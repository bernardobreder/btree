
//
//  BTree.m
//  iSql
//
//  Created by Bernardo Breder on 16/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "BTree.h"

@interface BTreeNode () {
    
@public
    
    uint64_t _id;
    
    uint64_t _keys[2 * BTREE_ORDER - 1];

    NSObject *_values[2 * BTREE_ORDER - 1];

    uint64_t _childrenIds[2 * BTREE_ORDER];
    
    BTreeNode *_childrenNode[2 * BTREE_ORDER];
    
    uint8_t _length;
    
    bool _leaf;

}

- (BTreeNode*)search:(uint64_t)key;

- (void)splitChild:(int8_t)index atNode:(BTreeNode*)y;

- (void)insertNonFull:(uint64_t)key value:(NSObject*)value;

- (void)remove:(uint64_t)key;

- (void)clear;

- (void)traverse:(NSMutableString*)string;

@end

@interface BTree () {
    
@public
    
    BTreeNode *_root;
    
}

@end

@implementation BTree

- (id)init
{
    if (!(self = [super init])) return nil;
    BTreeNode *root = [[BTreeNode alloc] init];
    root->_leaf = false;
    root->_length = 0;
    return self;
}

- (void)dealloc
{
    NSLog(@"Free");
}

- (void)add:(uint64_t)key value:(NSObject*)value
{
	if (_root == NULL) {
		_root = [[BTreeNode alloc] init];
        _root->_leaf = true;
		_root->_keys[0] = key;
		_root->_values[0] = value;
		_root->_length = 1;
	} else {
		if (_root->_length == 2 * BTREE_ORDER - 1) {
			BTreeNode *s = [[BTreeNode alloc] init];
            s->_childrenIds[0] = _root->_id;
			s->_childrenNode[0] = _root;
			[s splitChild:0 atNode:_root];
			int8_t i = 0;
			if (s->_keys[0] < key) {
				i++;
            }
			[s->_childrenNode[i] insertNonFull:key value:value];
			_root = s;
		} else
			[_root insertNonFull:key value:value];
	}
}

- (void)remove:(uint64_t)key
{
	if (!_root) {
		return;
	}
	[_root remove:key];
	if (_root->_length == 0) {
		BTreeNode *tmp = _root;
		if (_root->_leaf) {
			_root = nil;
        } else {
			_root = _root->_childrenNode[0];
        }
        [tmp clear];
	}
	return;
}

- (NSString*)traverse
{
    NSMutableString *string = [[NSMutableString alloc] init];
    if (_root) {
        [_root traverse:string];
    }
    return string;
}

- (BTreeNode*)search:(uint64_t)k
{
    return _root ? [_root search:k] : nil;
}

@end

@implementation BTreeNode

- (id)init
{
    if (!(self = [super init])) return nil;
    _leaf = false;
    return self;
}

- (void)splitChild:(int8_t)index atNode:(BTreeNode*)y
{
	BTreeNode *z = [[BTreeNode alloc] init];
    z->_leaf = y->_leaf;
	z->_length = BTREE_ORDER - 1;
	for (int8_t j = 0; j < BTREE_ORDER - 1; j++) {
		z->_keys[j] = y->_keys[j + BTREE_ORDER];
		z->_values[j] = y->_values[j + BTREE_ORDER];
    }
	if (!y->_leaf) {
		for (int8_t j = 0; j < BTREE_ORDER; j++) {
			z->_childrenNode[j] = y->_childrenNode[j + BTREE_ORDER];
            z->_childrenIds[j] = y->_childrenIds[j + BTREE_ORDER];
        }
	}
    int8_t len = y->_length;
	y->_length = BTREE_ORDER - 1;
	for (int8_t j = _length; j >= index + 1; j--) {
		_childrenNode[j + 1] = _childrenNode[j];
        _childrenIds[j + 1] = _childrenIds[j];
    }
	_childrenNode[index + 1] = z;
    _childrenIds[index + 1] = z->_id;
	for (int8_t j = _length - 1; j >= index; j--) {
		_keys[j + 1] = _keys[j];
		_values[j + 1] = _values[j];
    }
	_keys[index] = y->_keys[BTREE_ORDER - 1];
	_values[index] = y->_values[BTREE_ORDER - 1];
	_length++;
    for (int8_t j = BTREE_ORDER - 1; j < len; j++) {
        y->_keys[j] = 0;
        y->_values[j] = nil;
        y->_childrenIds[j+1] = 0;
        y->_childrenNode[j+1] = nil;
    }
}

- (void)insertNonFull:(uint64_t)key value:(NSObject*)value
{
	int8_t i = _length - 1;
	if (_leaf) {
		while (i >= 0 && _keys[i] > key) {
			_keys[i + 1] = _keys[i];
			_values[i + 1] = _values[i];
			i--;
		}
		_keys[i + 1] = key;
		_values[i + 1] = value;
		_length++;
	} else {
		while (i >= 0 && _keys[i] > key) {
			i--;
        }
		if (_childrenNode[i + 1]->_length == 2 * BTREE_ORDER - 1) {
			[self splitChild:i + 1 atNode:_childrenNode[i + 1]];
			if (_keys[i + 1] < key) {
				i++;
            }
		}
		[_childrenNode[i + 1] insertNonFull:key value:value];
	}
}

- (BTreeNode*)search:(uint64_t)key
{
	int8_t i = 0;
	while (i < _length && key > _keys[i]) {
		i++;
    }
	if (_keys[i] == key) {
		return self;
    }
	if (_leaf) {
		return nil;
    }
	return [_childrenNode[i] search:key];
}

- (int8_t)findKey:(uint64_t)key
{
    int8_t idx = 0;
	while (idx < _length && _keys[idx] < key) {
		++idx;
    }
	return idx;
}

- (void)remove:(uint64_t)key
{
	int8_t idx = [self findKey:key];
	if (idx < _length && _keys[idx] == key) {
		if (_leaf) {
			[self removeFromLeaf:idx];
		} else {
			[self removeFromNonLeaf:idx];
        }
	} else {
		if (_leaf) {
			return;
		}
		bool flag = ((idx == _length) ? true : false);
		if (_childrenNode[idx]->_length < BTREE_ORDER) {
			[self fill:idx];
        }
		if (flag && idx > _length) {
			[_childrenNode[idx - 1] remove:key];
        } else {
			[_childrenNode[idx] remove:key];
        }
	}
}

- (void)removeFromLeaf:(int8_t)idx
{
	for (int8_t i = idx + 1; i < _length; ++i) {
		_keys[i - 1] = _keys[i];
        _values[i - 1] = _values[i];
    }
	_length--;
	return;
}

- (void)removeFromNonLeaf:(int8_t)idx
{
	uint64_t k = _keys[idx];
	if (_childrenNode[idx]->_length >= BTREE_ORDER) {
		BTreeNode *predNode = [self getPred:idx];
		_keys[idx] = predNode->_keys[predNode->_length - 1];
        _values[idx] = predNode->_values[predNode->_length - 1];
		[_childrenNode[idx] remove:_keys[idx]];
	} else if (_childrenNode[idx + 1]->_length >= BTREE_ORDER) {
		BTreeNode *succNode = [self getSucc:idx];
		_keys[idx] = succNode->_keys[0];
		_values[idx] = succNode->_values[0];
		[_childrenNode[idx + 1] remove:_keys[idx]];
	} else {
		[self merge:idx];
		[_childrenNode[idx] remove:k];
	}
}

- (BTreeNode*)getPred:(int8_t)idx
{
	BTreeNode *cur = _childrenNode[idx];
	while (!cur->_leaf) {
		cur = cur->_childrenNode[cur->_length];
    }
	return cur;
}

- (BTreeNode*)getSucc:(int8_t)idx
{
	BTreeNode *cur = _childrenNode[idx + 1];
	while (!cur->_leaf) {
		cur = cur->_childrenNode[0];
    }
	return cur;
}

- (void)fill:(int8_t)idx
{
	if (idx != 0 && _childrenNode[idx - 1]->_length >= BTREE_ORDER) {
		[self borrowFromPrev:idx];
    } else if (idx != _length && _childrenNode[idx + 1]->_length >= BTREE_ORDER) {
		[self borrowFromNext:idx];
	} else {
		if (idx != _length) {
			[self merge:idx];
		} else {
			[self merge:(idx - 1)];
        }
	}
}

- (void)borrowFromPrev:(int8_t)idx
{
	BTreeNode *child = _childrenNode[idx];
	BTreeNode *sibling = _childrenNode[idx - 1];
	for (int8_t i = child->_length - 1; i >= 0; --i)
		child->_keys[i + 1] = child->_keys[i];
	if (!child->_leaf) {
		for (int8_t i = child->_length; i >= 0; --i) {
			child->_childrenNode[i + 1] = child->_childrenNode[i];
        }
	}
	child->_keys[0] = _keys[idx - 1];
	if (!_leaf) {
		child->_childrenNode[0] = sibling->_childrenNode[sibling->_length];
    }
	_keys[idx - 1] = sibling->_keys[sibling->_length - 1];
	child->_length++;
	sibling->_length--;
}

- (void)borrowFromNext:(int8_t)idx
{
	BTreeNode *child = _childrenNode[idx];
	BTreeNode *sibling = _childrenNode[idx + 1];
	child->_keys[(child->_length)] = _keys[idx];
	if (!(child->_leaf)) {
		child->_childrenNode[(child->_length) + 1] = sibling->_childrenNode[0];
    }
	_keys[idx] = sibling->_keys[0];
	for (int8_t i = 1; i < sibling->_length; ++i) {
		sibling->_keys[i - 1] = sibling->_keys[i];
    }
	if (!sibling->_leaf) {
		for (int8_t i = 1; i <= sibling->_length; ++i) {
			sibling->_childrenNode[i - 1] = sibling->_childrenNode[i];
        }
	}
	child->_length++;
	sibling->_length--;
}

- (void)merge:(int8_t)idx
{
	BTreeNode *child = _childrenNode[idx];
	BTreeNode *sibling = _childrenNode[idx + 1];
	child->_keys[BTREE_ORDER - 1] = _keys[idx];
	for (int8_t i = 0; i < sibling->_length; ++i)
		child->_keys[i + BTREE_ORDER] = sibling->_keys[i];
	if (!child->_leaf) {
		for (int8_t i = 0; i <= sibling->_length; ++i)
			child->_childrenNode[i + BTREE_ORDER] = sibling->_childrenNode[i];
	}
	for (int8_t i = idx + 1; i < _length; ++i)
		_keys[i - 1] = _keys[i];
	for (int8_t i = idx + 2; i <= _length; ++i)
		_childrenNode[i - 1] = _childrenNode[i];
	child->_length += sibling->_length + 1;
	_length--;
	[sibling clear];
}

- (void)clear
{
    for (int8_t n = 0; n < 2 * BTREE_ORDER ; n++) {
        _childrenNode[n] = nil;
    }
}

- (void)traverse:(NSMutableString*)string
{
	int8_t i;
	for (i = 0; i < _length; i++) {
		if (!_leaf) {
			[_childrenNode[i] traverse:string];
        }
        [string appendString:[NSString stringWithFormat:@" %ld", (long)_keys[i]]];
	}
	if (!_leaf) {
		[_childrenNode[i] traverse:string];
    }
}

@end