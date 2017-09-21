//
//  iStorageTests.m
//  iStorageTests
//
//  Created by Bernardo Breder on 16/08/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BPTree.h"

@interface iStorageTests : XCTestCase

@end

@implementation iStorageTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
	BPTree *storage = [[BPTree alloc] init];
	XCTAssertTrue([storage add:[NSNumber numberWithInt:10] value:[NSNumber numberWithInt:10]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:5] value:[NSNumber numberWithInt:5]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:8] value:[NSNumber numberWithInt:8]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:2] value:[NSNumber numberWithInt:2]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:4] value:[NSNumber numberWithInt:4]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:1] value:[NSNumber numberWithInt:1]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:9] value:[NSNumber numberWithInt:9]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:7] value:[NSNumber numberWithInt:7]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:3] value:[NSNumber numberWithInt:3]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:6] value:[NSNumber numberWithInt:6]]);
	
	XCTAssertEqual([NSNumber numberWithInt:10], [storage value:[NSNumber numberWithInt:10]]);
	XCTAssertEqual([NSNumber numberWithInt:9], [storage value:[NSNumber numberWithInt:9]]);
	XCTAssertEqual([NSNumber numberWithInt:8], [storage value:[NSNumber numberWithInt:8]]);
	XCTAssertEqual([NSNumber numberWithInt:7], [storage value:[NSNumber numberWithInt:7]]);
	XCTAssertEqual([NSNumber numberWithInt:6], [storage value:[NSNumber numberWithInt:6]]);
	XCTAssertEqual([NSNumber numberWithInt:1], [storage value:[NSNumber numberWithInt:1]]);
	XCTAssertEqual([NSNumber numberWithInt:2], [storage value:[NSNumber numberWithInt:2]]);
	XCTAssertEqual([NSNumber numberWithInt:3], [storage value:[NSNumber numberWithInt:3]]);
	XCTAssertEqual([NSNumber numberWithInt:4], [storage value:[NSNumber numberWithInt:4]]);
	XCTAssertEqual([NSNumber numberWithInt:5], [storage value:[NSNumber numberWithInt:5]]);
}

- (void)testInsertStress {
	NSUInteger max = 16 * 1024;
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:max];
	for (NSUInteger n = 1 ; n <= max ; n++) {
		[array addObject:[NSNumber numberWithUnsignedInteger:n]];
	}
	NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger remainingCount = count - i;
        NSUInteger exchangeIndex = i + (NSUInteger) arc4random_uniform((u_int32_t)remainingCount);
        [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
	BPTree *storage = [[BPTree alloc] init];
	for	(NSUInteger n = 0 ; n < count ; n++) {
		NSNumber *value = array[n];
		[storage add:value value:value];
	}
	for	(NSUInteger n = 0 ; n < count ; n++) {
		NSNumber *value = array[n];
		XCTAssertEqual(value, [storage value:value]);
	}
}

- (void)testRemote
{
	BPTree *storage = [[BPTree alloc] init];
	XCTAssertTrue([storage add:[NSNumber numberWithInt:10] value:[NSNumber numberWithInt:10]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:5] value:[NSNumber numberWithInt:5]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:8] value:[NSNumber numberWithInt:8]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:2] value:[NSNumber numberWithInt:2]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:4] value:[NSNumber numberWithInt:4]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:1] value:[NSNumber numberWithInt:1]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:9] value:[NSNumber numberWithInt:9]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:7] value:[NSNumber numberWithInt:7]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:3] value:[NSNumber numberWithInt:3]]);
	XCTAssertTrue([storage add:[NSNumber numberWithInt:6] value:[NSNumber numberWithInt:6]]);
	
	XCTAssertEqual([NSNumber numberWithInt:10], [storage value:[NSNumber numberWithInt:10]]);
	XCTAssertEqual([NSNumber numberWithInt:9], [storage value:[NSNumber numberWithInt:9]]);
	XCTAssertEqual([NSNumber numberWithInt:8], [storage value:[NSNumber numberWithInt:8]]);
	XCTAssertEqual([NSNumber numberWithInt:7], [storage value:[NSNumber numberWithInt:7]]);
	XCTAssertEqual([NSNumber numberWithInt:6], [storage value:[NSNumber numberWithInt:6]]);
	XCTAssertEqual([NSNumber numberWithInt:1], [storage value:[NSNumber numberWithInt:1]]);
	XCTAssertEqual([NSNumber numberWithInt:2], [storage value:[NSNumber numberWithInt:2]]);
	XCTAssertEqual([NSNumber numberWithInt:3], [storage value:[NSNumber numberWithInt:3]]);
	XCTAssertEqual([NSNumber numberWithInt:4], [storage value:[NSNumber numberWithInt:4]]);
	XCTAssertEqual([NSNumber numberWithInt:5], [storage value:[NSNumber numberWithInt:5]]);
	
	XCTAssertTrue([storage remove:[NSNumber numberWithInt:10]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:10]]);
	XCTAssertEqual([NSNumber numberWithInt:9], [storage value:[NSNumber numberWithInt:9]]);
	XCTAssertEqual([NSNumber numberWithInt:8], [storage value:[NSNumber numberWithInt:8]]);
	XCTAssertEqual([NSNumber numberWithInt:7], [storage value:[NSNumber numberWithInt:7]]);
	XCTAssertEqual([NSNumber numberWithInt:6], [storage value:[NSNumber numberWithInt:6]]);
	XCTAssertEqual([NSNumber numberWithInt:1], [storage value:[NSNumber numberWithInt:1]]);
	XCTAssertEqual([NSNumber numberWithInt:2], [storage value:[NSNumber numberWithInt:2]]);
	XCTAssertEqual([NSNumber numberWithInt:3], [storage value:[NSNumber numberWithInt:3]]);
	XCTAssertEqual([NSNumber numberWithInt:4], [storage value:[NSNumber numberWithInt:4]]);
	XCTAssertEqual([NSNumber numberWithInt:5], [storage value:[NSNumber numberWithInt:5]]);
	
	XCTAssertTrue([storage remove:[NSNumber numberWithInt:5]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:10]]);
	XCTAssertEqual([NSNumber numberWithInt:9], [storage value:[NSNumber numberWithInt:9]]);
	XCTAssertEqual([NSNumber numberWithInt:8], [storage value:[NSNumber numberWithInt:8]]);
	XCTAssertEqual([NSNumber numberWithInt:7], [storage value:[NSNumber numberWithInt:7]]);
	XCTAssertEqual([NSNumber numberWithInt:6], [storage value:[NSNumber numberWithInt:6]]);
	XCTAssertEqual([NSNumber numberWithInt:1], [storage value:[NSNumber numberWithInt:1]]);
	XCTAssertEqual([NSNumber numberWithInt:2], [storage value:[NSNumber numberWithInt:2]]);
	XCTAssertEqual([NSNumber numberWithInt:3], [storage value:[NSNumber numberWithInt:3]]);
	XCTAssertEqual([NSNumber numberWithInt:4], [storage value:[NSNumber numberWithInt:4]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:5]]);
	
	XCTAssertTrue([storage remove:[NSNumber numberWithInt:8]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:10]]);
	XCTAssertEqual([NSNumber numberWithInt:9], [storage value:[NSNumber numberWithInt:9]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:8]]);
	XCTAssertEqual([NSNumber numberWithInt:7], [storage value:[NSNumber numberWithInt:7]]);
	XCTAssertEqual([NSNumber numberWithInt:6], [storage value:[NSNumber numberWithInt:6]]);
	XCTAssertEqual([NSNumber numberWithInt:1], [storage value:[NSNumber numberWithInt:1]]);
	XCTAssertEqual([NSNumber numberWithInt:2], [storage value:[NSNumber numberWithInt:2]]);
	XCTAssertEqual([NSNumber numberWithInt:3], [storage value:[NSNumber numberWithInt:3]]);
	XCTAssertEqual([NSNumber numberWithInt:4], [storage value:[NSNumber numberWithInt:4]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:5]]);
	
	XCTAssertTrue([storage remove:[NSNumber numberWithInt:2]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:10]]);
	XCTAssertEqual([NSNumber numberWithInt:9], [storage value:[NSNumber numberWithInt:9]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:8]]);
	XCTAssertEqual([NSNumber numberWithInt:7], [storage value:[NSNumber numberWithInt:7]]);
	XCTAssertEqual([NSNumber numberWithInt:6], [storage value:[NSNumber numberWithInt:6]]);
	XCTAssertEqual([NSNumber numberWithInt:1], [storage value:[NSNumber numberWithInt:1]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:2]]);
	XCTAssertEqual([NSNumber numberWithInt:3], [storage value:[NSNumber numberWithInt:3]]);
	XCTAssertEqual([NSNumber numberWithInt:4], [storage value:[NSNumber numberWithInt:4]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:5]]);
	
	XCTAssertTrue([storage remove:[NSNumber numberWithInt:4]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:10]]);
	XCTAssertEqual([NSNumber numberWithInt:9], [storage value:[NSNumber numberWithInt:9]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:8]]);
	XCTAssertEqual([NSNumber numberWithInt:7], [storage value:[NSNumber numberWithInt:7]]);
	XCTAssertEqual([NSNumber numberWithInt:6], [storage value:[NSNumber numberWithInt:6]]);
	XCTAssertEqual([NSNumber numberWithInt:1], [storage value:[NSNumber numberWithInt:1]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:2]]);
	XCTAssertEqual([NSNumber numberWithInt:3], [storage value:[NSNumber numberWithInt:3]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:4]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:5]]);
	
	XCTAssertTrue([storage remove:[NSNumber numberWithInt:1]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:10]]);
	XCTAssertEqual([NSNumber numberWithInt:9], [storage value:[NSNumber numberWithInt:9]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:8]]);
	XCTAssertEqual([NSNumber numberWithInt:7], [storage value:[NSNumber numberWithInt:7]]);
	XCTAssertEqual([NSNumber numberWithInt:6], [storage value:[NSNumber numberWithInt:6]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:1]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:2]]);
	XCTAssertEqual([NSNumber numberWithInt:3], [storage value:[NSNumber numberWithInt:3]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:4]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:5]]);
	
	XCTAssertTrue([storage remove:[NSNumber numberWithInt:9]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:10]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:9]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:8]]);
	XCTAssertEqual([NSNumber numberWithInt:7], [storage value:[NSNumber numberWithInt:7]]);
	XCTAssertEqual([NSNumber numberWithInt:6], [storage value:[NSNumber numberWithInt:6]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:1]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:2]]);
	XCTAssertEqual([NSNumber numberWithInt:3], [storage value:[NSNumber numberWithInt:3]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:4]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:5]]);
	
	
	XCTAssertTrue([storage remove:[NSNumber numberWithInt:7]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:10]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:9]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:8]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:7]]);
	XCTAssertEqual([NSNumber numberWithInt:6], [storage value:[NSNumber numberWithInt:6]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:1]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:2]]);
	XCTAssertEqual([NSNumber numberWithInt:3], [storage value:[NSNumber numberWithInt:3]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:4]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:5]]);
	
	XCTAssertTrue([storage remove:[NSNumber numberWithInt:3]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:10]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:9]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:8]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:7]]);
	XCTAssertEqual([NSNumber numberWithInt:6], [storage value:[NSNumber numberWithInt:6]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:1]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:2]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:3]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:4]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:5]]);
	
	XCTAssertTrue([storage remove:[NSNumber numberWithInt:6]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:10]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:9]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:8]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:7]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:6]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:1]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:2]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:3]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:4]]);
	XCTAssertNil([storage value:[NSNumber numberWithInt:5]]);
}

- (void)testStress
{
	NSUInteger max = 16 * 1024;
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:max];
	for (NSUInteger n = 1 ; n <= max ; n++) {
		[array addObject:[NSNumber numberWithUnsignedInteger:n]];
	}
	NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger remainingCount = count - i;
        NSUInteger exchangeIndex = i + (NSUInteger) arc4random_uniform((u_int32_t)remainingCount);
        [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
	BPTree *storage = [[BPTree alloc] init];
	for	(NSUInteger n = 0 ; n < count ; n++) {
		NSNumber *value = array[n];
		[storage add:value value:value];
	}
	for	(NSUInteger n = 0 ; n < count ; n++) {
		NSNumber *value = array[n];
		XCTAssertEqual(value, [storage value:value]);
	}
	for	(NSUInteger n = 0 ; n < count ; n++) {
		NSNumber *value = array[n];
		XCTAssertTrue([storage remove:value]);
	}
	for	(NSUInteger n = 0 ; n < count ; n++) {
		NSNumber *value = array[n];
		XCTAssertNil([storage value:value]);
	}
	for	(NSUInteger n = 0 ; n < count ; n++) {
		NSNumber *value = array[n];
		[storage add:value value:value];
	}
	for	(NSUInteger n = 0 ; n < count ; n++) {
		NSNumber *value = array[n];
		XCTAssertEqual(value, [storage value:value]);
	}
	for	(NSUInteger n = 0 ; n < count ; n++) {
		NSNumber *value = array[n];
		XCTAssertTrue([storage remove:value]);
	}
    for	(NSUInteger n = 0 ; n < count ; n++) {
        NSNumber *value = array[n];
        XCTAssertNil([storage value:value]);
    }
}

- (void)_testLoopStress
{
	NSUInteger max = 256 * 1024;
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:max];
	for (NSUInteger n = 1 ; n <= max ; n++) {
		[array addObject:[NSNumber numberWithUnsignedInteger:n]];
	}
	NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger remainingCount = count - i;
        NSUInteger exchangeIndex = i + (NSUInteger) arc4random_uniform((u_int32_t)remainingCount);
        [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
	for (;;) {
		@autoreleasepool {
			BPTree *storage = [[BPTree alloc] init];
			for	(NSUInteger n = 0 ; n < count ; n++) {
				NSNumber *value = array[n];
				[storage add:value value:value];
			}
			for	(NSUInteger n = 0 ; n < count ; n++) {
				NSNumber *value = array[n];
				XCTAssertEqual(value, [storage value:value]);
			}
			for	(NSUInteger n = 0 ; n < count ; n++) {
				NSNumber *value = array[n];
				XCTAssertTrue([storage remove:value]);
			}
			for	(NSUInteger n = 0 ; n < count ; n++) {
				NSNumber *value = array[n];
				[storage add:value value:value];
			}
			for	(NSUInteger n = 0 ; n < count ; n++) {
				NSNumber *value = array[n];
				XCTAssertEqual(value, [storage value:value]);
			}
			for	(NSUInteger n = 0 ; n < count ; n++) {
				NSNumber *value = array[n];
				XCTAssertTrue([storage remove:value]);
			}
		}
	}
}

//- (void)testPerformanceExample {
// This is an example of a performance test case.
//    [self measureBlock:^{
// Put the code you want to measure the time of here.
//    }];
//}

@end
