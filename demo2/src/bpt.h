#include <stdio.h>
#include <stdlib.h>

#define ORDER 3

struct bptn {
	void* pointers[ORDER];
	int* keys[ORDER - 1];
	struct bptn* parent;
	unsigned char is_leaf;
	int num_keys;
	struct bptn* next;
    unsigned char changed;
};

struct bpt {
	struct bptn* root;
	unsigned int size;
	unsigned char changed;
	int (*compare)(void*, void*);
	void (*freeKey)(void*);
	void (*freeValue)(void*);
};

int bptn_height(struct bptn* root);
void bptn_print(struct bptn* root);
void* bptn_find(struct bptn* root, int* key, int (*compare)(void*, void*));
struct bptn* bptn_insert(struct bptn* root, int* key, void* value, int (*compare)(void*, void*));
struct bptn* bptn_remove(struct bptn* root, int* key, int (*compare)(void*, void*), void (*freeKey)(void*), void (*freeValue)(void*));
void bptn_clear_changed(struct bptn* root);

struct bpt* bpt_create(int (*compare)(void*, void*), void (*freeKey)(void*), void (*freeValue)(void*));
void bpt_free(struct bpt* self);
void* bpt_find(struct bpt* self, int* key);
unsigned char bpt_insert(struct bpt* self, int* key, void* value);
unsigned char bpt_remove(struct bpt* self, int* key);
void bpt_print(struct bpt* self);
void bpt_clear_changed(struct bpt* self);
