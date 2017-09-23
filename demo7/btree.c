#include <stdlib.h>
#include <string.h>
#include "btree.h"

static void b_btree_node_free(struct b_btree_t* tree, struct b_btree_node_t* self) {
	if (self->keys) {
		int n, size = self->key_size;
		void** aux = self->keys;
		for (n = 0; n < size; n++) {
			tree->keyFree(*(aux++));
		}
		tree->selfFree(self->keys);
	}
	if (self->values) {
		int n, size = self->key_size;
		void** aux = self->values;
		for (n = 0; n < size; n++) {
			tree->valueFree(*(aux++));
		}
		tree->selfFree(self->values);
	}
	if (self->childrenId) {
		tree->selfFree(self->childrenId);
	}
	if (self->children) {
		int n, size = self->children_size;
		struct b_btree_node_t** aux = self->children;
		for (n = 0; n < size; n++) {
			b_btree_node_free(tree, *(aux++));
		}
		tree->selfFree(self->children);
	}
	tree->selfFree(self);
}

static struct b_btree_node_t* b_btree_node_new(struct b_btree_t* tree) {
	struct b_btree_node_t* self = (struct b_btree_node_t*) tree->mallocFunc(sizeof(struct b_btree_node_t));
	if (!self) {
		return 0;
	}
	self->id = tree->sequence();
	self->key_size = 0;
	self->children_size = 0;
	self->user_data = 0;
	self->keys = (void**) tree->mallocFunc(sizeof(void*) * ((tree->half_max * 2) - 1));
	self->values = (void**) tree->mallocFunc(sizeof(void*) * ((tree->half_max * 2) - 1));
	self->children = (struct b_btree_node_t**) tree->mallocFunc(tree->half_max * 2 * sizeof(struct b_btree_node_t*));
	self->childrenId = (unsigned long*) tree->mallocFunc(tree->half_max * 2 * sizeof(unsigned long));
	if (!self->keys || !self->values || !self->children || !self->childrenId) {
		b_btree_node_free(tree, self);
		return 0;
	}
	memset(self->keys, 0, sizeof(void*) * ((tree->half_max * 2) - 1));
	memset(self->values, 0, sizeof(void*) * ((tree->half_max * 2) - 1));
	memset(self->children, 0, sizeof(void*) * tree->half_max * 2);
	memset(self->childrenId, 0, sizeof(unsigned long) * tree->half_max * 2);
	return self;
}

struct b_btree_t* b_btree_new(struct b_btree_t* self, int half_max, int (*compare)(void*, void*), unsigned long (*sequence)(), struct b_btree_t* (*readTree)(),
		unsigned char (*writeTree)(struct b_btree_t*), unsigned char (*deleteTree)(struct b_btree_t*), struct b_btree_node_t* (*readNode)(unsigned long),
		unsigned char (*writeNode)(struct b_btree_node_t*), unsigned char (*deleteNode)(struct b_btree_node_t*), void* (*mallocFunc)(size_t), void (*selfFree)(void*), void (*keyFree)(void*),
		void (*valueFree)(void*)) {
	mallocFunc = mallocFunc ? mallocFunc : malloc;
	if (!self) {
		self = (struct b_btree_t*) mallocFunc(sizeof(struct b_btree_t));
		if (!self) {
			return 0;
		}
	}
	self->mallocFunc = mallocFunc;
	self->half_max = half_max;
	self->compare = compare;
	self->sequence = sequence;
	self->readTree = readTree;
	self->writeTree = writeTree;
	self->deleteTree = deleteTree;
	self->readNode = readNode;
	self->writeNode = writeNode;
	self->deleteNode = deleteNode;
	self->selfFree = selfFree ? selfFree : free;
	self->keyFree = keyFree ? keyFree : free;
	self->valueFree = valueFree ? valueFree : free;
	self->size = 0;
	self->root = b_btree_node_new(self);
	if (!self->root) {
		b_btree_free(self);
		return 0;
	}
	return self;
}

static double b_btree_node_index_of(struct b_btree_t* tree, struct b_btree_node_t* self, void* key) {
	int i, size = self->key_size;
	for (i = 0; i < size; i++) {
		int compare = tree->compare(self->keys[i], key);
		if (!compare) {
			return i;
		} else if (compare > 0) {
			return (double) i + 0.5;
		}
	}
	return (double) (self->key_size + 1) - 0.5;
}

static void b_btree_node_add_locally(struct b_btree_t* tree, struct b_btree_node_t* self, void* key, void* value) {
	double d = b_btree_node_index_of(tree, self, key);
	int i = (int) d;
	if (i != d) {
		int size = self->key_size - i - 1;
		if (size > 0) {
			memcpy(self->keys + i + 1, self->keys + i, size * sizeof(void*));
			memcpy(self->values + i + 1, self->values + i, size * sizeof(void*));
		}
		self->keys[i] = key;
		self->values[i] = value;
		self->key_size++;
		if (self->children_size) {
			size = self->children_size - i - 1;
			if (size > 0) {
				memcpy(self->children + i + 1, self->children + i, size * sizeof(struct b_btree_node_t*));
				memcpy(self->childrenId + i + 1, self->childrenId + i, size * sizeof(unsigned long));
			}
			self->children[i + 1] = 0;
			self->childrenId[i + 1] = 0;
			self->children_size++;
		}
	}
}

static struct b_btree_node_t* b_btree_node_create_right_sibling(struct b_btree_t* tree, struct b_btree_node_t* self) {
	int i, i0 = tree->half_max, size = tree->half_max * 2 - 1, n = tree->half_max;
	struct b_btree_node_t* node = b_btree_node_new(tree);
	for (i = i0; i < size; i++) {
		char* key = self->keys[n];
		void* value = self->values[n];
		int msize = self->key_size - n - 1;
		if (msize > 0) {
			memcpy(self->keys + n, self->keys + n + 1, msize * sizeof(void*));
			memcpy(self->values + n, self->values + n + 1, msize * sizeof(void*));
		}
		node->keys[self->key_size] = key;
		node->values[self->key_size++] = value;
	}
	if (self->children_size) {
		size--;
		for (i = i0; i < size; i++) {
			struct b_btree_node_t* child = self->children[n];
			unsigned int msize = self->children_size - n - 1;
			if (msize > 0) {
				memcpy(self->children + n, self->children + n + 1, msize * sizeof(struct b_btree_node_t*));
				memcpy(self->childrenId + n, self->childrenId + n + 1, msize * sizeof(unsigned long));
			}
			node->children[self->children_size] = child;
			node->childrenId[self->children_size++] = child->id;
		}
	}
	if (tree->writeNode ? tree->writeNode(node) : 0) {
		// TODO Reverter
		return 0;
	}
	return node;
}

static unsigned char b_btree_node_split_child(struct b_btree_t* tree, struct b_btree_node_t* self, unsigned int index, struct b_btree_node_t* child) {
	struct b_btree_node_t* node = b_btree_node_create_right_sibling(tree, child);
	if (!node) {
		return 1;
	}
	int n = tree->half_max - 1;
	char* key = child->keys[n];
	void* value = child->values[n];
	int size = self->key_size - n - 1;
	if (size > 0) {
		memcpy(self->keys + n, self->keys + n + 1, size * sizeof(void*));
		memcpy(self->values + n, self->values + n + 1, size * sizeof(void*));
	}
	self->key_size--;
	b_btree_node_add_locally(tree, self, key, value);
	if (tree->writeNode ? tree->writeNode(child) : 0) {
		// Reverter a adição local
		return 1;
	}
	self->children[index + 1] = node;
	self->childrenId[index + 1] = node->id;
	return 0;
}

static struct b_btree_node_t* b_btree_node_new_children(struct b_btree_t* tree, struct b_btree_node_t* child) {
	struct b_btree_node_t* self = b_btree_node_new(tree);
	if (!self) {
		return 0;
	}
	self->children[0] = child;
	self->childrenId[0] = child->id;
	self->children_size++;
	b_btree_node_split_child(tree, self, 0, child);
	return self;
}

unsigned char b_btree_node_add(struct b_btree_t* tree, struct b_btree_node_t* self, void* key, void* value) {
	struct b_btree_node_t* node = self;
	while (node->children_size) {
		double d = b_btree_node_index_of(tree, self, key);
		int i = (int) d;
		if (i == d) {
			// TODO Alterar o valor
			return 0;
		} else {
			struct b_btree_node_t* child = node->children[i];
			if (!child) {
				child = tree->readNode ? tree->readNode(node->childrenId[i]) : 0;
				if (!child) {
					return 1;
				}
			}
			if (child->key_size + 1 == tree->half_max * 2) {
				if (b_btree_node_split_child(tree, node, i, child)) {
					return 1;
				}
			} else {
				if (tree->writeNode ? tree->writeNode(node) : 0) {
					return 1;
				}
				node = child;
			}
		}
	}
	b_btree_node_add_locally(tree, node, key, value);
	if (tree->writeNode ? tree->writeNode(node) : 0) {
		// TODO Reverter o adição no node
		return 1;
	}
	return 0;
}

void b_btree_free(struct b_btree_t* self) {
	self->size = 0;
	self->root = 0;
	self->selfFree(self);
}

unsigned int b_btree_size(struct b_btree_t* self) {
	return self->size;
}

unsigned char b_btree_add(struct b_btree_t* self, void* key, void* value) {
	struct b_btree_node_t* root = self->root;
	if (!root) {
		root = self->readNode ? self->readNode(self->rootId) : 0;
		if (!root) {
			return 1;
		}
	}
	if (root->key_size + 1 == self->half_max * 2) {
		struct b_btree_node_t* parent = b_btree_node_new_children(self, root);
		self->rootId = parent->id;
		if (self->writeTree ? self->writeTree(self) : 0) {
			// TODO Pensar se tem que reverter
			return 1;
		}
		b_btree_node_add(self, parent, key, value);
	} else {
		b_btree_node_add(self, root, key, value);
	}
	return 0;
}

void* b_btree_get(struct b_btree_t* self, void* key) {
}

void b_btree_del(struct b_btree_t* self, void* key) {
}
