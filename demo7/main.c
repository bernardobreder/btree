#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "binary.h"
#include "btree.h"
#include "kbtree.h"
#include "obtree.h"

unsigned long seq() {
	static unsigned long i = 0;
	return ++i;
}

//__KB_TREE_T(my)
//__KB_INIT(my, int)

int main(void) {
	{
		BTREE tree = btree_Create(1, strcmp);
		btree_Insert(tree, "a");
		btree_Insert(tree, "b");
		btree_Insert(tree, "c");
		btree_Insert(tree, "d");
		btree_Insert(tree, "e");
		btree_Search(tree, "a", 0);
		btree_Search(tree, "b", 0);
		btree_Search(tree, "c", 0);
		btree_Search(tree, "d", 0);
		btree_Search(tree, "e", 0);
		if (tree) {
			return 0;
		}
	}
	{
		struct b_btree_t* self = b_btree_new(0, 1, strcmp, seq, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		b_btree_add(self, strdup("a"), strdup("a"));
		b_btree_add(self, strdup("b"), strdup("b"));
		b_btree_add(self, strdup("c"), strdup("c"));
		b_btree_add(self, strdup("d"), strdup("d"));
		b_btree_add(self, strdup("e"), strdup("e"));
		b_btree_add(self, strdup("f"), strdup("f"));
	}
	{
		struct b_binary_tree_t* self = b_binary_tree_new(0, strcmp, 0, free, free, free);
		b_binary_tree_set(self, 0, strdup("c"), strdup("c"));
		b_binary_tree_set(self, 0, strdup("k"), strdup("k"));
		b_binary_tree_set(self, 0, strdup("j"), strdup("j"));
		b_binary_tree_set(self, 0, strdup("a"), strdup("a"));
		b_binary_tree_set(self, 0, strdup("i"), strdup("i"));
		b_binary_tree_set(self, 0, strdup("n"), strdup("n"));
		b_binary_tree_set(self, 0, strdup("f"), strdup("f"));
		b_binary_tree_set(self, 0, strdup("o"), strdup("o"));
		b_binary_tree_set(self, 0, strdup("g"), strdup("g"));
		b_binary_tree_set(self, 0, strdup("m"), strdup("m"));
		b_binary_tree_set(self, 0, strdup("d"), strdup("d"));
		b_binary_tree_set(self, 0, strdup("h"), strdup("h"));
		b_binary_tree_set(self, 0, strdup("b"), strdup("b"));
		b_binary_tree_set(self, 0, strdup("l"), strdup("l"));
		b_binary_tree_set(self, 0, strdup("e"), strdup("e"));
		assert(strcmp("a", b_binary_tree_get(self, ("a"))) == 0);
		assert(strcmp("b", b_binary_tree_get(self, ("b"))) == 0);
		assert(strcmp("c", b_binary_tree_get(self, ("c"))) == 0);
		assert(strcmp("d", b_binary_tree_get(self, ("d"))) == 0);
		assert(strcmp("e", b_binary_tree_get(self, ("e"))) == 0);
		assert(strcmp("f", b_binary_tree_get(self, ("f"))) == 0);
		assert(strcmp("g", b_binary_tree_get(self, ("g"))) == 0);
		assert(strcmp("h", b_binary_tree_get(self, ("h"))) == 0);
		assert(strcmp("i", b_binary_tree_get(self, ("i"))) == 0);
		assert(strcmp("j", b_binary_tree_get(self, ("j"))) == 0);
		assert(strcmp("k", b_binary_tree_get(self, ("k"))) == 0);
		assert(strcmp("l", b_binary_tree_get(self, ("l"))) == 0);
		assert(strcmp("m", b_binary_tree_get(self, ("m"))) == 0);
		assert(strcmp("n", b_binary_tree_get(self, ("n"))) == 0);
		assert(strcmp("o", b_binary_tree_get(self, ("o"))) == 0);
		b_binary_tree_del(self, "a");
		b_binary_tree_del(self, "b");
		b_binary_tree_del(self, "c");
		b_binary_tree_del(self, "d");
		b_binary_tree_del(self, "e");
		b_binary_tree_del(self, "f");
		b_binary_tree_del(self, "g");
		b_binary_tree_del(self, "h");
		b_binary_tree_del(self, "i");
		b_binary_tree_del(self, "j");
		b_binary_tree_del(self, "k");
		b_binary_tree_del(self, "l");
		b_binary_tree_del(self, "m");
		b_binary_tree_del(self, "n");
		b_binary_tree_del(self, "o");
		b_binary_tree_free(self);
	}
	return EXIT_SUCCESS;
}
