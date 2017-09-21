#include "bpt.h"

int bptn_find_range(struct bptn* root, int* key_start, int* key_end, void* returned_keys[], void* returned_pointers[], int (*compare)(void*, void*));
struct bptn* bptn_find_leaf(struct bptn* root, int* key, int (*compare)(void*, void*));
int bptn_cut(int length);

// Insertion.

struct bptn* bptn_create_node(void);
struct bptn* bptn_create_node_leaf(void);
int bptn_get_left_index(struct bptn* parent, struct bptn* left);
struct bptn* bptn_insert_into_leaf(struct bptn* leaf, int* key, void* pointer, int (*compare)(void*, void*));
struct bptn* bptn_insert_into_leaf_after_splitting(struct bptn* root, struct bptn* leaf, int* key, void* pointer, int (*compare)(void*, void*));
struct bptn* bptn_insert_into_node(struct bptn* root, struct bptn* parent, int left_index, int* key, struct bptn* right);
struct bptn* bptn_insert_into_node_after_splitting(struct bptn* root, struct bptn* parent, int left_index, int* key, struct bptn* right);
struct bptn* bptn_insert_into_parent(struct bptn* root, struct bptn* left, int* key, struct bptn* right);
struct bptn* bptn_insert_into_new_root(struct bptn* left, int* key, struct bptn* right);
struct bptn* bptn_start_new_tree(int* key, void* pointer);

// Deletion.

int bptn_get_neighbor_index(struct bptn* n);
struct bptn* bptn_adjust_root(struct bptn* root);
struct bptn* bptn_coalesce_nodes(struct bptn* root, struct bptn* n, struct bptn* neighbor, int neighbor_index, int* k_prime, unsigned char canFreeKey, int (*compare)(void*, void*), void (*freeKey)(void*), void (*freeValue)(void*));
struct bptn* bptn_redistribute_nodes(struct bptn* root, struct bptn* n, struct bptn* neighbor, int neighbor_index, int k_prime_index, int* k_prime);
struct bptn* bptn_remove_entry(struct bptn* root, struct bptn* n, int* key, void * pointer, unsigned char canFreeKey, int (*compare)(void*, void*), void (*freeKey)(void*), void (*freeValue)(void*));

struct bptn * queue = NULL;

void enqueue(struct bptn* new_node) {
	struct bptn* c;
	if (queue == NULL) {
		queue = new_node;
		queue->next = NULL;
	} else {
		c = queue;
		while (c->next != NULL) {
			c = c->next;
		}
		c->next = new_node;
		new_node->next = NULL;
	}
}

struct bptn* dequeue(void) {
	struct bptn* n = queue;
	queue = queue->next;
	n->next = NULL;
	return n;
}

int path_to_root(struct bptn* root, struct bptn* child) {
	int length = 0;
	struct bptn* c = child;
	while (c != root) {
		c = c->parent;
		length++;
	}
	return length;
}

void print_tree(struct bptn* root) {
	struct bptn* n = NULL;
	int i = 0;
	int rank = 0;
	int new_rank = 0;
	if (root == NULL) {
		printf("Empty tree.\n");
		return;
	}
	queue = NULL;
	enqueue(root);
	while (queue != NULL) {
		n = dequeue();
		if (n->parent != NULL && n == n->parent->pointers[0]) {
			new_rank = path_to_root(root, n);
			if (new_rank != rank) {
				rank = new_rank;
				printf("\n");
			}
		}
		if (n->changed) printf("*");
		for (i = 0; i < n->num_keys; i++) {
			printf("%d ", *n->keys[i]);
		}
		if (!n->is_leaf) for (i = 0; i <= n->num_keys; i++)
			enqueue(n->pointers[i]);
		printf("| ");
	}
	printf("\n");
}

int bptn_find_range(struct bptn* root, int* key_start, int* key_end, void* returned_keys[], void* returned_pointers[], int (*compare)(void*, void*)) {
	int i, num_found;
	num_found = 0;
	struct bptn* n = bptn_find_leaf(root, key_start, compare);
	if (n == 0) return 0;
	for (i = 0; i < n->num_keys && n->keys[i] < key_start; i++) {
	}
	if (i == n->num_keys) return 0;
	while (n != 0) {
		for (; i < n->num_keys && n->keys[i] <= key_end; i++) {
			returned_keys[num_found] = n->keys[i];
			returned_pointers[num_found] = n->pointers[i];
			num_found++;
		}
		n = n->pointers[ORDER - 1];
		i = 0;
	}
	return num_found;
}

struct bptn* bptn_find_leaf(struct bptn* root, int* key, int (*compare)(void*, void*)) {
	struct bptn* c = root;
	if (c == 0) return c;
	while (!c->is_leaf) {
		int i = 0;
		while (i < c->num_keys) {
			if (compare(key, c->keys[i]) >= 0) i++;
			else break;
		}
		c = (struct bptn*) c->pointers[i];
	}
	return c;
}

void* bptn_find(struct bptn* root, int* key, int (*compare)(void*, void*)) {
	struct bptn* c = bptn_find_leaf(root, key, compare);
	if (c == 0) return 0;
	int i;
	for (i = 0; i < c->num_keys; i++)
		if (compare(c->keys[i], key) == 0) break;
	if (i == c->num_keys) return 0;
	else return (void*) c->pointers[i];
}

int bptn_cut(int length) {
	if (length % 2 == 0) return length / 2;
	else return length / 2 + 1;
}

struct bptn* bptn_create_node() {
	struct bptn* new_node;
	new_node = malloc(sizeof(struct bptn));
	if (new_node == 0) return 0;
	new_node->is_leaf = 0;
	new_node->num_keys = 0;
	new_node->parent = 0;
	new_node->next = 0;
	new_node->changed = 1;
	return new_node;
}

struct bptn* bptn_create_node_leaf() {
	struct bptn* leaf = bptn_create_node();
	leaf->is_leaf = 1;
	return leaf;
}

int bptn_get_left_index(struct bptn* parent, struct bptn* left) {
	int left_index = 0;
	while (left_index <= parent->num_keys && parent->pointers[left_index] != left)
		left_index++;
	return left_index;
}

struct bptn* bptn_insert_into_leaf(struct bptn* leaf, int* key, void* pointer, int (*compare)(void*, void*)) {
	int i, insertion_point = 0;
	while (insertion_point < leaf->num_keys && compare(leaf->keys[insertion_point], key) < 0)
		insertion_point++;
	for (i = leaf->num_keys; i > insertion_point; i--) {
		leaf->keys[i] = leaf->keys[i - 1];
		leaf->pointers[i] = leaf->pointers[i - 1];
	}
	leaf->keys[insertion_point] = key;
	leaf->pointers[insertion_point] = pointer;
	leaf->num_keys++;
	leaf->changed = 1;
	printf("bptn %d changed\n", *leaf->keys[0]);
	return leaf;
}

struct bptn* bptn_insert_into_leaf_after_splitting(struct bptn* root, struct bptn* leaf, int* key, void* pointer, int (*compare)(void*, void*)) {
	void* temp_keys[ORDER];
	void* temp_pointers[ORDER];
	int insertion_index, split, i, j;
	struct bptn* new_leaf = bptn_create_node_leaf();
	if (!new_leaf) return 0;
	insertion_index = 0;
	while (insertion_index < ORDER - 1 && compare(leaf->keys[insertion_index], key) < 0)
		insertion_index++;
	for (i = 0, j = 0; i < leaf->num_keys; i++, j++) {
		if (j == insertion_index) j++;
		temp_keys[j] = leaf->keys[i];
		temp_pointers[j] = leaf->pointers[i];
	}
	temp_keys[insertion_index] = key;
	temp_pointers[insertion_index] = pointer;
	leaf->num_keys = 0;
	split = bptn_cut(ORDER - 1);
	for (i = 0; i < split; i++) {
		leaf->pointers[i] = temp_pointers[i];
		leaf->keys[i] = temp_keys[i];
		leaf->num_keys++;
	}
	for (i = split, j = 0; i < ORDER; i++, j++) {
		new_leaf->pointers[j] = temp_pointers[i];
		new_leaf->keys[j] = temp_keys[i];
		new_leaf->num_keys++;
	}
	new_leaf->pointers[ORDER - 1] = leaf->pointers[ORDER - 1];
	leaf->pointers[ORDER - 1] = new_leaf;
	for (i = leaf->num_keys; i < ORDER - 1; i++)
		leaf->pointers[i] = 0;
	for (i = new_leaf->num_keys; i < ORDER - 1; i++)
		new_leaf->pointers[i] = 0;
	new_leaf->parent = leaf->parent;
	void* new_key = new_leaf->keys[0];
	leaf->changed = 1;
	printf("bptn %d changed\n", *new_leaf->keys[0]);
	new_leaf->changed = 1;
	printf("bptn %d changed\n", *new_leaf->keys[0]);
	return bptn_insert_into_parent(root, leaf, new_key, new_leaf);
}

struct bptn* bptn_insert_into_node(struct bptn* root, struct bptn* n, int left_index, int* key, struct bptn* right) {
	int i;
	for (i = n->num_keys; i > left_index; i--) {
		n->pointers[i + 1] = n->pointers[i];
		n->keys[i] = n->keys[i - 1];
	}
	n->pointers[left_index + 1] = right;
	n->keys[left_index] = key;
	n->num_keys++;
	n->changed = 1;
	printf("bptn %d changed\n", *n->keys[0]);
	right->changed = 1;
	printf("bptn %d changed\n", *right->keys[0]);
	return root;
}

struct bptn* bptn_insert_into_node_after_splitting(struct bptn* root, struct bptn* old_node, int left_index, int* key, struct bptn* right) {
	int i, j;
	void* temp_keys[ORDER];
	struct bptn* temp_pointers[ORDER + 1];
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
	int split = bptn_cut(ORDER);
	struct bptn* new_node = bptn_create_node();
	if (!new_node) return 0;
	old_node->num_keys = 0;
	for (i = 0; i < split - 1; i++) {
		old_node->pointers[i] = temp_pointers[i];
		old_node->keys[i] = temp_keys[i];
		old_node->num_keys++;
	}
	old_node->pointers[i] = temp_pointers[i];
	int* k_prime = temp_keys[split - 1];
	for (++i, j = 0; i < ORDER; i++, j++) {
		new_node->pointers[j] = temp_pointers[i];
		new_node->keys[j] = temp_keys[i];
		new_node->num_keys++;
	}
	new_node->pointers[j] = temp_pointers[i];
	new_node->parent = old_node->parent;
	for (i = 0; i <= new_node->num_keys; i++) {
		struct bptn* child = new_node->pointers[i];
		child->parent = new_node;
	}
	new_node->changed = 1;
	printf("bptn %d changed\n", *new_node->keys[0]);
	old_node->changed = 1;
	printf("bptn %d changed\n", *old_node->keys[0]);
	right->changed = 1;
	printf("bptn %d changed\n", *right->keys[0]);
	return bptn_insert_into_parent(root, old_node, k_prime, new_node);
}

struct bptn* bptn_insert_into_parent(struct bptn* root, struct bptn* left, int* key, struct bptn* right) {
	struct bptn* parent = left->parent;
	if (parent == 0) return bptn_insert_into_new_root(left, key, right);
	int left_index = bptn_get_left_index(parent, left);
	if (parent->num_keys < ORDER - 1) return bptn_insert_into_node(root, parent, left_index, key, right);
	return bptn_insert_into_node_after_splitting(root, parent, left_index, key, right);
}

struct bptn* bptn_insert_into_new_root(struct bptn* left, int* key, struct bptn* right) {
	struct bptn* root = bptn_create_node();
	if (!root) return 0;
	root->keys[0] = key;
	root->pointers[0] = left;
	root->pointers[1] = right;
	root->num_keys++;
	root->parent = 0;
	left->parent = root;
	right->parent = root;
	root->changed = 1;
	printf("bptn %d changed\n", *root->keys[0]);
	left->changed = 1;
	printf("bptn %d changed\n", *left->keys[0]);
	right->changed = 1;
	printf("bptn %d changed\n", *right->keys[0]);
	return root;
}

struct bptn* bptn_start_new_tree(int* key, void* pointer) {
	struct bptn* root = bptn_create_node_leaf();
	root->keys[0] = key;
	root->pointers[0] = pointer;
	root->pointers[ORDER - 1] = 0;
	root->parent = 0;
	root->num_keys++;
	root->changed = 1;
	printf("bptn %d changed\n", *root->keys[0]);
	return root;
}

struct bptn* bptn_insert(struct bptn* root, int* key, void* value, int (*compare)(void*, void*)) {
	if (bptn_find(root, key, compare) != 0) return root;
	if (root == 0) return bptn_start_new_tree(key, value);
	struct bptn* leaf = bptn_find_leaf(root, key, compare);
	if (leaf->num_keys < ORDER - 1) {
		leaf = bptn_insert_into_leaf(leaf, key, value, compare);
		return root;
	}
	return bptn_insert_into_leaf_after_splitting(root, leaf, key, value, compare);
}

int bptn_get_neighbor_index(struct bptn* n) {
	int i;
	for (i = 0; i <= n->parent->num_keys; i++)
		if (n->parent->pointers[i] == n) return i - 1;
	return -1;
}

struct bptn* bptn_remove_entry_from_node(struct bptn* n, int* key, struct bptn* pointer, unsigned char canFreeKey, int (*compare)(void*, void*), void (*freeKey)(void*), void (*freeValue)(void*)) {
	int j, i = 0;
	while (compare(n->keys[i], key) != 0)
		i++;
	void* pkey = n->keys[i];
	if (freeKey) {
		if (n->is_leaf) {
			unsigned char found_key = 0;
			struct bptn* parent = n->parent;
			while (parent && !found_key) {
				for (j = 0; j < parent->num_keys; j++) {
					int compareTo = compare(parent->keys[j], pkey);
					if (compareTo == 0) found_key = 1;
					if (compareTo >= 0) break;
				}
				parent = parent->parent;
			}
			if (!found_key) {
				freeKey(pkey);
			}
		} else {
			struct bptn* child = (struct bptn*) n->pointers[i + 1];
			if (child->is_leaf && (child->num_keys == 0 || compare(child->keys[0], key))) {
				freeKey(pkey);
			}
		}
	}
	for (++i; i < n->num_keys; i++)
		n->keys[i - 1] = n->keys[i];
	int num_pointers = n->is_leaf ? n->num_keys : n->num_keys + 1;
	i = 0;
	while (n->pointers[i] != pointer)
		i++;
	for (++i; i < num_pointers; i++)
		n->pointers[i - 1] = n->pointers[i];
	n->num_keys--;
	if (n->is_leaf) for (i = n->num_keys; i < ORDER - 1; i++)
		n->pointers[i] = 0;
	else for (i = n->num_keys + 1; i < ORDER; i++)
		n->pointers[i] = 0;
	n->changed = 1;
	printf("bptn %d changed\n", *n->keys[0]);
	return n;
}

struct bptn* bptn_adjust_root(struct bptn* root) {
	struct bptn* new_root;
	if (root->num_keys > 0) return root;
	if (!root->is_leaf) {
		new_root = root->pointers[0];
		new_root->parent = 0;
		new_root->changed = 1;
		printf("bptn %d changed\n", *new_root->keys[0]);
	} else new_root = 0;
	free(root);
	return new_root;
}

struct bptn* bptn_coalesce_nodes(struct bptn* root, struct bptn* n, struct bptn* neighbor, int neighbor_index, int* k_prime, unsigned char canFreeKey, int (*compare)(void*, void*), void (*freeKey)(void*), void (*freeValue)(void*)) {
	int i, j;
	struct bptn* tmp;
	if (neighbor_index == -1) {
		tmp = n;
		n = neighbor;
		neighbor = tmp;
	}
	int neighbor_insertion_index = neighbor->num_keys;
	if (!n->is_leaf) {
		neighbor->keys[neighbor_insertion_index] = k_prime;
		neighbor->num_keys++;
		int n_end = n->num_keys;
		for (i = neighbor_insertion_index + 1, j = 0; j < n_end; i++, j++) {
			neighbor->keys[i] = n->keys[j];
			neighbor->pointers[i] = n->pointers[j];
			neighbor->num_keys++;
			n->num_keys--;
		}
		neighbor->pointers[i] = n->pointers[j];
		for (i = 0; i < neighbor->num_keys + 1; i++) {
			tmp = (struct bptn*) neighbor->pointers[i];
			tmp->parent = neighbor;
		}
	} else {
		for (i = neighbor_insertion_index, j = 0; j < n->num_keys; i++, j++) {
			neighbor->keys[i] = n->keys[j];
			neighbor->pointers[i] = n->pointers[j];
			neighbor->num_keys++;
		}
		neighbor->pointers[ORDER - 1] = n->pointers[ORDER - 1];
	}
	root = bptn_remove_entry(root, n->parent, k_prime, n, 0, compare, freeKey, freeValue);
	free(n);
	n->changed = 1;
	printf("bptn %d changed\n", *n->keys[0]);
	neighbor->changed = 1;
	printf("bptn %d changed\n", *neighbor->keys[0]);
	root->changed = 1;
	printf("bptn %d changed\n", *root->keys[0]);
	return root;
}

struct bptn* bptn_redistribute_nodes(struct bptn* root, struct bptn* n, struct bptn* neighbor, int neighbor_index, int k_prime_index, int* k_prime) {
	int i;
	if (neighbor_index != -1) {
		if (!n->is_leaf) n->pointers[n->num_keys + 1] = n->pointers[n->num_keys];
		for (i = n->num_keys; i > 0; i--) {
			n->keys[i] = n->keys[i - 1];
			n->pointers[i] = n->pointers[i - 1];
		}
		if (!n->is_leaf) {
			n->pointers[0] = neighbor->pointers[neighbor->num_keys];
			struct bptn* tmp = (struct bptn*) n->pointers[0];
			tmp->parent = n;
			neighbor->pointers[neighbor->num_keys] = 0;
			n->keys[0] = k_prime;
			n->parent->keys[k_prime_index] = neighbor->keys[neighbor->num_keys - 1];
		} else {
			n->pointers[0] = neighbor->pointers[neighbor->num_keys - 1];
			neighbor->pointers[neighbor->num_keys - 1] = 0;
			n->keys[0] = neighbor->keys[neighbor->num_keys - 1];
			n->parent->keys[k_prime_index] = n->keys[0];
		}
	} else {
		if (n->is_leaf) {
			n->keys[n->num_keys] = neighbor->keys[0];
			n->pointers[n->num_keys] = neighbor->pointers[0];
			n->parent->keys[k_prime_index] = neighbor->keys[1];
		} else {
			n->keys[n->num_keys] = k_prime;
			n->pointers[n->num_keys + 1] = neighbor->pointers[0];
			struct bptn* tmp = (struct bptn*) n->pointers[n->num_keys + 1];
			tmp->parent = n;
			n->parent->keys[k_prime_index] = neighbor->keys[0];
		}
		for (i = 0; i < neighbor->num_keys - 1; i++) {
			neighbor->keys[i] = neighbor->keys[i + 1];
			neighbor->pointers[i] = neighbor->pointers[i + 1];
		}
		if (!n->is_leaf) neighbor->pointers[i] = neighbor->pointers[i + 1];
	}
	n->num_keys++;
	neighbor->num_keys--;
	n->changed = 1;
	printf("bptn %d changed\n", *n->keys[0]);
	neighbor->changed = 1;
	printf("bptn %d changed\n", *neighbor->keys[0]);
	return root;
}

struct bptn* bptn_remove_entry(struct bptn* root, struct bptn* n, int* key, void * pointer, unsigned char canFreeKey, int (*compare)(void*, void*), void (*freeKey)(void*), void (*freeValue)(void*)) {
	n = bptn_remove_entry_from_node(n, key, pointer, canFreeKey, compare, freeKey, freeValue);
	if (n == root) return bptn_adjust_root(root);
	int min_keys = n->is_leaf ? bptn_cut(ORDER - 1) : bptn_cut(ORDER) - 1;
	if (n->num_keys >= min_keys) return root;
	int neighbor_index = bptn_get_neighbor_index(n);
	int k_prime_index = neighbor_index == -1 ? 0 : neighbor_index;
	int* k_prime = n->parent->keys[k_prime_index];
	struct bptn* neighbor =
	        neighbor_index == -1 ? n->parent->pointers[1] : n->parent->pointers[neighbor_index];
	int capacity = n->is_leaf ? ORDER : ORDER - 1;
	if (neighbor->num_keys + n->num_keys < capacity) return bptn_coalesce_nodes(root, n, neighbor, neighbor_index, k_prime, canFreeKey, compare, freeKey, freeValue);
	else return bptn_redistribute_nodes(root, n, neighbor, neighbor_index, k_prime_index, k_prime);
}

struct bptn* bptn_remove(struct bptn* root, int* key, int (*compare)(void*, void*), void (*freeKey)(void*), void (*freeValue)(void*)) {
	void* value = bptn_find(root, key, compare);
	struct bptn* key_leaf = bptn_find_leaf(root, key, compare);
	if (value && key_leaf) {
		root = bptn_remove_entry(root, key_leaf, key, value, 1, compare, freeKey, freeValue);
		if (freeValue) freeValue(value);
	}
	return root;
}

void bptn_clear_changed(struct bptn* root) {
	root->changed = 0;
	if (!root->is_leaf) {
		int i;
		for (i = 0; i <= root->num_keys; i++) {
			bptn_clear_changed((struct bptn*) root->pointers[i]);
		}
	}
}

void bptn_free(struct bptn* root) {
	int i;
	if (root->is_leaf) for (i = 0; i < root->num_keys; i++)
		free(root->pointers[i]);
	else for (i = 0; i < root->num_keys + 1; i++)
		bptn_free(root->pointers[i]);
	free(root);
}

struct bpt* bpt_create(int (*compare)(void*, void*), void (*freeKey)(void*), void (*freeValue)(void*)) {
	struct bpt* self = (struct bpt*) malloc(sizeof(struct bpt));
	self->root = 0;
	self->size = 0;
	self->changed = 1;
	self->compare = compare;
	self->freeKey = freeKey;
	self->freeValue = freeValue;
	printf("bpt changed\n");
	return self;
}

void bpt_free(struct bpt* self) {
	if (self->root) bptn_free(self->root);
	free(self);
}

void* bpt_find(struct bpt* self, int* key) {
	return bptn_find(self->root, key, self->compare);
}

unsigned char bpt_insert(struct bpt* self, int* key, void* value) {
	struct bptn* root = bptn_insert(self->root, key, value, self->compare);
	if (!root) return 1;
	self->root = root;
	self->size++;
	self->changed = 1;
	printf("bpt changed\n");
	return 0;
}

unsigned char bpt_remove(struct bpt* self, int* key) {
	struct bptn* root = bptn_remove(self->root, key, self->compare, self->freeKey, self->freeValue);
	if (self->size > 1 && !root) return 1;
	self->root = root;
	self->size--;
	self->changed = 1;
	printf("bpt changed\n");
	return 0;
}

void bpt_print(struct bpt* self) {
	print_tree(self->root);
}

void bpt_clear_changed(struct bpt* self) {
	if (self->root) bptn_clear_changed(self->root);
}
