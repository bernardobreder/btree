/*
 * btree.h
 *
 *  Created on: 09/10/2013
 *      Author: bernardobreder
 */

#ifndef BTREE_H_
#define BTREE_H_

struct b_btree_t {
	unsigned int size;
	unsigned int half_max;
	struct b_btree_node_t* root;
	unsigned long rootId;
	int (*compare)(void*, void*);
	unsigned long (*sequence)();
	struct b_btree_t* (*readTree)();
	unsigned char (*writeTree)(struct b_btree_t*);
	unsigned char (*deleteTree)(struct b_btree_t*);
	struct b_btree_node_t* (*readNode)(unsigned long);
	unsigned char (*writeNode)(struct b_btree_node_t*);
	unsigned char (*deleteNode)(struct b_btree_node_t*);
	void* (*mallocFunc)(size_t);
	void (*selfFree)(void*);
	void (*keyFree)(void*);
	void (*valueFree)(void*);
};

struct b_btree_node_t {
	unsigned long id;
	unsigned int key_size;
	unsigned int children_size;
	char** keys;
	void** values;
	struct b_btree_node_t** children;
	unsigned long* childrenId;
	void* user_data;
};

struct b_btree_t* b_btree_new(struct b_btree_t* self, int half_max, int (*compare)(void*, void*), unsigned long (*sequence)(), struct b_btree_t* (*readTree)(),
		unsigned char (*writeTree)(struct b_btree_t*), unsigned char (*deleteTree)(struct b_btree_t*), struct b_btree_node_t* (*readNode)(unsigned long),
		unsigned char (*writeNode)(struct b_btree_node_t*), unsigned char (*deleteNode)(struct b_btree_node_t*), void* (*mallocFunc)(size_t), void (*selfFree)(void*), void (*keyFree)(void*),
		void (*valueFree)(void*));

unsigned char b_btree_add(struct b_btree_t* self, void* key, void* value);

#endif /* BINARY_H_ */
