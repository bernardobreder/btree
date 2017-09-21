/*
 * map.h
 *
 *  Created on: 18/08/2014
 *      Author: bernardobreder_local
 */

#ifndef MAP_H_
#define MAP_H_

#define MAP_ITEM_MAX 64
#define MAP_TYPE_INT_8 1
#define MAP_TYPE_INT_32 2
#define MAP_TYPE_INT_64 3
#define MAP_TYPE_CHAR_1 4
#define MAP_TYPE_CHAR_N 5

struct map_t {
    void* values;
};

struct map_info_entry_t {
    char *name;
    unsigned char type;
};

struct map_info_t {
    struct map_info_entry_t entrys[MAP_ITEM_MAX];
    unsigned int count;
};

struct map_info_t* map_info_new();

void map_info_free(struct map_info_t* self);

struct map_t* map_new(struct map_info_t* info);

void map_free(struct map_t* self);

void

#endif /* MAP_H_ */
