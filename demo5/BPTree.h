//
//  Storage.h
//  iStorage
//
//  Created by Bernardo Breder on 16/08/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPTree : NSObject

- (instancetype)init;

- (instancetype)initWithCompare:(NSInteger (^)(NSObject *left, NSObject* right))compare;

- (bool)add:(NSObject*)id value:(NSObject*)value;

- (NSObject*)value:(NSObject*)id;

- (bool)set:(NSObject*)id value:(NSObject*)value;

- (bool)remove:(NSObject*)id;

- (NSUInteger)count;

- (void)enumerateObjectsUsingBlock:(void (^)(NSObject *id, BOOL *stop))block;

@end

@interface BPTreeNode : NSObject 

- (instancetype)init;

@end