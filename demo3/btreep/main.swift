
import Foundation

class BPTree: NSObject {
    
    let order: Int
    
    var sequence: Int
    
    var root: BPTreeNode?
    
    init(order: Int) {
        self.order = order
        self.sequence = 1
        self.root = nil
        super.init()
        self.root = BPTreeNode(tree: self)
    }
    
    func find(key: Int) -> NSObject? {
        return root?.find(key)
    }
    
    func insert(key: Int, value: NSObject) -> BPTree {
        self.root = root?.insert(self, key: key, value: value)
        return self
    }
    
    func unchanged() {
        self.root?.unchanged()
    }
    
}

class BPTreeNode: NSObject {
    
    weak var tree: BPTree?
    
    let id: Int
    
    var pointers: [NSObject?]
    
    var keys: [Int]
    
    weak var parent: BPTreeNode?
    
    var leaf: Bool
    
    var length: Int
    
    var changed: Bool
    
    init(tree: BPTree) {
        self.tree = tree
        self.id = tree.sequence++
        self.pointers = [NSObject?](count: tree.order, repeatedValue: nil)
        self.keys = [Int](count: tree.order - 1, repeatedValue: 0);
        self.length = 0
        self.leaf = true
        self.changed = true
    }
    
    func first() -> BPTreeNode {
        var node: BPTreeNode = self
        while !node.leaf {
            node = node.pointers[0] as! BPTreeNode
        }
        return node
    }
    
    func last() -> BPTreeNode {
        var node: BPTreeNode = self
        while !node.leaf {
            node = node.pointers[node.length] as! BPTreeNode
        }
        return node
    }
    
    func next() -> BPTreeNode? {
        return self.pointers[self.pointers.count - 1] as? BPTreeNode
    }
    
    func unchanged() {
        self.changed = false
        if !self.leaf {
            for i: Int in 0 ... self.length {
                let node: BPTreeNode = self.pointers[i] as! BPTreeNode
                node.unchanged()
            }
        }
    }
    
    func find(key: Int) -> NSObject? {
        let leaf: BPTreeNode = self.findLeaf(key)
        var n: Int
        for n = 0; n < leaf.length; n++ {
            if leaf.keys[n] == key {
                break
            }
        }
        if n == leaf.length {
            return nil
        } else {
            return leaf.pointers[n]
        }
    }
    
    func findLeaf(key: Int) -> BPTreeNode {
        var node: BPTreeNode = self
        while !node.leaf {
            var i: Int = 0
            while i < node.length {
                if key >= node.keys[i] {
                    i++
                } else {
                    break
                }
            }
            node = node.pointers[i] as! BPTreeNode
        }
        return node
    }
    
    func insert(tree: BPTree, key: Int, value: NSObject) -> BPTreeNode {
        let leaf: BPTreeNode = self.findLeaf(key)
        if leaf.length < tree.order - 1 {
            leaf.insertIntoLeaf(tree, key: key, value: value)
            return self
        } else {
            return self.insertIntoLeafAfterSplitting(tree, left: leaf, key: key, value: value)
        }
    }
    
    func insertIntoLeaf(tree: BPTree, key: Int, value: NSObject) {
        var i: Int, ip: Int = 0
        while ip < self.length && self.keys[ip] <= key {
            ip++
        }
        if self.keys[ip] == key {
            return
        }
        for i = self.length; i > ip; i-- {
            self.keys[i] = self.keys[i - 1]
            self.pointers[i] = self.pointers[i - 1]
        }
        self.keys[ip] = key
        self.pointers[ip] = value
        self.length++
        self.changed = true
    }
    
    func insertIntoLeafAfterSplitting(tree: BPTree, left: BPTreeNode, key: Int, value: NSObject) -> BPTreeNode {
        let order: Int = tree.order
        var tmpKeys: [Int] = [Int](count: order, repeatedValue: 0)
        var tmpPointers: [NSObject?] = [NSObject?](count: order, repeatedValue: nil)
        let right: BPTreeNode = BPTreeNode(tree: tree)
        var ii: Int = 0
        while ii < order - 1 && left.keys[ii] < key {
            ii++
        }
        var i: Int, j: Int
        for i = 0, j = 0; i < left.length; i++, j++ {
            if j == ii {
                j++
            }
            tmpKeys[j] = left.keys[i]
            tmpPointers[j] = left.pointers[i]
        }
        tmpKeys[ii] = key
        tmpPointers[ii] = value
        let split: Int = ((order - 1) % 2) == 0 ? (order - 1) / 2 : (order - 1) / 2 + 1
        left.length = split
        for i = 0; i < split; i++ {
            left.keys[i] = tmpKeys[i]
            left.pointers[i] = tmpPointers[i]
        }
        right.length = order - split
        for i = split, j = 0; i < order; i++, j++ {
            right.keys[j] = tmpKeys[i]
            right.pointers[j] = tmpPointers[i]
        }
        right.pointers[order - 1] = left.pointers[order - 1]
        left.pointers[order - 1] = right
        for i = left.length; i < order - 1; i++ {
            left.pointers[i] = nil
        }
        for i = right.length; i < order - 1; i++ {
            right.pointers[i] = nil
        }
        right.parent = left.parent
        left.changed = true
        return self.insertIntoParent(tree, left: left, key: right.keys[0], right: right);
    }
    
    func insertIntoParent(tree: BPTree, left: BPTreeNode, key: Int, right: BPTreeNode) -> BPTreeNode {
        if let parent: BPTreeNode = left.parent {
            let i = parent.getLeftIndex(left)
            if parent.length < tree.order - 1 {
                return self.insertIntoNode(tree, node: parent, index: i, key: key, right: right)
            } else {
                return self.insertIntoNodeAfterSplitting(tree, oldNode: parent, index: i, key: key, right: right)
            }
        } else {
            return left.insertIntoNewRoot(tree, key: key, node: right)
        }
    }
    
    func getLeftIndex(left: BPTreeNode) -> Int {
        var i: Int = 0
        while i <= self.length && self.pointers[i] != left {
            i++
        }
        return i
    }
    
    func insertIntoNode(tree: BPTree, node: BPTreeNode, index: Int, key: Int, right: BPTreeNode) -> BPTreeNode {
        var i: Int
        for i = node.length; i > index; i-- {
            node.keys[i] = node.keys[i - 1]
            node.pointers[i + 1] = node.pointers[i]
        }
        node.pointers[index + 1] = right
        node.keys[index] = key
        node.length++
        right.parent = node
        node.changed = true
        right.changed = true
        return self
    }
    
    func insertIntoNodeAfterSplitting(tree: BPTree, oldNode: BPTreeNode, index: Int, key: Int, right: BPTreeNode) ->
        BPTreeNode {
            let order: Int = tree.order
            var tmpKeys: [Int] = [Int](count: order, repeatedValue: 0)
            var tmpPointers: [NSObject?] = [NSObject?](count: order + 1, repeatedValue: nil)
            var i: Int, j: Int
            for i = 0, j = 0; i < oldNode.length; i++, j++ {
                if j == index {
                    j++
                }
                tmpKeys[j] = oldNode.keys[i]
            }
            for i = 0, j = 0; i < oldNode.length + 1; i++, j++ {
                if j == index + 1 {
                    j++
                }
                tmpPointers[j] = oldNode.pointers[i]
            }
            tmpKeys[index] = key
            tmpPointers[index + 1] = right
            let split: Int = (order % 2) == 0 ? order / 2 : order / 2 + 1
            let newLeaf: BPTreeNode = BPTreeNode(tree: tree)
            newLeaf.leaf = false
            oldNode.length = 0
            for i = 0; i < split - 1; i++ {
                oldNode.keys[i] = tmpKeys[i]
                oldNode.pointers[i] = tmpPointers[i]
                oldNode.length++
            }
            oldNode.pointers[i] = tmpPointers[i];
            let prime: Int = tmpKeys[split - 1]
            for ++i, j = 0; i < order; i++, j++ {
                newLeaf.keys[j] = tmpKeys[i]
                newLeaf.pointers[j] = tmpPointers[i]
                newLeaf.length++
            }
            newLeaf.pointers[j] = tmpPointers[i]
            newLeaf.parent = oldNode.parent
            for i = 0; i <= newLeaf.length; i++ {
                let child: BPTreeNode = newLeaf.pointers[i] as! BPTreeNode
                child.parent = newLeaf
            }
            oldNode.changed = true
            right.changed = true
            return self.insertIntoParent(tree, left: oldNode, key: prime, right: newLeaf);
    }
    
    func insertIntoNewRoot(tree: BPTree, key: Int, node: BPTreeNode) -> BPTreeNode {
        let root: BPTreeNode = BPTreeNode(tree: tree);
        root.leaf = false
        root.keys[0] = key
        root.pointers[0] = self
        root.pointers[1] = node
        root.length++
        self.parent = root
        node.parent = root
        self.changed = true
        node.changed = true
        return root
    }
    
}

print("Hello, World!")

do {
    let tree: BPTree = BPTree(order: 3)
    do {
        tree.unchanged()
        
        tree.insert(5, value: "5")
        assert(tree.root!.leaf)
        assert(tree.root!.length == 1)
        assert(tree.root!.keys[0] == 5)
        assert(tree.root!.changed)
        tree.root!.unchanged()
        
        tree.insert(2, value: "2")
        assert(tree.root!.leaf)
        assert(tree.root!.length == 2)
        assert(tree.root!.keys[0] == 2)
        assert(tree.root!.keys[1] == 5)
        assert(tree.root!.changed)
        tree.root!.unchanged()
        
        tree.insert(8, value: "8")
        assert(!tree.root!.leaf)
        assert(tree.root!.length == 1)
        assert(tree.root!.keys[0] == 5)
        assert(tree.root!.changed)
        
        assert((tree.root!.pointers[0] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[0] as! BPTreeNode).length == 1)
        assert((tree.root!.pointers[0] as! BPTreeNode).keys[0] == 2)
        assert((tree.root!.pointers[0] as! BPTreeNode).changed)
        
        assert((tree.root!.pointers[1] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[1] as! BPTreeNode).length == 2)
        assert((tree.root!.pointers[1] as! BPTreeNode).keys[0] == 5)
        assert((tree.root!.pointers[1] as! BPTreeNode).keys[1] == 8)
        assert((tree.root!.pointers[1] as! BPTreeNode).changed)
        tree.root!.unchanged()
        
        tree.insert(3, value: "3")
        assert(!tree.root!.leaf)
        assert(tree.root!.length == 1)
        assert(tree.root!.keys[0] == 5)
        assert(!tree.root!.changed)
        
        assert((tree.root!.pointers[0] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[0] as! BPTreeNode).length == 2)
        assert((tree.root!.pointers[0] as! BPTreeNode).keys[0] == 2)
        assert((tree.root!.pointers[0] as! BPTreeNode).keys[1] == 3)
        assert((tree.root!.pointers[0] as! BPTreeNode).changed)
        
        assert((tree.root!.pointers[1] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[1] as! BPTreeNode).length == 2)
        assert((tree.root!.pointers[1] as! BPTreeNode).keys[0] == 5)
        assert((tree.root!.pointers[1] as! BPTreeNode).keys[1] == 8)
        assert(!(tree.root!.pointers[1] as! BPTreeNode).changed)
        tree.root!.unchanged()
        
        tree.insert(7, value: "7")
        assert(!tree.root!.leaf)
        assert(tree.root!.length == 2)
        assert(tree.root!.keys[0] == 5)
        assert(tree.root!.keys[1] == 7)
        assert(tree.root!.changed)
        
        
        assert((tree.root!.pointers[0] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[0] as! BPTreeNode).length == 2)
        assert((tree.root!.pointers[0] as! BPTreeNode).keys[0] == 2)
        assert((tree.root!.pointers[0] as! BPTreeNode).keys[1] == 3)
        assert(!(tree.root!.pointers[0] as! BPTreeNode).changed)
        
        assert((tree.root!.pointers[1] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[1] as! BPTreeNode).length == 1)
        assert((tree.root!.pointers[1] as! BPTreeNode).keys[0] == 5)
        assert((tree.root!.pointers[1] as! BPTreeNode).changed)
        
        assert((tree.root!.pointers[2] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[2] as! BPTreeNode).length == 2)
        assert((tree.root!.pointers[2] as! BPTreeNode).keys[0] == 7)
        assert((tree.root!.pointers[2] as! BPTreeNode).keys[1] == 8)
        assert((tree.root!.pointers[2] as! BPTreeNode).changed)
        tree.root!.unchanged()
        
        tree.insert(9, value: "9")
        assert(!tree.root!.leaf)
        assert(tree.root!.length == 1)
        assert(tree.root!.keys[0] == 7)
        assert(tree.root!.changed)
        
        assert(!(tree.root!.pointers[0] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[0] as! BPTreeNode).length == 1)
        assert((tree.root!.pointers[0] as! BPTreeNode).keys[0] == 5)
        assert((tree.root!.pointers[0] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).length == 2)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).keys[0] == 2)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).keys[1] == 3)
        assert(!((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).length == 1)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[0] == 5)
        assert(!((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).changed)
        
        assert(!(tree.root!.pointers[1] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[1] as! BPTreeNode).length == 1)
        assert((tree.root!.pointers[1] as! BPTreeNode).keys[0] == 8)
        assert((tree.root!.pointers[1] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).length == 1)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).keys[0] == 7)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).length == 2)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[0] == 8)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[1] == 9)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).changed)
        tree.root!.unchanged()
        
        tree.insert(1, value: "1")
        assert(!tree.root!.leaf)
        assert(tree.root!.length == 1)
        assert(tree.root!.keys[0] == 7)
        assert(!tree.root!.changed)
        
        assert(!(tree.root!.pointers[0] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[0] as! BPTreeNode).length == 2)
        assert((tree.root!.pointers[0] as! BPTreeNode).keys[0] == 2)
        assert((tree.root!.pointers[0] as! BPTreeNode).keys[1] == 5)
        assert((tree.root!.pointers[0] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).length == 1)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).keys[0] == 1)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).length == 2)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[0] == 2)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[1] == 3)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[2] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[2] as! BPTreeNode).length == 1)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[2] as! BPTreeNode).keys[0] == 5)
        assert(!((tree.root!.pointers[0] as! BPTreeNode).pointers[2] as! BPTreeNode).changed)
        
        assert(!(tree.root!.pointers[1] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[1] as! BPTreeNode).length == 1)
        assert((tree.root!.pointers[1] as! BPTreeNode).keys[0] == 8)
        assert(!(tree.root!.pointers[1] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).length == 1)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).keys[0] == 7)
        assert(!((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).length == 2)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[0] == 8)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[1] == 9)
        assert(!((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).changed)
        tree.root!.unchanged()
        
        tree.insert(4, value: "4")
        assert(!tree.root!.leaf)
        assert(tree.root!.length == 2)
        assert(tree.root!.keys[0] == 3)
        assert(tree.root!.keys[1] == 7)
        assert(tree.root!.changed)
        
        assert(!(tree.root!.pointers[0] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[0] as! BPTreeNode).length == 1)
        assert((tree.root!.pointers[0] as! BPTreeNode).keys[0] == 2)
        assert((tree.root!.pointers[0] as! BPTreeNode).changed)
        
        assert(!(tree.root!.pointers[1] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[1] as! BPTreeNode).length == 1)
        assert((tree.root!.pointers[1] as! BPTreeNode).keys[0] == 5)
        assert((tree.root!.pointers[1] as! BPTreeNode).changed)
        
        assert(!(tree.root!.pointers[2] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[2] as! BPTreeNode).length == 1)
        assert((tree.root!.pointers[2] as! BPTreeNode).keys[0] == 8)
        assert(!(tree.root!.pointers[2] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).length == 1)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).keys[0] == 1)
        assert(!((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).length == 1)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[0] == 2)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).length == 2)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).keys[0] == 3)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).keys[1] == 4)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).length == 1)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[0] == 5)
        assert(!((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[0] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[0] as! BPTreeNode).length == 1)
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[0] as! BPTreeNode).keys[0] == 7)
        assert(!((tree.root!.pointers[2] as! BPTreeNode).pointers[0] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[1] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[1] as! BPTreeNode).length == 2)
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[0] == 8)
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[1] == 9)
        assert(!((tree.root!.pointers[2] as! BPTreeNode).pointers[1] as! BPTreeNode).changed)
        tree.root!.unchanged()
        
        tree.insert(6, value: "6")
        assert(!tree.root!.leaf)
        assert(tree.root!.length == 2)
        assert(tree.root!.keys[0] == 3)
        assert(tree.root!.keys[1] == 7)
        assert(!tree.root!.changed)
        
        assert(!(tree.root!.pointers[0] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[0] as! BPTreeNode).length == 1)
        assert((tree.root!.pointers[0] as! BPTreeNode).keys[0] == 2)
        assert(!(tree.root!.pointers[0] as! BPTreeNode).changed)
        
        assert(!(tree.root!.pointers[1] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[1] as! BPTreeNode).length == 1)
        assert((tree.root!.pointers[1] as! BPTreeNode).keys[0] == 5)
        assert(!(tree.root!.pointers[1] as! BPTreeNode).changed)
        
        assert(!(tree.root!.pointers[2] as! BPTreeNode).leaf)
        assert((tree.root!.pointers[2] as! BPTreeNode).length == 1)
        assert((tree.root!.pointers[2] as! BPTreeNode).keys[0] == 8)
        assert(!(tree.root!.pointers[2] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).length == 1)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).keys[0] == 1)
        assert(!((tree.root!.pointers[0] as! BPTreeNode).pointers[0] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).length == 1)
        assert(((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[0] == 2)
        assert(!((tree.root!.pointers[0] as! BPTreeNode).pointers[1] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).length == 2)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).keys[0] == 3)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).keys[1] == 4)
        assert(!((tree.root!.pointers[1] as! BPTreeNode).pointers[0] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).length == 2)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[0] == 5)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[1] == 6)
        assert(((tree.root!.pointers[1] as! BPTreeNode).pointers[1] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[0] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[0] as! BPTreeNode).length == 1)
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[0] as! BPTreeNode).keys[0] == 7)
        assert(!((tree.root!.pointers[2] as! BPTreeNode).pointers[0] as! BPTreeNode).changed)
        
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[1] as! BPTreeNode).leaf)
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[1] as! BPTreeNode).length == 2)
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[0] == 8)
        assert(((tree.root!.pointers[2] as! BPTreeNode).pointers[1] as! BPTreeNode).keys[1] == 9)
        assert(!((tree.root!.pointers[2] as! BPTreeNode).pointers[1] as! BPTreeNode).changed)
        tree.root!.unchanged()
    }
    
    do {
        tree.find(1)!
        tree.find(2)!
        tree.find(3)!
        tree.find(4)!
        tree.find(5)!
        tree.find(6)!
        tree.find(7)!
        tree.find(8)!
        tree.find(9)!
    }
}

do {
    let tree: BPTree = BPTree(order: 3)
    do {
        tree.insert(5, value: "5")
        tree.insert(2, value: "2")
        tree.insert(8, value: "8")
        tree.insert(3, value: "3")
        tree.insert(7, value: "7")
        tree.insert(9, value: "9")
        tree.insert(1, value: "1")
        tree.insert(4, value: "4")
        tree.insert(6, value: "6")
    }
    
    do {
        tree.find(1)!
        tree.find(2)!
        tree.find(3)!
        tree.find(4)!
        tree.find(5)!
        tree.find(6)!
        tree.find(7)!
        tree.find(8)!
        tree.find(9)!
    }
    
    do {
        var node: BPTreeNode? = tree.root!.first()
        while var n: BPTreeNode = node {
            for i in 0 ..< n.length {
                print(n.keys[i])
            }
            node = n.next()
        }
    }
}

extension CollectionType {
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}
extension MutableCollectionType where Index == Int {
    mutating func shuffleInPlace() {
        if count < 2 { return }
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

do {
    let max: Int = 32 * 1024
    let tree: BPTree = BPTree(order: 3)
    for i: Int in 1 ... max {
        tree.insert(i, value: "");
    }
    for i in 1 ... max {
        tree.find(i)!
    }
    do {
        var j: Int = 0
        var node: BPTreeNode? = tree.root!.first()
        while var n: BPTreeNode = node {
            for i in 0 ..< n.length {
                let key: Int = n.keys[i]
                assert(key == j + 1)
                j = key
                //            print(n.keys[i])
            }
            node = n.next()
        }
    }
}

do {
    let max: Int = 32 * 1024
    var keys: [Int] = [Int](count: Int(max), repeatedValue: 0)
    for i in 1 ... max {
        keys[i-1] = i
    }
    keys = keys.shuffle();
    for var i = 3; i <= 729; i *= 3 {
        print(i)
        let tree: BPTree = BPTree(order: i)
        for i in 1 ... max {
            tree.insert(keys[i-1], value: "");
        }
        for i in 1 ... max {
            tree.find(keys[i-1])!
        }
        do {
            var j: Int = 0
            var node: BPTreeNode? = tree.root!.first()
            while var n: BPTreeNode = node {
                for i in 0 ..< n.length {
                    let key: Int = n.keys[i]
                    assert(key == j + 1)
                    j = key
                }
                node = n.next()
            }
        }
    }
}