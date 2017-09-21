// http://www.amittai.com/prose/bpt.c

#include <stdio.h>
#include <stdlib.h>
#include "btree.h"

struct btree_node_t* btree_create_node();
struct btree_node_t* btree_create_leaf();
int btree_get_left_index(struct btree_node_t* parent, struct btree_node_t* left);
int btree_cut(int length);
unsigned char btree_is_changed(struct btree_node_t *root);
struct btree_node_t* btree_find_leaf(struct btree_t* self, void* key, unsigned char *has_parent);
void btree_destroy_tree_nodes(struct btree_t* self, struct btree_node_t* root);

struct btree_node_t* btree_insert_into_leaf(struct btree_t* self, struct btree_node_t* leaf, void* key, void* pointer);
struct btree_node_t* btree_insert_into_leaf_after_splitting(struct btree_t* self, struct btree_node_t* root, struct btree_node_t* leaf, void* key, void* pointer);
struct btree_node_t* btree_insert_into_node(struct btree_node_t* root, struct btree_node_t* parent, int left_index, void* key, struct btree_node_t* right);
struct btree_node_t* btree_insert_into_node_after_splitting(struct btree_t* self, struct btree_node_t* root, struct btree_node_t* parent, int left_index, void* key, struct btree_node_t* right);
struct btree_node_t* btree_insert_into_parent(struct btree_t* self, struct btree_node_t* root, struct btree_node_t* left, void* key, void* right);
struct btree_node_t* btree_insert_into_new_root(struct btree_node_t* left, void* key, struct btree_node_t* right);
struct btree_node_t* btree_start_new_tree(void* key, void* pointer);

int btree_get_neighbor_index(struct btree_node_t* node);
struct btree_node_t* btree_adjust_root(struct btree_node_t* root);
struct btree_node_t* btree_coalesce_nodes(struct btree_t* self, struct btree_node_t* root, struct btree_node_t* node, struct btree_node_t* neighbor, int neighbor_index, void* k_prime);
struct btree_node_t* btree_redistribute_nodes(struct btree_node_t* root, struct btree_node_t* node, struct btree_node_t* neighbor, int neighbor_index, int k_prime_index, void* k_prime);
struct btree_node_t* btree_delete_entry(struct btree_t* self, struct btree_node_t* root, struct btree_node_t* node, void* key, void * pointer);

void btree_free(struct btree_t *self) {
	if (self->root) {
		btree_destroy_tree_nodes(self, self->root);
	}
	self->root = 0;
	free(self);
}

void btree_destroy_tree_nodes(struct btree_t* self, struct btree_node_t* root) {
	int i;
	if (root->is_leaf) {
		if (self->freeKey) {
			for (i = 0; i < root->num_keys; i++) {
				self->freeKey(root->keys[i]);
			}
		}
		if (self->freeValue) {
			for (i = 0; i < root->num_keys + 1; i++) {
				self->freeValue(root->pointers[i]);
			}
		}
	} else {
		for (i = 0; i < root->num_keys + 1; i++) {
			btree_destroy_tree_nodes(self, root->pointers[i]);
		}
	}
	free(root);
}

struct btree_node_t* btree_find_leaf(struct btree_t* self, void* key, unsigned char *has_parent) {
	struct btree_node_t* node = self->root;
	if (!node) return node;
	while (!node->is_leaf) {
		int i = 0;
		while (i < node->num_keys) {
			int compare = self->compare(key, node->keys[i]);
			if (compare == 0 && has_parent) *has_parent = 1;
			if (compare >= 0) i++;
			else break;
		}
		node = (struct btree_node_t*) node->pointers[i];
	}
	return node;
}

int btree_find_range(struct btree_t* self, void* key_start, void* key_end, void* returned_keys[], void* returned_pointers[]) {
	int i, num_found;
	num_found = 0;
	struct btree_node_t* n = btree_find_leaf(self, key_start, 0);
	if (!n) return 0;
	for (i = 0; i < n->num_keys && n->keys[i] < key_start; i++) {
	}
	if (i == n->num_keys) return 0;
	while (n) {
		for (; i < n->num_keys && n->keys[i] <= key_end; i++) {
			if (returned_keys) returned_keys[num_found] = n->keys[i];
			if (returned_pointers) returned_pointers[num_found] = n->pointers[i];
			num_found++;
		}
		n = n->pointers[BTREE_ORDER - 1];
		i = 0;
	}
	return num_found;
}

int btree_find_index(struct btree_t* self, struct btree_node_t* node, void* key) {
	int i;
	for (i = 0; i < node->num_keys; i++) {
		if (self->compare(node->keys[i], key) == 0) {
			break;
		}
	}
	return (i == node->num_keys) ? -1 : i;
}

void* btree_find(struct btree_t* self, void* key) {
	struct btree_node_t* n = btree_find_leaf(self, key, 0);
	if (!n) return 0;
	int i = btree_find_index(self, n, key);
	return (i < 0) ? 0 : n->pointers[i];
}

int btree_cut(int length) {
	return (length % 2 == 0) ? length / 2 : length / 2 + 1;
}

unsigned char btree_is_changed(struct btree_node_t *root) {
	if (root->changed) return 1;
	if (!root->is_leaf) {
		int m;
		for (m = 0; m < root->num_keys + 1; m++) {
			if (btree_is_changed((struct btree_node_t*) root->pointers[m])) {
				return 1;
			}
		}
	}
	return 0;
}

struct btree_node_t* btree_create_node() {
	struct btree_node_t* node = malloc(sizeof(struct btree_node_t));
	if (!node) return 0;
	node->is_leaf = 0;
	node->num_keys = 0;
	node->parent = 0;
	node->changed = 1;
	return node;
}

struct btree_node_t* btree_create_leaf() {
	struct btree_node_t* leaf = btree_create_node();
	if (!leaf) return 0;
	leaf->is_leaf = 1;
	return leaf;
}

int btree_get_left_index(struct btree_node_t* parent, struct btree_node_t* left) {
	int left_index = 0;
	while (left_index <= parent->num_keys && parent->pointers[left_index] != left) {
		left_index++;
	}
	return left_index;
}

void btree_clean_changed(struct btree_node_t* root) {
	root->changed = 0;
	if (!root->is_leaf) {
		int n;
		for (n = 0; n < root->num_keys + 1; n++) {
			btree_clean_changed((struct btree_node_t*) root->pointers[n]);
		}
	}
}

struct btree_node_t* btree_insert_into_node(struct btree_node_t* root, struct btree_node_t* n, int left_index, void* key, struct btree_node_t* right) {
	int i;
	for (i = n->num_keys; i > left_index; i--) {
		n->pointers[i + 1] = n->pointers[i];
		n->keys[i] = n->keys[i - 1];
	}
	n->pointers[left_index + 1] = right;
	n->keys[left_index] = key;
	n->num_keys++;
	n->changed = 1;
	return root;
}

struct btree_node_t* btree_insert_into_new_root(struct btree_node_t* left, void* key, struct btree_node_t* right) {
	struct btree_node_t* root = btree_create_node();
	root->keys[0] = key;
	root->pointers[0] = left;
	root->pointers[1] = right;
	root->num_keys++;
	root->parent = NULL;
	left->parent = root;
	right->parent = root;
	left->changed = 1;
	right->changed = 1;
	return root;
}

struct btree_node_t* btree_insert_into_leaf_after_splitting(struct btree_t* self, struct btree_node_t* root, struct btree_node_t* leaf, void* key, void* pointer) {
	struct btree_node_t* new_leaf = btree_create_leaf();
	if (!new_leaf) return 0;
	void* temp_keys[BTREE_ORDER];
	void* temp_pointers[BTREE_ORDER];
	int insertion_index = 0;
	while (insertion_index < BTREE_ORDER - 1 && self->compare(leaf->keys[insertion_index], key) < 0) {
		insertion_index++;
	}
	int i, j;
	for (i = 0, j = 0; i < leaf->num_keys; i++, j++) {
		if (j == insertion_index) j++;
		temp_keys[j] = leaf->keys[i];
		temp_pointers[j] = leaf->pointers[i];
	}
	temp_keys[insertion_index] = key;
	temp_pointers[insertion_index] = pointer;
	leaf->num_keys = 0;
	int split = btree_cut(BTREE_ORDER - 1);
	for (i = 0; i < split; i++) {
		leaf->pointers[i] = temp_pointers[i];
		leaf->keys[i] = temp_keys[i];
		leaf->num_keys++;
	}
	for (i = split, j = 0; i < BTREE_ORDER; i++, j++) {
		new_leaf->pointers[j] = temp_pointers[i];
		new_leaf->keys[j] = temp_keys[i];
		new_leaf->num_keys++;
	}
	new_leaf->pointers[BTREE_ORDER - 1] = leaf->pointers[BTREE_ORDER - 1];
	leaf->pointers[BTREE_ORDER - 1] = new_leaf;
	for (i = leaf->num_keys; i < BTREE_ORDER - 1; i++) {
		leaf->pointers[i] = NULL;
	}
	for (i = new_leaf->num_keys; i < BTREE_ORDER - 1; i++) {
		new_leaf->pointers[i] = NULL;
	}
	new_leaf->parent = leaf->parent;
	void* new_key = new_leaf->keys[0];
	leaf->changed = 1;
	return btree_insert_into_parent(self, root, leaf, new_key, new_leaf);
}

struct btree_node_t* btree_insert_into_parent(struct btree_t* self, struct btree_node_t* root, struct btree_node_t* left, void* key, void* right) {
	struct btree_node_t* parent = left->parent;
	if (!parent) return btree_insert_into_new_root(left, key, right);
	int left_index = btree_get_left_index(parent, left);
	if (parent->num_keys < BTREE_ORDER - 1) return btree_insert_into_node(root, parent, left_index, key, right);
	return btree_insert_into_node_after_splitting(self, root, parent, left_index, key, right);
}

struct btree_node_t* btree_insert_into_node_after_splitting(struct btree_t* self, struct btree_node_t* root, struct btree_node_t* old_node, int left_index, void* key, struct btree_node_t* right) {
	int i, j;
	struct btree_node_t* temp_pointers[BTREE_ORDER];
	void* temp_keys[BTREE_ORDER - 1];
	for (i = 0, j = 0; i < old_node->num_keys + 1; i++, j++) {
		if (j == left_index + 1) j++;
		temp_pointers[j] = old_node->pointers[i];
	}
	for (i = 0, j = 0; i < old_node->num_keys; i++, j++) {
		if (j == left_index) j++;
		temp_keys[j] = old_node->keys[i];
	}
	temp_pointers[left_index + 1] = right;
	temp_keys[left_index] = key;

	int split = btree_cut(BTREE_ORDER);
	struct btree_node_t* new_node = btree_create_node();
	old_node->num_keys = 0;
	for (i = 0; i < split - 1; i++) {
		old_node->pointers[i] = temp_pointers[i];
		old_node->keys[i] = temp_keys[i];
		old_node->num_keys++;
	}
	old_node->pointers[i] = temp_pointers[i];
	void* k_prime = temp_keys[split - 1];
	for (++i, j = 0; i < BTREE_ORDER; i++, j++) {
		new_node->pointers[j] = temp_pointers[i];
		new_node->keys[j] = temp_keys[i];
		new_node->num_keys++;
	}
	new_node->pointers[j] = temp_pointers[i];
	new_node->parent = old_node->parent;
	for (i = 0; i <= new_node->num_keys; i++) {
		struct btree_node_t* child = new_node->pointers[i];
		child->parent = new_node;
	}
	old_node->changed = 1;
	return btree_insert_into_parent(self, root, old_node, k_prime, new_node);
}

struct btree_node_t* btree_insert_into_leaf(struct btree_t* self, struct btree_node_t* leaf, void* key, void* pointer) {
	int i, insertion_point;
	insertion_point = 0;
	while (insertion_point < leaf->num_keys && self->compare(leaf->keys[insertion_point], key) < 0) {
		insertion_point++;
	}
	for (i = leaf->num_keys; i > insertion_point; i--) {
		leaf->keys[i] = leaf->keys[i - 1];
		leaf->pointers[i] = leaf->pointers[i - 1];
	}
	leaf->keys[insertion_point] = key;
	leaf->pointers[insertion_point] = pointer;
	leaf->num_keys++;
	leaf->changed = 1;
	return leaf;
}

struct btree_node_t* btree_start_new_tree(void* key, void* pointer) {
	struct btree_node_t* root = btree_create_leaf();
	root->keys[0] = key;
	root->pointers[0] = pointer;
	root->pointers[BTREE_ORDER - 1] = 0;
	root->parent = 0;
	root->num_keys++;
	return root;
}

unsigned char btree_insert(struct btree_t* self, void* key, void* value) {
	struct btree_node_t *root = self->root;
	if (btree_find(self, key)) return 0;
	if (!root) {
		self->root = btree_start_new_tree(key, value);
		self->changed = 1;
		return 1;
	}
	struct btree_node_t* leaf = btree_find_leaf(self, key, 0);
	if (leaf->num_keys < BTREE_ORDER - 1) {
		btree_insert_into_leaf(self, leaf, key, value);
		self->changed = 1;
		return 1;
	}
	self->root = btree_insert_into_leaf_after_splitting(self, self->root, leaf, key, value);
	self->changed = self->changed || self->root != root || btree_is_changed(self->root);
	return 1;
}

int btree_get_neighbor_index(struct btree_node_t* node) {
	int i;
	for (i = 0; i <= node->parent->num_keys; i++) {
		if (node->parent->pointers[i] == node) return i - 1;
	}
	return -1;
}

struct btree_node_t* btree_remove_entry_from_node(struct btree_t* self, struct btree_node_t* node, void* key, struct btree_node_t* pointer) {
	int i = 0;
	while (self->compare(node->keys[i], key) != 0) {
		i++;
	}
	for (++i; i < node->num_keys; i++) {
		node->keys[i - 1] = node->keys[i];
	}
	int num_pointers = node->is_leaf ? node->num_keys : node->num_keys + 1;
	i = 0;
	while (node->pointers[i] != pointer) {
		i++;
	}
	for (++i; i < num_pointers; i++) {
		node->pointers[i - 1] = node->pointers[i];
	}
	node->num_keys--;
	if (node->is_leaf) {
		for (i = node->num_keys; i < BTREE_ORDER - 1; i++) {
			node->pointers[i] = 0;
		}
	} else {
		for (i = node->num_keys + 1; i < BTREE_ORDER; i++) {
			node->pointers[i] = 0;
		}
	}
	node->changed = 1;
	return node;
}

struct btree_node_t* btree_adjust_root(struct btree_node_t* root) {
	struct btree_node_t* new_root;
	if (root->num_keys > 0) return root;
	if (!root->is_leaf) {
		new_root = root->pointers[0];
		new_root->parent = 0;
		new_root->changed = 1;
	} else new_root = 0;
	free(root);
	return new_root;
}

struct btree_node_t* btree_coalesce_nodes(struct btree_t* self, struct btree_node_t* root, struct btree_node_t* node, struct btree_node_t* neighbor, int neighbor_index, void* k_prime) {
	int i, j, neighbor_insertion_index, n_end;
	struct btree_node_t* tmp;
	if (neighbor_index == -1) {
		tmp = node;
		node = neighbor;
		neighbor = tmp;
	}
	neighbor_insertion_index = neighbor->num_keys;
	if (!node->is_leaf) {
		neighbor->keys[neighbor_insertion_index] = k_prime;
		neighbor->num_keys++;
		n_end = node->num_keys;
		for (i = neighbor_insertion_index + 1, j = 0; j < n_end; i++, j++) {
			neighbor->keys[i] = node->keys[j];
			neighbor->pointers[i] = node->pointers[j];
			neighbor->num_keys++;
			node->num_keys--;
		}
		neighbor->pointers[i] = node->pointers[j];
		for (i = 0; i < neighbor->num_keys + 1; i++) {
			tmp = (struct btree_node_t*) neighbor->pointers[i];
			tmp->parent = neighbor;
			tmp->changed = 1;
		}
	} else {
		for (i = neighbor_insertion_index, j = 0; j < node->num_keys;
		        i++, j++) {
			neighbor->keys[i] = node->keys[j];
			neighbor->pointers[i] = node->pointers[j];
			neighbor->num_keys++;
		}
		neighbor->pointers[BTREE_ORDER - 1] = node->pointers[BTREE_ORDER - 1];
	}
	root = btree_delete_entry(self, root, node->parent, k_prime, node);
	free(node);
	neighbor->changed = 1;
	return root;
}

struct btree_node_t* btree_redistribute_nodes(struct btree_node_t* root, struct btree_node_t* node, struct btree_node_t* neighbor, int neighbor_index, int k_prime_index, void* k_prime) {
	int i;
	struct btree_node_t* tmp;
	if (neighbor_index != -1) {
		if (!node->is_leaf) node->pointers[node->num_keys + 1] = node->pointers[node->num_keys];
		for (i = node->num_keys; i > 0; i--) {
			node->keys[i] = node->keys[i - 1];
			node->pointers[i] = node->pointers[i - 1];
		}
		if (!node->is_leaf) {
			node->pointers[0] = neighbor->pointers[neighbor->num_keys];
			tmp = (struct btree_node_t*) node->pointers[0];
			tmp->parent = node;
			neighbor->pointers[neighbor->num_keys] = NULL;
			node->keys[0] = k_prime;
			node->parent->keys[k_prime_index] = neighbor->keys[neighbor->num_keys - 1];
		} else {
			node->pointers[0] = neighbor->pointers[neighbor->num_keys - 1];
			neighbor->pointers[neighbor->num_keys - 1] = NULL;
			node->keys[0] = neighbor->keys[neighbor->num_keys - 1];
			node->parent->keys[k_prime_index] = node->keys[0];
		}
	} else {
		if (node->is_leaf) {
			node->keys[node->num_keys] = neighbor->keys[0];
			node->pointers[node->num_keys] = neighbor->pointers[0];
			node->parent->keys[k_prime_index] = neighbor->keys[1];
		} else {
			node->keys[node->num_keys] = k_prime;
			node->pointers[node->num_keys + 1] = neighbor->pointers[0];
			tmp = (struct btree_node_t*) node->pointers[node->num_keys + 1];
			tmp->parent = node;
			node->parent->keys[k_prime_index] = neighbor->keys[0];
		}
		for (i = 0; i < neighbor->num_keys - 1; i++) {
			neighbor->keys[i] = neighbor->keys[i + 1];
			neighbor->pointers[i] = neighbor->pointers[i + 1];
		}
		if (!node->is_leaf) neighbor->pointers[i] = neighbor->pointers[i + 1];
	}
	node->num_keys++;
	neighbor->num_keys--;
	node->changed = 1;
	neighbor->changed = 1;
	return root;
}

struct btree_node_t* btree_delete_entry(struct btree_t* self, struct btree_node_t* root, struct btree_node_t* node, void* key, void* pointer) {
	node = btree_remove_entry_from_node(self, node, key, pointer);
	if (node == root) return btree_adjust_root(root);
	int min_keys =
	        node->is_leaf ? btree_cut(BTREE_ORDER - 1) : btree_cut(BTREE_ORDER) - 1;
	if (node->num_keys >= min_keys) return root;
	int neighbor_index = btree_get_neighbor_index(node);
	int k_prime_index = neighbor_index == -1 ? 0 : neighbor_index;
	void* k_prime = node->parent->keys[k_prime_index];
	struct btree_node_t* neighbor =
	        neighbor_index == -1 ? node->parent->pointers[1] : node->parent->pointers[neighbor_index];
	int capacity = node->is_leaf ? BTREE_ORDER : BTREE_ORDER - 1;
	if (neighbor->num_keys + node->num_keys < capacity) return btree_coalesce_nodes(self, root, node, neighbor, neighbor_index, k_prime);
	else return btree_redistribute_nodes(root, node, neighbor, neighbor_index, k_prime_index, k_prime);
}

unsigned char btree_delete(struct btree_t* self, void* key) {
	unsigned char has_parent = 0;
	struct btree_node_t* root = self->root;
	struct btree_node_t* leaf = btree_find(self, key);
	if (!leaf) return 0;
	int i = btree_find_index(self, leaf, key);
	if (i < 0) return 0;
	void* valuei = leaf->pointers[i];
	self->root = btree_delete_entry(self, root, leaf, key, valuei);
	self->changed = 1;
//	if (self->freeKey && !has_parent) self->freeKey(keyi);
//	if (self->freeValue) self->freeValue(valuei);
	return 1;
}

struct btree_t* btree_new(int (*compare)(void*, void*), void (*freeKey)(void*), void (*freeValue)(void*)) {
	struct btree_t* self = (struct btree_t*) malloc(sizeof(struct btree_t));
	self->root = 0;
	self->changed = 1;
	self->sequence = 1;
	self->compare = compare;
	self->freeKey = freeKey;
	self->freeValue = freeValue;
	return self;
}
