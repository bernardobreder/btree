//
//  Storage.m
//  iStorage
//
//  Created by Bernardo Breder on 16/08/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "BPTree.h"

#define ORDER 3

@interface BPTree () {
	@package
	BPTreeNode *_root;
	NSUInteger _rootId;
	unsigned char _changed;
	NSUInteger _sequence;
	NSUInteger _size;
	NSInteger (^_compare)(NSObject *left, NSObject* right);
}

@end

@interface BPTreeNode () {
	@package
	NSUInteger _sequence;
	NSObject *_pointers[ORDER];
	NSUInteger _pointersId[ORDER];
	NSObject *_ids[ORDER - 1];
	__weak BPTreeNode *_parent;
	unsigned char _isLeaf;
	unsigned char _changed;
	int _numIds;
}

- (instancetype)initNewTree:(NSUInteger)sequence id:(NSObject*)id pointer:(NSObject*)pointer;
- (instancetype)initIntoNewRoot:(NSUInteger)sequence left:(BPTreeNode*)left id:(NSObject*)id right:(BPTreeNode*)right;
- (BOOL)isChanged;
- (BPTreeNode*)adjustRoot;
- (NSInteger)getNeighborIndex;
- (NSInteger)getLeftIndex:(BPTreeNode*)left;

@end

@implementation BPTree

- (instancetype)init
{
    return [self initWithCompare:^NSInteger(NSObject *left, NSObject *right) {
		return [left hash] - [right hash];
	}];
}

- (instancetype)initWithCompare:(NSInteger (^)(NSObject *left, NSObject* right))compare
{
    if (!(self = [super init])) return nil;
	_compare = compare;
	_sequence = 1;
	_rootId = 0;
    return self;
}

- (bool)add:(NSObject*)id value:(NSObject*)value
{
	if ([self find:_root id:id]) return true;
	if (!_root) {
		_root = [[BPTreeNode alloc] initNewTree:_sequence++ id:id pointer:value];
		_rootId = _root->_sequence;
		_size++;
		return true;
	}
	BPTreeNode *leaf = [self findLeaf:_root id:id];
	if (leaf->_numIds < ORDER - 1) {
		[self insertIntoLeaf:leaf id:id pointer:value];
		_size++;
		return true;
	}
	_root = [self insertIntoLeafAfterSplitting:_root leaf:leaf id:id pointer:value];
	_rootId = _root->_sequence;
	_size++;
	return true;
}

- (NSObject*)value:(NSObject*)id
{
	return [self find:_root id:id];
}

- (bool)set:(NSObject*)id value:(NSObject*)value
{
	BPTreeNode *leaf = [self findLeaf:_root id:id];
	if (!leaf) return false;
	NSInteger i = [self findBinary:leaf id:id];
	if (i < 0) return false;
	leaf->_pointers[i] = value;
	return true;
}

- (bool)remove:(NSObject*)id
{
	BPTreeNode* root = _root;
	NSObject *value = [self find:_root id:id];
	BPTreeNode* leaf = [self findLeaf:_root id:id];
	if (value && leaf) {
		_root = [self removeEntry:_root node:leaf id:id pointer:value];
		_rootId = !_root ? 0 : _root->_sequence;
		_changed = _root != root || [_root isChanged];
		_size--;
		return true;
	}
	return false;
}

- (NSUInteger)count
{
	return _size;
}

- (void)enumerateObjectsUsingBlock:(void (^)(NSObject* id, BOOL *stop))block
{
}

- (NSObject*)find:(BPTreeNode*)node id:(NSObject*)id
{
	BPTreeNode *leaf = [self findLeaf:node id:id];
	if (!leaf) return 0;
	NSInteger i = [self findBinary:leaf id:id];
	if (i < 0) return nil;
	return (NSObject*) leaf->_pointers[i];
}

- (BPTreeNode*)findLeaf:(BPTreeNode*)node id:(NSObject*)id
{
	BPTreeNode *leaf = node;
	if (!leaf) return leaf;
	while (!leaf->_isLeaf) {
		NSInteger i = [self findLowerBinary:leaf id:id];
		leaf = (BPTreeNode*) leaf->_pointers[i];
	}
	return leaf;
}

- (NSInteger)findBinary:(BPTreeNode*)node id:(NSObject*)id
{
	NSInteger low = 0, hi = node->_numIds - 1;
	NSInteger mid = 0;
	while (low <= hi) {
		mid = (low + hi) >> 1;
		NSObject *midValue = node->_ids[mid];
		NSInteger compare = _compare(midValue, id);
		if (compare < 0) {
			low = ++mid;
		} else if (compare > 0) {
			hi = mid - 1;
		} else {
			return mid;
		}
	}
	return -(mid + 1);
}

- (NSInteger)findLowerBinary:(BPTreeNode*)node id:(NSObject*)id
{
	NSInteger low = 0, hi = node->_numIds - 1;
	NSInteger mid = 0;
	while (low <= hi) {
		mid = (low + hi) >> 1;
		NSObject *midValue = node->_ids[mid];
		NSInteger compare = _compare(midValue, id);
		if (compare < 0) {
			low = ++mid;
		} else if (compare > 0) {
			hi = mid - 1;
		} else {
			return mid + 1;
		}
	}
	mid = MAX(0, MIN(low, hi));
	for (; mid < node->_numIds ; mid++) {
		if (_compare(id, node->_ids[mid]) < 0) break;
	}
	return mid;
}

- (BPTreeNode*)insertIntoLeaf:(BPTreeNode*)leaf id:(NSObject*)id pointer:(NSObject*)pointer
{
	NSUInteger i, insertionPoint = 0;
	while (insertionPoint < leaf->_numIds && _compare(leaf->_ids[insertionPoint], id) < 0) {
		insertionPoint++;
	}
	for (i = leaf->_numIds; i > insertionPoint; i--) {
		leaf->_ids[i] = leaf->_ids[i - 1];
		leaf->_pointers[i] = leaf->_pointers[i - 1];
	}
	leaf->_ids[insertionPoint] = id;
	leaf->_pointers[insertionPoint] = pointer;
	leaf->_numIds++;
	return leaf;
}

- (BPTreeNode*)insertIntoLeafAfterSplitting:(BPTreeNode*)root leaf:(BPTreeNode*)leaf id:(NSObject*)id pointer:(NSObject*)pointer
{
	BPTreeNode* newLeaf = [[BPTreeNode alloc] init];
	if (!newLeaf) return nil;
	newLeaf->_isLeaf = true;
	NSObject *tempKeys[ORDER], *tempPointers[ORDER];
	int insertionIndex = 0;
	while (insertionIndex < ORDER - 1 && _compare(leaf->_ids[insertionIndex], id) < 0) {
		insertionIndex++;
	}
	for (NSUInteger i = 0, j = 0; i < leaf->_numIds; i++, j++) {
		if (j == insertionIndex) j++;
		tempKeys[j] = leaf->_ids[i];
		tempPointers[j] = leaf->_pointers[i];
	}
	tempKeys[insertionIndex] = id;
	tempPointers[insertionIndex] = (NSObject*) pointer;
	leaf->_numIds = 0;
	NSUInteger split = [self cutOrder:(ORDER - 1)];
	for (NSUInteger i = 0; i < split; i++) {
		leaf->_pointers[i] = tempPointers[i];
		leaf->_ids[i] = tempKeys[i];
		leaf->_numIds++;
	}
	for (NSUInteger i = split, j = 0; i < ORDER; i++, j++) {
		newLeaf->_pointers[j] = tempPointers[i];
		newLeaf->_ids[j] = tempKeys[i];
		newLeaf->_numIds++;
	}
	newLeaf->_pointers[ORDER - 1] = leaf->_pointers[ORDER - 1];
	leaf->_pointers[ORDER - 1] = (NSObject*) newLeaf;
	for (NSUInteger i = leaf->_numIds; i < ORDER - 1; i++) {
		leaf->_pointers[i] = NULL;
	}
	for (NSUInteger i = newLeaf->_numIds; i < ORDER - 1; i++) {
		newLeaf->_pointers[i] = NULL;
	}
	newLeaf->_parent = leaf->_parent;
	NSObject *new_key = newLeaf->_ids[0];
	return [self insertIntoParent:root left:leaf id:new_key right:newLeaf];
}

- (BPTreeNode*)insertIntoParent:(BPTreeNode*)root left:(BPTreeNode*)left id:(NSObject*)id right:(BPTreeNode*)right
{
	BPTreeNode* parent = left->_parent;
	if (!parent) return [[BPTreeNode alloc] initIntoNewRoot:_sequence++ left:left id:id right:right];
	NSUInteger left_index = [parent getLeftIndex:left];
	if (parent->_numIds < ORDER - 1) return [self insertIntoNode:root left:parent index:left_index id:id right:right];
	return [self insertIntoNodeAfterSplitting:root left:parent index:left_index id:id right:right];
}

- (BPTreeNode*)insertIntoNode:(BPTreeNode*)root left:(BPTreeNode*)left index:(NSUInteger)leftIndex id:(NSObject*)id right:(BPTreeNode*)right
{
	for (NSUInteger i = left->_numIds; i > leftIndex; i--) {
		left->_pointers[i + 1] = left->_pointers[i];
		left->_ids[i] = left->_ids[i - 1];
		left->_pointersId[i + 1] = ((BPTreeNode*) left->_pointers[i])->_sequence;
	}
	left->_pointers[leftIndex + 1] = right;
	left->_pointersId[leftIndex + 1] = right->_sequence;
	left->_ids[leftIndex] = id;
	left->_numIds++;
	return root;
}

- (BPTreeNode*)insertIntoNodeAfterSplitting:(BPTreeNode*)root left:(BPTreeNode*)oldNode index:(NSUInteger)leftIndex id:(NSObject*)id right:(BPTreeNode*)right
{
	NSUInteger i, j;
	NSObject *tempKeys[ORDER], *tempPointers[ORDER + 1];
	NSUInteger tempPointerIds[ORDER + 1];
	for (i = 0, j = 0; i < oldNode->_numIds + 1; i++, j++) {
		if (j == leftIndex + 1) j++;
		tempPointers[j] = oldNode->_pointers[i];
		tempPointerIds[j] = oldNode->_pointersId[i];
	}
	for (i = 0, j = 0; i < oldNode->_numIds; i++, j++) {
		if (j == leftIndex) j++;
		tempKeys[j] = oldNode->_ids[i];
	}
	tempPointers[leftIndex + 1] = right;
	tempPointerIds[leftIndex + 1] = right->_sequence;
	tempKeys[leftIndex] = id;
	
	NSUInteger split = [self cutOrder:ORDER];
	BPTreeNode *newNode = [[BPTreeNode alloc] init];
	if (!newNode) return nil;
	oldNode->_numIds = 0;
	for (i = 0; i < split - 1; i++) {
		oldNode->_pointers[i] = tempPointers[i];
		oldNode->_pointersId[i] = tempPointerIds[i];
		oldNode->_ids[i] = tempKeys[i];
		oldNode->_numIds++;
	}
	oldNode->_pointers[i] = tempPointers[i];
	oldNode->_pointersId[i] = tempPointerIds[i];
	NSObject *prime = tempKeys[split - 1];
	for (++i, j = 0; i < ORDER; i++, j++) {
		newNode->_pointers[j] = tempPointers[i];
		newNode->_pointersId[j] = tempPointerIds[i];
		newNode->_ids[j] = tempKeys[i];
		newNode->_numIds++;
	}
	newNode->_pointers[j] = tempPointers[i];
	newNode->_pointersId[j] = tempPointerIds[i];
	newNode->_parent = oldNode->_parent;
	for (i = 0; i <= newNode->_numIds; i++) {
		BPTreeNode *child = (BPTreeNode*) newNode->_pointers[i];
		child->_parent = newNode;
	}
	return [self insertIntoParent:root left:oldNode id:prime right:newNode];
}

- (NSUInteger)cutOrder:(NSUInteger)length
{
	return (length % 2 == 0) ? length / 2 : length / 2 + 1;
}

- (BPTreeNode*)removeEntry:(BPTreeNode*)root node:(BPTreeNode*)node id:(NSObject*)id pointer:(NSObject*)pointer
{
	node = [self removeEntryFromNode:node id:id pointer:pointer];
	if (node == root) return [root adjustRoot];
	NSUInteger minKeys = node->_isLeaf ? [self cutOrder:(ORDER - 1)] : [self cutOrder:ORDER] - 1;
	if (node->_numIds >= minKeys) return root;
	NSInteger neighbor_index = [node getNeighborIndex];
	NSInteger primeIndex = neighbor_index == -1 ? 0 : neighbor_index;
	NSObject *prime = node->_parent->_ids[primeIndex];
	BPTreeNode *neighbor = (BPTreeNode*) (neighbor_index == -1 ? node->_parent->_pointers[1] : node->_parent->_pointers[neighbor_index]);
	NSUInteger capacity = node->_isLeaf ? ORDER : ORDER - 1;
	if (neighbor->_numIds + node->_numIds < capacity) {
		return [self removeCoalesceNodes:root node:node neighbor:neighbor neighborIndex:neighbor_index prime:prime];
	} else {
		return [self removeRedistributeNodes:root node:node neighbor:neighbor neighborIndex:neighbor_index primeIndex:primeIndex prime:prime];
	}
}

- (BPTreeNode*)removeEntryFromNode:(BPTreeNode*)node id:(NSObject*)id pointer:(NSObject*)pointer
{
	int i = 0;
	while (_compare(node->_ids[i], id) != 0) {
		i++;
	}
	for (++i; i < node->_numIds; i++) {
		node->_ids[i - 1] = node->_ids[i];
	}
	int num_pointers = node->_isLeaf ? node->_numIds : node->_numIds + 1;
	i = 0;
	while (node->_pointers[i] != pointer)
		i++;
	for (++i; i < num_pointers; i++) {
		node->_pointers[i - 1] = node->_pointers[i];
		node->_pointersId[i - 1] = node->_pointersId[i];
	}
	node->_numIds--;
	if (node->_isLeaf) {
		for (i = node->_numIds; i < ORDER - 1; i++) {
			node->_pointers[i] = 0;
			node->_pointersId[i] = 0;
		}
	} else {
		for (i = node->_numIds + 1; i < ORDER; i++) {
			node->_pointers[i] = 0;
			node->_pointersId[i] = 0;
		}
	}
	node->_changed = 1;
	return node;
}

- (BPTreeNode*)removeCoalesceNodes:(BPTreeNode*)root node:(BPTreeNode*)node neighbor:(BPTreeNode*)neighbor neighborIndex:(NSInteger)neighborIndex prime:(NSObject*)prime
{
	int i, j, neighborInsertionIndex, endIndex;
	BPTreeNode* tmp;
	if (neighborIndex == -1) {
		tmp = node;
		node = neighbor;
		neighbor = tmp;
	}
	neighborInsertionIndex = neighbor->_numIds;
	if (!node->_isLeaf) {
		neighbor->_ids[neighborInsertionIndex] = prime;
		neighbor->_numIds++;
		endIndex = node->_numIds;
		for (i = neighborInsertionIndex + 1, j = 0; j < endIndex; i++, j++) {
			neighbor->_ids[i] = node->_ids[j];
			neighbor->_pointers[i] = node->_pointers[j];
			neighbor->_pointersId[i] = node->_pointersId[j];
			neighbor->_numIds++;
			node->_numIds--;
		}
		neighbor->_pointers[i] = node->_pointers[j];
		for (i = 0; i < neighbor->_numIds + 1; i++) {
			tmp = (BPTreeNode*) neighbor->_pointers[i];
			tmp->_parent = neighbor;
			tmp->_changed = 1;
		}
	} else {
		for (i = neighborInsertionIndex, j = 0; j < node->_numIds;
			 i++, j++) {
			neighbor->_ids[i] = node->_ids[j];
			neighbor->_pointers[i] = node->_pointers[j];
			neighbor->_pointersId[i] = node->_pointersId[j];
			neighbor->_numIds++;
		}
		neighbor->_pointers[ORDER - 1] = node->_pointers[ORDER - 1];
		neighbor->_pointersId[ORDER - 1] = node->_pointersId[ORDER - 1];
	}
	root = [self removeEntry:root node:node->_parent id:prime pointer:node];
	neighbor->_changed = 1;
	return root;
}

- (BPTreeNode*)removeRedistributeNodes:(BPTreeNode*)root node:(BPTreeNode*)node neighbor:(BPTreeNode*)neighbor neighborIndex:(NSInteger)neighborIndex primeIndex:(NSInteger)primeIndex prime:(NSObject*)k_prime
{
	int i;
	BPTreeNode* tmp;
	if (neighborIndex != -1) {
		if (!node->_isLeaf) node->_pointers[node->_numIds + 1] = node->_pointers[node->_numIds];
		for (i = node->_numIds; i > 0; i--) {
			node->_ids[i] = node->_ids[i - 1];
			node->_pointers[i] = node->_pointers[i - 1];
			node->_pointersId[i] = node->_pointersId[i - 1];
		}
		if (!node->_isLeaf) {
			node->_pointers[0] = neighbor->_pointers[neighbor->_numIds];
			node->_pointersId[0] = neighbor->_pointersId[neighbor->_numIds];
			tmp = (BPTreeNode*) node->_pointers[0];
			tmp->_parent = node;
			neighbor->_pointers[neighbor->_numIds] = nil;
			neighbor->_pointersId[neighbor->_numIds] = 0;
			node->_ids[0] = k_prime;
			node->_parent->_ids[primeIndex] = neighbor->_ids[neighbor->_numIds - 1];
		} else {
			node->_pointers[0] = neighbor->_pointers[neighbor->_numIds - 1];
			node->_pointersId[0] = neighbor->_pointersId[neighbor->_numIds - 1];
			neighbor->_pointers[neighbor->_numIds - 1] = nil;
			neighbor->_pointersId[neighbor->_numIds - 1] = 0;
			node->_ids[0] = neighbor->_ids[neighbor->_numIds - 1];
			node->_parent->_ids[primeIndex] = node->_ids[0];
		}
	} else {
		if (node->_isLeaf) {
			node->_ids[node->_numIds] = neighbor->_ids[0];
			node->_pointers[node->_numIds] = neighbor->_pointers[0];
			node->_pointersId[node->_numIds] = neighbor->_pointersId[0];
			node->_parent->_ids[primeIndex] = neighbor->_ids[1];
		} else {
			node->_ids[node->_numIds] = k_prime;
			node->_pointers[node->_numIds + 1] = neighbor->_pointers[0];
			node->_pointersId[node->_numIds + 1] = neighbor->_pointersId[0];
			tmp = (BPTreeNode*) node->_pointers[node->_numIds + 1];
			tmp->_parent = node;
			node->_parent->_ids[primeIndex] = neighbor->_ids[0];
		}
		for (i = 0; i < neighbor->_numIds - 1; i++) {
			neighbor->_ids[i] = neighbor->_ids[i + 1];
			neighbor->_pointers[i] = neighbor->_pointers[i + 1];
			neighbor->_pointersId[i] = neighbor->_pointersId[i + 1];
		}
		if (!node->_isLeaf) {
			neighbor->_pointers[i] = neighbor->_pointers[i + 1];
			neighbor->_pointersId[i] = neighbor->_pointersId[i + 1];
		}
	}
	node->_numIds++;
	neighbor->_numIds--;
	node->_changed = 1;
	neighbor->_changed = 1;
	return root;
}

@end

@implementation BPTreeNode

- (instancetype)init
{
	if (!(self = [super init])) return nil;
	_isLeaf = false;
	_numIds = 0;
	_parent = 0;
	_changed = 1;
    return self;
}

- (instancetype)initNewTree:(NSUInteger)sequence id:(NSObject*)id pointer:(NSObject*)pointer
{
	if (!(self = [self init])) return nil;
	_sequence = sequence;
	_isLeaf = true;
	_ids[0] = id;
	_pointers[0] = pointer;
	_pointers[ORDER - 1] = 0;
	_numIds++;
	return self;
}

- (instancetype)initIntoNewRoot:(NSUInteger)sequence left:(BPTreeNode*)left id:(NSObject*)id right:(BPTreeNode*)right
{
	if (!(self = [self init])) return nil;
	_sequence = sequence;
	_ids[0] = id;
	_pointers[0] = left;
	_pointersId[0] = left->_sequence;
	_pointers[1] = right;
	_pointersId[1] = right->_sequence;
	_numIds++;
	_parent = nil;
	left->_parent = self;
	right->_parent = self;
	return self;
}

- (void)cleanChange
{
	_changed = 0;
	if (!_isLeaf) {
		for (NSUInteger n = 0; n < _numIds + 1; n++) {
			[(BPTreeNode*) _pointers[n] cleanChange];
		}
	}
}

- (BOOL)isChanged
{
	if (_changed) return 1;
	if (!_isLeaf) {
		for (NSUInteger n = 0; n < _numIds + 1; n++) {
			BPTreeNode *pointer = (BPTreeNode*)_pointers[n];
			if ([pointer isChanged]) {
				return 1;
			}
		}
	}
	return 0;
}

- (BPTreeNode*)adjustRoot
{
	BPTreeNode* newRoot;
	if (_numIds > 0) return self;
	if (!_isLeaf) {
		newRoot = (BPTreeNode*) _pointers[0];
		newRoot->_parent = 0;
		newRoot->_changed = 1;
	} else newRoot = 0;
	return newRoot;
}

- (NSInteger)getNeighborIndex
{
	for (NSUInteger i = 0; i <= _parent->_numIds; i++) {
		if (_parent->_pointers[i] == self) return i - 1;
	}
	return -1;
}

- (NSInteger)getLeftIndex:(BPTreeNode*)left
{
	NSInteger leftIndex = 0;
	while (leftIndex <= _numIds && _pointers[leftIndex] != left) {
		leftIndex++;
	}
	return leftIndex;
}

@end