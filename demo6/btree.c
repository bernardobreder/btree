#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "btree.h"

struct long_btree_t* long_btree_new(struct long_btree_node_t* (*readNodeFunc)(unsigned long id), void (*writeNodeFunc)(struct long_btree_node_t* node), void (*valueFreeFunc)(unsigned char*)) {
	struct long_btree_t* self = (struct long_btree_t*) calloc(1, sizeof(struct long_btree_t));
	if (!self) {
		return 0;
	}
	self->readNodeFunc = readNodeFunc;
	self->writeNodeFunc = writeNodeFunc;
	self->valueFreeFunc = valueFreeFunc;
	return self;
}

void long_btree_free(struct long_btree_t* self) {
}

static unsigned int long_btree_node_alloc_size(struct long_btree_t* self, struct long_btree_node_t* node) {
	unsigned int size = 0;
	while (node) {
		if (node->size + 1 > long_btree_order * 2) {
			size++;
			if (!node->parent) {
				size++;
			}
			node = node->parent;
		} else {
			break;
		}
	}
	return size;
}

static void long_btree_node_check_full(struct long_btree_t* self, struct long_btree_node_t* node, struct long_btree_node_t * nodes) {
	if (node->size + 1 > long_btree_order * 2) {
		int size = long_btree_order >> 1;
		if (node->parent) {
			struct long_btree_node_t* right = node++;
			memcpy(right->keys, node->keys + size + 1, size * sizeof(long));
			memcpy(right->values, node->values + size + 1, size * sizeof(unsigned char*));
			struct long_btree_node_t* parent = node->parent;
			{
				long key = node->keys[size];
				long* keys = parent->keys;
				int low = 0;
				int high = parent->size - 1;
				while (low < high) {
					int mid = (high - low) >> 1;
					if (key < keys[mid]) {
						high = mid - 1;
					} else if (key > keys[mid]) {
						low = mid + 1;
					}
				}
				int i = low;
				memcpy(parent->keys + i + 1, parent->keys + i, (parent->size - i) * sizeof(long));
				memcpy(parent->values + i + 1, parent->values + i, (parent->size - i) * sizeof(unsigned char*));
				parent->keys[i] = key;
				parent->values[i] = node->values[size];
			}
			node->size = size;
			right->size = size;
			parent->size++;
			node->changed = 1;
			right->changed = 1;
			parent->changed = 1;
			long_btree_node_check_full(self, parent, nodes);
		} else {
			struct long_btree_node_t* left = node++;
			struct long_btree_node_t* right = node++;
			memcpy(left->keys, node->keys, size * sizeof(long));
			memcpy(left->values, node->values, size * sizeof(unsigned char*));
			memcpy(right->keys, node->keys + size + 1, size * sizeof(long));
			memcpy(right->values, node->values + size + 1, size * sizeof(unsigned char*));
			node->keys[0] = node->keys[size];
			node->values[0] = node->values[size];
			left->size = size;
			right->size = size;
			node->size = 1;
			node->changed = 1;
			left->changed = 1;
			right->changed = 1;
		}
		node->changed = 1;
	}
}

unsigned char long_btree_add(struct long_btree_t* self, long key, unsigned char* value) {
	if (!self->root) {
		self->root = (struct long_btree_node_t*) calloc(1, sizeof(struct long_btree_node_t));
		if (!self->root) {
			return 1;
		}
		self->root->leaf = 1;
		self->size++;
		self->changed = 1;
		return 0;
	} else {
		struct long_btree_node_t* node = self->root;
		for (;;) {
			int low = 0;
			int high = node->size - 1;
			while (low < high) {
				int mid = (high - low) >> 1;
				if (key < node->keys[mid]) {
					high = mid - 1;
				} else if (key > node->keys[mid]) {
					low = mid + 1;
				} else {
					if (self->valueFreeFunc) {
						self->valueFreeFunc(node->values[mid]);
					}
					node->values[mid] = value;
					node->changed = 1;
					self->changed = 1;
					return 0;
				}
			}
			int i = low;
			if (node->leaf) {
				unsigned int size = long_btree_node_alloc_size(self, node);
				struct long_btree_node_t * nodes = 0;
				if (size > 0) {
					nodes = (struct long_btree_node_t*) calloc(size, sizeof(struct long_btree_node_t));
					if (!nodes) {
						return 1;
					}
					int n;
					for (n = 0; n < size; n++) {
						nodes[n].id = self->sequence++;
					}
				}
				memcpy(node->keys + i + 1, node->keys + i, (node->size - i) * sizeof(long));
				memcpy(node->values + i + 1, node->values + i, (node->size - i) * sizeof(unsigned char*));
				node->keys[i] = key;
				node->values[i] = value;
				node->size++;
				node->changed = 1;
				long_btree_node_check_full(self, node, nodes);
				self->size++;
				self->changed = 1;
				return 0;
			} else {
				if (key < node->keys[i]) {
					node = self->readNodeFunc(node->children[i]);
				} else {
					node = self->readNodeFunc(node->children[i + 1]);
				}
			}
		}
	}
	return 1;
}

unsigned char* long_btree_get(struct long_btree_t* self, long key) {
	return 0;
}

unsigned char* long_btree_remove(struct long_btree_t* self, long key) {
	return 0;
}

unsigned long long_btree_size(struct long_btree_t* self) {
	return 0;
}

void long_btree_clear(struct long_btree_t* self) {
}

void long_btree_test() {

}
