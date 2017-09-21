/*
 * btree.h
 *
 *  Created on: 18/08/2014
 *      Author: bernardobreder_local
 */

#ifndef BTREE_H_
#define BTREE_H_

#define BTREE_ORDER 32

struct btree_node_t {
	void* pointers[BTREE_ORDER];
    unsigned int pointerIds[BTREE_ORDER];
	void* keys[BTREE_ORDER-1];
	struct btree_node_t* parent;
	unsigned char is_leaf;
	int num_keys;
	unsigned char changed;
};

struct btree_t {
	struct btree_node_t *root;
	unsigned char changed;
	int sequence;
	int (*compare)(void*, void*);
	void (*freeKey)(void*);
	void (*freeValue)(void*);
    void* (*read)(unsigned char* bytes, unsigned long size);
    unsigned char* (*write)(void* data, int* size);
};

// int btree_find_range(struct btree_t* self, void* key_start, void* key_end, void* returned_keys[], void* returned_pointers[]);

void* btree_find(struct btree_t* self, void* key);

void btree_clean_changed(struct btree_node_t* root);

unsigned char btree_insert(struct btree_t *self, void* key, void* value);

unsigned char btree_delete(struct btree_t *self, void* key);

void btree_free(struct btree_t *self);

struct btree_t* btree_new(int (*compare)(void*, void*), void (*freeKey)(void*), void (*freeValue)(void*));

#endif /* BTREE_H_ */
