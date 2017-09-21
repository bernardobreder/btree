//
//  NSTable.swift
//  BTree
//
//  Created by Bernardo Breder on 22/08/15.
//  Copyright (c) 2015 breder. All rights reserved.
//

import Foundation

let NSTableOrder: Int = 3

let NSTableOrderSum: Int = NSTableOrder + 1
let NSTableOrderSub: Int = NSTableOrder - 1

let NSTableOrderCutted: Int = (NSTableOrder % 2 == 0) ? NSTableOrder : NSTableOrder / 2 + 1

let NSTableOrderCuttedSub: Int = (NSTableOrderSub % 2 == 0) ? NSTableOrderSub : NSTableOrderSub / 2 + 1

let null: NSNull = NSNull()

class NSTable {
    
    var name: String
    
    var root: NSTableNode
    
    var size: Int = 0
    
    var changed: Bool = true
    
    init(name: String) {
        self.name = name
        self.root = NSTableNode()
    }
    
    func add(value: NSObject) -> Int {
        let key: Int = ++size
        let node : NSTableNode = findLeafNode(key)
        if node.size == NSTableOrderSub {
            root = addIntoLeafAfterSplitting(node, key: key, value: value)
        } else {
            addIntoLeaf(node, key: key, value: value)
        }
        return key
    }
    
    private func addIntoLeaf(node: NSTableNode, key: Int, value: NSObject) {
        var point = 0
        while point < node.size && node.keys[point] < key {
            point++
        }
        for var i: Int = node.size ; i > point ; i-- {
            node.keys[i] = node.keys[i-1]
            node.children[i] = node.children[i-1]
        }
        node.keys[point] = key
        node.children[point] = value
        node.size++
        node.changed = true
    }
    
    private func addIntoLeafAfterSplitting(node: NSTableNode, key: Int, value: NSObject) -> NSTableNode {
        var keys: [Int] = [Int](count: NSTableOrder, repeatedValue: 0)
        var children: [NSObject] = [NSObject](count: NSTableOrder, repeatedValue: null)
        let other: NSTableNode = NSTableNode()
        var index: Int = 0
        while index < NSTableOrderSub && node.keys[index] < key {
            index++
        }
        for var i: Int = 0, j: Int = 0 ; i < node.size ; i++, j++ {
            if j == index {
                j++
            }
            keys[j] = node.keys[i]
            children[j] = node.children[i]
        }
        keys[index] = key
        children[index] = value
        for var i: Int = 0 ; i < NSTableOrderCuttedSub ; i++ {
            node.keys[i] = keys[i]
            node.children[i] = children[i]
//            node.size++
        }
        node.size = NSTableOrderCuttedSub
        for var i: Int = NSTableOrderCuttedSub, j: Int = 0 ; i < NSTableOrder ; i++, j++ {
            other.keys[j] = keys[i]
            other.children[j] = children[i]
            other.size++
        }
        other.children[NSTableOrderSub] = node.children[NSTableOrderSub]
        node.children[NSTableOrderSub] = other
        for var i: Int = node.size ; i < NSTableOrderSub ; i++ {
            node.children[i] = null
        }
        for var i: Int = other.size ; i < NSTableOrderSub ; i++ {
            other.children[i] = null
        }
        other.parent = node.parent
        node.changed = true
        other.changed = true
        return addIntoParent(node, key: other.keys[0], right: other)
    }
    
    private func addIntoParent(left: NSTableNode, key: Int, right: NSTableNode) -> NSTableNode {
        if let parent: NSTableNode = left.parent {
            var index: Int = 0
            while index < parent.size && parent.children[index] != left {
                index++
            }
            if parent.size < NSTableOrderSub {
                return addIntoNode(parent, index: index, key: key, right: right)
            } else {
                return addIntoNodeAfterSplitting(parent, index: index, key: key, right: right)
            }
        } else {
            return addIntoNewRoot(left, key, right)
        }
    }

    private func addIntoNode(left: NSTableNode, index: Int, key: Int, right: NSTableNode) -> NSTableNode {
        for var i: Int = left.size ; i > index ; i-- {
            left.keys[i] = left.keys[i-1]
            left.children[i+1] = left.children[i]
        }
        left.keys[index] = key
        left.children[index+1] = right
        left.size++
        left.changed = true
        right.changed = true
        return root
    }
    
    private func addIntoNodeAfterSplitting(left: NSTableNode, index: Int, key: Int, right: NSTableNode) -> NSTableNode {
        var keys: [Int] = [Int](count: NSTableOrder, repeatedValue: 0)
        var children: [NSObject] = [NSObject](count: NSTableOrderSum, repeatedValue: null)
        for var i: Int = 0, j: Int = 0 ; i < left.size + 1 ; i++, j++ {
            if j == index + 1 {
                j++
            }
            children[j] = left.children[i]
        }
        for var i: Int = 0, j: Int = 0 ; i < left.size + 1 ; i++, j++ {
            if j == index + 1 {
                j++
            }
            keys[j] = left.keys[i]
        }
        keys[index] = key
        children[index + 1] = right
        var other: NSTableNode = NSTableNode()
        other.leaf = false
        for var i: Int = 0 ; i < NSTableOrderCuttedSub ; i++ {
            other.keys[i] = keys[i]
            other.children[i] = children[i]
        }
        other.size = NSTableOrderCuttedSub
        other.children[NSTableOrderCuttedSub] = children[NSTableOrderCuttedSub]
        for var i: Int = NSTableOrderCuttedSub, j: Int = 0 ; i < NSTableOrder ; i++, j++ {
            other.keys[j] = keys[i]
            other.children[j] = children[i]
            other.size++
        }
        other.children[NSTableOrderSub] = other.children[NSTableOrderSub]
        
        
        for var i: Int = other.size ; i < NSTableOrderSub ; i++ {
            other.keys[i] = keys[i]
            other.children[i] = children[i]
        }
        for var i: Int = other.size ; i < NSTableOrderSub ; i++ {
            other.children[i] = null
        }
        other.parent = node.parent
        node.changed = true
        other.changed = true
        return addIntoParent(node, key: other.keys[0], right: other)

//    for (i = 0, j = 0; i < old_node->num_keys + 1; i++, j++) {
//        if (j == left_index + 1) j++;
//        temp_pointers[j] = old_node->pointers[i];
//    }
//    for (i = 0, j = 0; i < old_node->num_keys; i++, j++) {
//        if (j == left_index) j++;
//        temp_keys[j] = old_node->keys[i];
//    }
//    temp_pointers[left_index + 1] = right;
//    temp_keys[left_index] = key;
//    int split = bptn_cut(ORDER);
//    struct bptn* new_node = bptn_create_node();
//    if (!new_node) return 0;
//    old_node->num_keys = 0;
//    for (i = 0; i < split - 1; i++) {
//        old_node->pointers[i] = temp_pointers[i];
//        old_node->keys[i] = temp_keys[i];
//        old_node->num_keys++;
//    }
//    old_node->pointers[i] = temp_pointers[i];
//    int* k_prime = temp_keys[split - 1];
//    for (++i, j = 0; i < ORDER; i++, j++) {
//        new_node->pointers[j] = temp_pointers[i];
//        new_node->keys[j] = temp_keys[i];
//        new_node->num_keys++;
//    }
//    new_node->pointers[j] = temp_pointers[i];
//    new_node->parent = old_node->parent;
//    for (i = 0; i <= new_node->num_keys; i++) {
//        struct bptn* child = new_node->pointers[i];
//        child->parent = new_node;
//    }
//    new_node->changed = 1;
//    printf("bptn %d changed\n", *new_node->keys[0]);
//    old_node->changed = 1;
//    printf("bptn %d changed\n", *old_node->keys[0]);
//    right->changed = 1;
//    printf("bptn %d changed\n", *right->keys[0]);
//    return bptn_insert_into_parent(root, old_node, k_prime, new_node);

    }
    
    func findNode(key: Int) -> NSTableNode? {
        let node: NSTableNode = findLeafNode(key)
        for var i: Int = 0 ; i < node.size ; i++ {
            if node.keys[i] == key {
                if let value: NSTableNode = node.children[i] as? NSTableNode {
                    return value
                }
            }
        }
        return nil
    }
    
    func findLeafNode(key: Int) -> NSTableNode {
        var node: NSTableNode = root
        while !node.leaf {
            var i = 0
            while i < node.size && key >= node.keys[i] {
                i++
            }
            node = node.children[i] as! NSTableNode
        }
        return node
    }
    
    func get(key: Int) -> NSObject? {
        let node: NSTableNode = findLeafNode(key)
        for var i: Int = 0 ; i < node.size ; i++ {
            if node.keys[i] == key {
                return node.children[i]
            }
        }
        return nil
    }
    
}

class NSTableNode: NSObject {
    
    weak var parent: NSTableNode?
    
    var keys: [Int] = [Int](count: NSTableOrderSub, repeatedValue: 0)
    
    var children: [NSObject] = [NSObject](count: NSTableOrder, repeatedValue: null)
    
    var leaf: Bool = true
    
    var size: Int = 0
    
    var next: NSTableNode?
    
    var changed: Bool = true
    
}