/*
 * binary.h
 *
 *  Created on: 09/10/2013
 *      Author: bernardobreder
 */

#ifndef BINARY_H_
#define BINARY_H_

struct b_binary_tree_t {
	unsigned int size;
	struct b_binary_tree_node_t* root;
	int (*compare)(void*, void*);
	void* (*mallocFunc)(size_t);
	void (*selfFree)(void*);
	void (*keyFree)(void*);
	void (*valueFree)(void*);
};

struct b_binary_tree_node_t {
	void* key;
	void* value;
	struct b_binary_tree_node_t* parent;
	struct b_binary_tree_node_t* left;
	struct b_binary_tree_node_t* right;
};

struct b_binary_tree_t* b_binary_tree_new(struct b_binary_tree_t* self, int (*compare)(void*, void*), void* (*mallocFunc)(size_t), void (*selfFree)(void*), void (*keyFree)(void*),
		void (*valueFree)(void*));

void b_binary_tree_free(struct b_binary_tree_t* self);

unsigned int b_binary_tree_size(struct b_binary_tree_t* self);

void* b_binary_tree_get(struct b_binary_tree_t* self, void* key);

unsigned char b_binary_tree_set(struct b_binary_tree_t* self, struct b_binary_tree_node_t* node, void* key, void* value);

void b_binary_tree_del(struct b_binary_tree_t* self, void* key);

#endif /* BINARY_H_ */
