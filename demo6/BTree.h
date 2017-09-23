//
//  BTree.h
//  iSql
//
//  Created by Bernardo Breder on 16/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BTREE_ORDER 2

@interface BTreeNode : NSObject

- (id)init;

@end

@interface BTree : NSObject

- (void)add:(uint64_t)key value:(NSObject*)value;

- (void)remove:(uint64_t)key;

- (NSString*)traverse;

@end
