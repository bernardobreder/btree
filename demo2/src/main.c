#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <assert.h>
#include "btree.h"
#include "bpt.h"

int k1[2] = { 1, 3 };
int k2[2] = { 4, 6 };
int k3[2] = { 7, 9 };
int k4[2] = { 10, 12 };
int k5[2] = { 13, 15 };
int v1 = 2;
int v2 = 5;
int v3 = 8;
int v4 = 11;
int v5 = 14;

static int* int_new(int value) {
	int* self = (int*) malloc(sizeof(int));
	*self = value;
	return self;
}

static int int2_compare(void* a, void* b) {
	int* va = (int*) a;
	int* vb = (int*) b;
	if (va[0] != vb[0]) {
		return va[0] - vb[0];
	}
	if (va[1] != vb[1]) {
		return va[1] - vb[1];
	}
	return 0;
}

static int int_compare(void* a, void* b) {
	int* va = (int*) a;
	int* vb = (int*) b;
	return va[0] - vb[0];
}

static void rand_array(int* array, int length) {
	int n;
	int set[length];
	for (n = 1; n <= length; n++) {
		set[n - 1] = n;
	}
	for (n = 0; n < length; n++) {
		int index = rand() % (length - n);
		array[n] = set[index];
		set[index] = set[length - n - 1];
	}
}

int main(void) {
//	setbuf(stdout, 0);
	{
		clock_t time = clock();
		{
			int n, o, nmax = 20;
			int array[nmax];
			rand_array(array, nmax);
			for (o = 0; o < 1; o++) {
				printf("m = %d\n", o);
				struct bpt* tree = bpt_create(int_compare, free, free);
				for (n = 0; n < nmax; n++) {
					int key = array[n];
					printf("Inserting %d\n", key);
					assert(!bpt_insert(tree, int_new(key), int_new(key)));
					printf("Commit\n");
				}
				for (n = 0; n < nmax; n++) {
					int key = array[n];
					assert(key == *(int*) bpt_find(tree, &key));
				}
				bpt_clear_changed(tree);
				bpt_print(tree);
				for (n = 0; n < nmax; n++) {
					int key = array[n];
					assert(key == *(int*) bpt_find(tree, &key));
					printf("Removing %d\n", key);
					assert(!bpt_remove(tree, &key));
					assert(!bpt_find(tree, &key));
					bpt_print(tree);
					bpt_clear_changed(tree);
					printf("Commit\n");
				}
				bpt_free(tree);
			}
		}
		time = clock() - time;
		printf("%ld", time);
	}
//	printf("Add Random Many Test BPTree\n");
//	{
//		int n, nmax = 1024;
//		int array[nmax];
//		rand_array(array, nmax);
//		struct btree_t* tree = btree_new(int_compare, free, free);
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			if (value == 23) {
//				printf("debug Inserting %d\n", value);
//			}
//			printf("Inserting %d\n", value);
//			assert(btree_insert(tree, int_new(value), int_new(value)));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			assert(value == *(int* )btree_find(tree, &value));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			if (n == 471) {
//				value = array[n];
//			}
//			printf("Deleting %d\n", value);
//			assert(btree_delete(tree, &value));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			assert(!btree_find(tree, &value));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			assert(btree_insert(tree, int_new(value), int_new(value)));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			assert(value == *(int* )btree_find(tree, &value));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			assert(btree_delete(tree, &value));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			assert(!btree_find(tree, &value));
//		}
//		btree_free(tree);
//	}
//	printf("Basic Test\n");
//	{
//		struct btree_t* tree = btree_new(int2_compare, 0, 0);
//		{
//			assert(btree_insert(tree, k1, &v1));
//			assert(&v1 == btree_find(tree, k1));
//			assert(!btree_find(tree, k2));
//			assert(!btree_find(tree, k3));
//			assert(!btree_find(tree, k4));
//			assert(!btree_find(tree, k5));
//		}
//		{
//			assert(btree_insert(tree, k2, &v2));
//			assert(&v1 == btree_find(tree, k1));
//			assert(&v2 == btree_find(tree, k2));
//			assert(!btree_find(tree, k3));
//			assert(!btree_find(tree, k4));
//			assert(!btree_find(tree, k5));
//		}
//		{
//			assert(btree_insert(tree, k3, &v3));
//			assert(&v1 == btree_find(tree, k1));
//			assert(&v2 == btree_find(tree, k2));
//			assert(&v3 == btree_find(tree, k3));
//			assert(!btree_find(tree, k4));
//			assert(!btree_find(tree, k5));
//		}
//		{
//			assert(btree_insert(tree, k4, &v4));
//			assert(&v1 == btree_find(tree, k1));
//			assert(&v2 == btree_find(tree, k2));
//			assert(&v3 == btree_find(tree, k3));
//			assert(&v4 == btree_find(tree, k4));
//			assert(!btree_find(tree, k5));
//		}
//		{
//			assert(btree_insert(tree, k5, &v5));
//			assert(&v1 == btree_find(tree, k1));
//			assert(&v2 == btree_find(tree, k2));
//			assert(&v3 == btree_find(tree, k3));
//			assert(&v4 == btree_find(tree, k4));
//			assert(&v5 == btree_find(tree, k5));
//		}
//		{
//			assert(btree_delete(tree, k1));
//			assert(!btree_find(tree, k1));
//			assert(&v2 == btree_find(tree, k2));
//			assert(&v3 == btree_find(tree, k3));
//			assert(&v4 == btree_find(tree, k4));
//			assert(&v5 == btree_find(tree, k5));
//		}
//		{
//			assert(btree_delete(tree, k2));
//			assert(!btree_find(tree, k1));
//			assert(!btree_find(tree, k2));
//			assert(&v3 == btree_find(tree, k3));
//			assert(&v4 == btree_find(tree, k4));
//			assert(&v5 == btree_find(tree, k5));
//		}
//		{
//			assert(btree_delete(tree, k3));
//			assert(!btree_find(tree, k1));
//			assert(!btree_find(tree, k2));
//			assert(!btree_find(tree, k3));
//			assert(&v4 == btree_find(tree, k4));
//			assert(&v5 == btree_find(tree, k5));
//		}
//		{
//			assert(btree_delete(tree, k4));
//			assert(!btree_find(tree, k1));
//			assert(!btree_find(tree, k2));
//			assert(!btree_find(tree, k3));
//			assert(!btree_find(tree, k4));
//			assert(&v5 == btree_find(tree, k5));
//		}
//		{
//			assert(btree_delete(tree, k5));
//			assert(!btree_find(tree, k1));
//			assert(!btree_find(tree, k2));
//			assert(!btree_find(tree, k3));
//			assert(!btree_find(tree, k4));
//			assert(!btree_find(tree, k5));
//		}
//	}
//	printf("Add Many Test\n");
//	{
//		int n, nmax = 256 * 1024;
//		struct btree_t* tree = btree_new(int_compare, free, free);
//		for (n = 1; n <= nmax; n++) {
//			assert(btree_insert(tree, int_new(n), int_new(n)));
//		}
//		for (n = 1; n <= nmax; n++) {
//			assert(n == *(int* )btree_find(tree, &n));
//		}
//		for (n = 1; n <= nmax; n++) {
//			assert(btree_delete(tree, &n));
//		}
//		for (n = 1; n <= nmax; n++) {
//			assert(!btree_find(tree, &n));
//		}
//		for (n = 1; n <= nmax; n++) {
//			assert(btree_insert(tree, int_new(n), int_new(n)));
//		}
//		for (n = 1; n <= nmax; n++) {
//			assert(n == *(int* )btree_find(tree, &n));
//		}
//		for (n = 1; n <= nmax; n++) {
//			assert(btree_delete(tree, &n));
//		}
//		for (n = 1; n <= nmax; n++) {
//			assert(!btree_find(tree, &n));
//		}
//		btree_free(tree);
//	}
//	printf("Add Random Many Test\n");
//	{
//		int n, nmax = 256 * 1024;
//		int set[nmax], array[nmax];
//		for (n = 1; n <= nmax; n++) {
//			set[n - 1] = n;
//		}
//		for (n = 0; n < nmax; n++) {
//			int index = rand() % (nmax - n);
//			array[n] = set[index];
//			set[index] = set[nmax - n - 1];
//		}
//		struct btree_t* tree = btree_new(int_compare, free, free);
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			assert(btree_insert(tree, int_new(value), int_new(value)));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			assert(value == *(int* )btree_find(tree, &value));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			if (n == 471) {
//				value = array[n];
//			}
//			assert(btree_delete(tree, &value));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			assert(!btree_find(tree, &value));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			assert(btree_insert(tree, int_new(value), int_new(value)));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			assert(value == *(int* )btree_find(tree, &value));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			assert(btree_delete(tree, &value));
//		}
//		for (n = 0; n < nmax; n++) {
//			int value = array[n];
//			assert(!btree_find(tree, &value));
//		}
//		btree_free(tree);
//	}
//	printf("Memory Test\n");
//	{
//		int n;
//		for (;;) {
//			struct btree_t* tree = btree_new(int_compare, free, free);
//			btree_insert(tree, int_new(5), int_new(5));
//			btree_insert(tree, int_new(9), int_new(9));
//			btree_insert(tree, int_new(2), int_new(2));
//			n = 5;
//			btree_delete(tree, &n);
//			n = 9;
//			btree_delete(tree, &n);
//			n = 2;
//			btree_delete(tree, &n);
//			btree_free(tree);
//		}
//	}
//	{
//		int n, nmax = 1024;
//		for (;;) {
//			struct btree_t* tree = btree_new(int_compare, free, free);
//			for (n = 1; n <= nmax; n++) {
//				btree_insert(tree, int_new(n), int_new(n));
//			}
//			for (n = 1; n <= nmax; n++) {
//				btree_delete(tree, &n);
//			}
//			btree_free(tree);
//		}
//	}
//	printf("Stress Test\n");
//	{
//		int omax = 36, nmax = 256;
//		int o, n, m;
//		struct btree_t* tree = btree_new(int_compare, free, free);
//		for (n = 1; n <= nmax; n++) {
//			for (m = n; m <= nmax; m++) {
//				assert(!btree_find(tree, &m));
//			}
//			btree_insert(tree, int_new(n), int_new(n));
//			for (m = 1; m <= n; m++) {
//				assert(btree_find(tree, &m));
//			}
//		}
//		for (n = 1; n <= nmax; n++) {
//			btree_delete(tree, &n);
//		}
//		btree_free(tree);
//	}

	printf("Finished\n");
	return EXIT_SUCCESS;
}
