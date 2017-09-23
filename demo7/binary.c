#include <stdlib.h>
#include "binary.h"

struct b_binary_tree_t* b_binary_tree_new(struct b_binary_tree_t* self, int (*compare)(void*, void*), void* (*mallocFunc)(size_t), void (*selfFree)(void*), void (*keyFree)(void*),
		void (*valueFree)(void*)) {
	if (!mallocFunc) {
		mallocFunc = malloc;
	}
	if (!self) {
		self = (struct b_binary_tree_t*) mallocFunc(sizeof(struct b_binary_tree_t));
		if (!self) {
			return 0;
		}
	}
	self->size = 0;
	self->root = 0;
	self->compare = compare;
	self->mallocFunc = mallocFunc;
	self->selfFree = selfFree;
	self->keyFree = keyFree;
	self->valueFree = valueFree;
	return self;
}

static void b_binary_tree_node_free(struct b_binary_tree_t* self, struct b_binary_tree_node_t* node) {
	if (self->keyFree) {
		self->keyFree(node->key);
	}
	if (self->valueFree) {
		self->valueFree(node->value);
	}
	if (self->selfFree) {
		self->selfFree(node);
	}
	if (node->left) {
		b_binary_tree_node_free(self, node->left);
	}
	if (node->right) {
		b_binary_tree_node_free(self, node->right);
	}
}

void b_binary_tree_free(struct b_binary_tree_t* self) {
	if (self->root) {
		b_binary_tree_node_free(self, self->root);
	}
	if (self->selfFree) {
		self->selfFree(self);
	}
}

unsigned int b_binary_tree_size(struct b_binary_tree_t* self) {
	return self->size;
}

void* b_binary_tree_get(struct b_binary_tree_t* self, void* key) {
	if (!self->root) {
		return 0;
	}
	struct b_binary_tree_node_t* node = self->root;
	while (node) {
		int compare = self->compare(key, node->key);
		if (!compare) {
			return node->value;
		} else if (compare < 0) {
			node = node->left;
		} else {
			node = node->right;
		}
	}
	return 0;
}

unsigned char b_binary_tree_set(struct b_binary_tree_t* self, struct b_binary_tree_node_t* node, void* key, void* value) {
	if (!self->root) {
		if (!node) {
			node = (struct b_binary_tree_node_t*) self->mallocFunc(sizeof(struct b_binary_tree_node_t));
			if (!node) {
				return 1;
			}
		}
		node->key = key;
		node->value = value;
		node->parent = 0;
		node->left = 0;
		node->right = 0;
		self->root = node;
		return 0;
	}
	struct b_binary_tree_node_t* aux = self->root;
	while (aux) {
		int compare = self->compare(key, aux->key);
		if (!compare) {
			if (self->keyFree) {
				self->keyFree(aux->key);
			}
			if (self->valueFree) {
				self->valueFree(aux->key);
			}
			aux->key = key;
			aux->value = value;
		} else if (compare < 0) {
			if (aux->left) {
				aux = aux->left;
			} else {
				if (!node) {
					node = (struct b_binary_tree_node_t*) self->mallocFunc(sizeof(struct b_binary_tree_node_t));
					if (!node) {
						return 1;
					}
				}
				node->key = key;
				node->value = value;
				node->parent = aux;
				node->left = 0;
				node->right = 0;
				aux->left = node;
				return 0;
			}
		} else {
			if (aux->right) {
				aux = aux->right;
			} else {
				if (!node) {
					node = (struct b_binary_tree_node_t*) self->mallocFunc(sizeof(struct b_binary_tree_node_t));
					if (!node) {
						return 1;
					}
				}
				node->key = key;
				node->value = value;
				node->parent = aux;
				node->left = 0;
				node->right = 0;
				aux->right = node;
				return 0;
			}
		}
	}
	return 0;
}

static void b_binary_tree_node_del(struct b_binary_tree_t* self, struct b_binary_tree_node_t* node) {
	if (!node->left && !node->right) {
		struct b_binary_tree_node_t* parent = node->parent;
		if (parent) {
			if (parent->left == node) {
				parent->left = 0;
			} else {
				parent->right = 0;
			}
		} else {
			self->root = 0;
		}
		if (self->selfFree) {
			self->selfFree(node);
		}
	} else if (node->left) {
		struct b_binary_tree_node_t* aux = node->left;
		while (aux->right) {
			aux = aux->right;
		}
		node->key = aux->key;
		node->value = aux->value;
		b_binary_tree_node_del(self, aux);
	} else if (node->right) {
		struct b_binary_tree_node_t* aux = node->right;
		while (aux->left) {
			aux = aux->left;
		}
		node->key = aux->key;
		node->value = aux->value;
		b_binary_tree_node_del(self, aux);
	}
}

void b_binary_tree_del(struct b_binary_tree_t* self, void* key) {
	if (!self->root) {
		return;
	}
	struct b_binary_tree_node_t* node = self->root;
	while (node) {
		int compare = self->compare(key, node->key);
		if (!compare) {
			if (self->keyFree) {
				self->keyFree(node->key);
			}
			if (self->valueFree) {
				self->valueFree(node->value);
			}
			b_binary_tree_node_del(self, node);
			break;
		} else if (compare < 0) {
			node = node->left;
		} else {
			node = node->right;
		}
	}
	self->compare(key, key);
}
