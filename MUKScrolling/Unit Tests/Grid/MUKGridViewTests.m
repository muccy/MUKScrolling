// Copyright (c) 2012, Marco Muccinelli
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
// * Neither the name of the <organization> nor the
// names of its contributors may be used to endorse or promote products
// derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "MUKGridViewTests.h"

#import "MUKGridView.h"
#import "MUKDummyRecyclableView.h"
#import "MUKGridCellView_.h"
#import "MUKGridCellFixedSize.h"

#import <MUKToolkit/MUKToolkit.h>

@implementation MUKGridViewTests

- (void)testEnqueuedViewClass {
    MUKDummyRecyclableView *guestView = [[MUKDummyRecyclableView alloc] init];
    guestView.recycleIdentifier = @"Foo";
    
    MUKGridCellView_ *cellView = [[MUKGridCellView_ alloc] init];
    cellView.guestView = guestView;
    
    MUKGridView *gridView = [[MUKGridView alloc] init];
    [gridView enqueueView:cellView];
    
    id enqueuedView = [[gridView enqueuedViews] anyObject];
    STAssertTrue([enqueuedView isMemberOfClass:[MUKDummyRecyclableView class]], nil);
}

- (void)testVisibleViewClass {
    MUKDummyRecyclableView *guestView = [[MUKDummyRecyclableView alloc] init];
    guestView.recycleIdentifier = @"Foo";
    
    MUKGridCellView_ *cellView = [[MUKGridCellView_ alloc] init];
    cellView.guestView = guestView;
    
    MUKGridView *gridView = [[MUKGridView alloc] init];
    [gridView addSubview:cellView];
    
    id visibleView = [[gridView visibleViews] anyObject];
    STAssertTrue([visibleView isMemberOfClass:[MUKDummyRecyclableView class]], nil);
}
                  
- (void)testDequeuedViewClass {
    MUKDummyRecyclableView *guestView = [[MUKDummyRecyclableView alloc] init];
    guestView.recycleIdentifier = @"Foo";
    
    MUKGridCellView_ *cellView = [[MUKGridCellView_ alloc] init];
    cellView.guestView = guestView;
    
    MUKGridView *gridView = [[MUKGridView alloc] init];
    [gridView enqueueView:cellView];
    
    id dequeuedView = [gridView dequeueViewWithIdentifier:@"Foo"];
    STAssertTrue([dequeuedView isMemberOfClass:[MUKDummyRecyclableView class]], nil);
}

- (void)testDirection {
    MUKGridView *gridView = [[MUKGridView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    
    CGSize cellSize = CGSizeMake(50, 50);
    gridView.cellSize = [[MUKGridCellFixedSize alloc] initWithSize:cellSize];
    gridView.numberOfCells = 100;
    
    /*
     25 vertical rows, 4 horizontal columns
     */
    gridView.direction = MUKGridDirectionHorizontal;
    [gridView reloadData];
    STAssertEqualsWithAccuracy(gridView.contentSize.width, 25.0f * cellSize.width, 0.000001, @"25 vertical rows");
    STAssertEqualsWithAccuracy(gridView.contentSize.height, 4.0f * cellSize.height, 0.00001, @"4 horizontal columns");
    
    /*
     25 horizontal rows, 4 vertical columns
     */
    gridView.direction = MUKGridDirectionVertical;
    [gridView reloadData];
    STAssertEqualsWithAccuracy(gridView.contentSize.height, 25.0f * cellSize.height, 0.000001, @"25 vertical rows");
    STAssertEqualsWithAccuracy(gridView.contentSize.width, 4.0f * cellSize.width, 0.00001, @"4 horizontal columns");
}

- (void)testNumberOfCells {
    MUKGridView *gridView = [[MUKGridView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    gridView.direction = MUKGridDirectionVertical;
    
    CGSize cellSize = CGSizeMake(50, 50);
    gridView.cellSize = [[MUKGridCellFixedSize alloc] initWithSize:cellSize];
    gridView.cellCreationHandler = ^(NSInteger index) {
        MUKDummyRecyclableView *view = [[MUKDummyRecyclableView alloc] init];
        view.recycleIdentifier = @"Foo";
        return view;
    };

    gridView.numberOfCells = 0;
    [gridView reloadData];
    STAssertEqualsWithAccuracy(gridView.contentSize.width, 0.0f, 0.000001, @"No cells");
    STAssertEqualsWithAccuracy(gridView.contentSize.height, 0.0f, 0.000001, @"No cells");
    
    gridView.numberOfCells = 2;
    [gridView reloadData];
    STAssertEqualsWithAccuracy(gridView.contentSize.width, cellSize.width * 2.0f, 0.000001, @"2 cells");
    STAssertEqualsWithAccuracy(gridView.contentSize.height, cellSize.height, 0.000001, @"2 cells");
    STAssertEquals([[gridView visibleViews] count], (NSUInteger)2, @"2 cells");
    STAssertEquals([[gridView indexesOfVisibleCells] count], (NSUInteger)2, @"2 cells");
    
    gridView.numberOfCells = 400; // 100 rows & 4 columns
    NSUInteger maxVisibleCells = 16; // 4 rows & 4 columns are visible
    [gridView reloadData];
    STAssertEqualsWithAccuracy(gridView.contentSize.width, cellSize.width * 4.0f, 0.000001, @"%i cells", maxVisibleCells);
    STAssertEqualsWithAccuracy(gridView.contentSize.height, cellSize.height * 100.0f, 0.000001, @"%i cells", maxVisibleCells);
    STAssertEquals([[gridView visibleViews] count], maxVisibleCells, @"%i cells", maxVisibleCells);
    STAssertEquals([[gridView indexesOfVisibleCells] count], maxVisibleCells, @"%i cells", maxVisibleCells);
}

- (void)testCellCreationHandler {
    MUKGridView *gridView = [[MUKGridView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    gridView.direction = MUKGridDirectionVertical;
    
    CGSize cellSize = CGSizeMake(50, 50);
    gridView.cellSize = [[MUKGridCellFixedSize alloc] initWithSize:cellSize];
    
    gridView.numberOfCells = 400;
    NSUInteger maxVisibleCells = 16; // 4 rows & 4 columns are visible
    
    __block NSUInteger handlerCallsCount = 0;
    __block NSInteger recycledCellsCount = 0;
    __unsafe_unretained MUKGridView *weakGridView = gridView;
    gridView.cellCreationHandler = ^(NSInteger index) {
        handlerCallsCount++;
        
        MUKDummyRecyclableView *view = (MUKDummyRecyclableView *)[weakGridView dequeueViewWithIdentifier:@"Foo"];
        if (view == nil) {
            view = [[MUKDummyRecyclableView alloc] init];
            view.recycleIdentifier = @"Foo";
        }
        else {
            recycledCellsCount++;
        }
        
        return view;
    };
    
    [gridView reloadData];
    STAssertEquals(handlerCallsCount, maxVisibleCells, @"All cells created");
    STAssertEquals(recycledCellsCount, 0, @"No cells recycled");
    
    handlerCallsCount = 0;
    recycledCellsCount = 0;
    [gridView reloadData];
    STAssertEquals(handlerCallsCount, maxVisibleCells, @"All cells created");
    STAssertEquals((NSUInteger)recycledCellsCount, maxVisibleCells, @"All cells recycled");    
}

- (void)testReloadData {
    MUKGridView *gridView = [[MUKGridView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    gridView.direction = MUKGridDirectionVertical;

    STAssertEquals((NSUInteger)0, [[gridView visibleViews] count], @"No cells layed out");
    STAssertTrue(CGSizeEqualToSize(CGSizeZero, gridView.contentSize), @"No cells layed out");
    
    CGSize cellSize = CGSizeMake(50, 50);
    gridView.cellSize = [[MUKGridCellFixedSize alloc] initWithSize:cellSize];
    gridView.numberOfCells = 2;
    gridView.cellCreationHandler = ^(NSInteger index) {
        MUKDummyRecyclableView *view = [[MUKDummyRecyclableView alloc] init];
        view.recycleIdentifier = @"Foo";
        return view;
    };
    
    [gridView reloadData];
    STAssertEquals((NSUInteger)gridView.numberOfCells, [[gridView visibleViews] count], @"2 cells layed out");
}

- (void)testIndexesOfVisibleCells {
    MUKGridView *gridView = [[MUKGridView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    gridView.direction = MUKGridDirectionVertical;
    gridView.numberOfCells = 1000;
    
    CGSize cellSize = CGSizeMake(50, 50);
    gridView.cellSize = [[MUKGridCellFixedSize alloc] initWithSize:cellSize];
    gridView.cellCreationHandler = ^(NSInteger index) {
        MUKDummyRecyclableView *view = [[MUKDummyRecyclableView alloc] init];
        view.recycleIdentifier = @"Foo";
        return view;
    };
    
    [gridView reloadData];
    NSIndexSet *visibleIndexes = [gridView indexesOfVisibleCells];
    STAssertEquals((NSUInteger)16, [visibleIndexes count], @"16 visible cells");
    NSRange visibleRange = NSMakeRange(0, 16);
    [visibleIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        STAssertTrue(NSLocationInRange(idx, visibleRange), @"Visible indexes = [0, 15]");
    }];
}

- (void)testIndexesOfCellsInVisibleBounds {
    MUKGridView *gridView = [[MUKGridView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    gridView.direction = MUKGridDirectionVertical;
    gridView.numberOfCells = 16; // 4 rows
    
    CGSize cellSize = CGSizeMake(50, 50);
    gridView.cellSize = [[MUKGridCellFixedSize alloc] initWithSize:cellSize];
    
    CGRect bounds = CGRectMake(0, 0, 200, 100);
    NSIndexSet *indexSet = [gridView indexesOfCellsInVisibleBounds:bounds];
    NSRange expectedRange = NSMakeRange(0, 8);
    STAssertEquals((NSUInteger)8, [indexSet count], @"Two rows");
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        STAssertTrue(NSLocationInRange(idx, expectedRange), @"%i in first two rows", idx);
    }];
    
    bounds = CGRectMake(0, -100, 200, 100);
    indexSet = [gridView indexesOfCellsInVisibleBounds:bounds];
    expectedRange = NSMakeRange(0, 4);
    STAssertEquals((NSUInteger)4, [indexSet count], @"One row");
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        STAssertTrue(NSLocationInRange(idx, expectedRange), @"%i in first row", idx);
    }];
    
    bounds = CGRectMake(0, 50, 200, 100);
    indexSet = [gridView indexesOfCellsInVisibleBounds:bounds];
    expectedRange = NSMakeRange(4, 8);
    STAssertEquals((NSUInteger)8, [indexSet count], @"Two rows");
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        STAssertTrue(NSLocationInRange(idx, expectedRange), @"%i in second and third row", idx);
    }];
    
    bounds = CGRectMake(0, 150, 200, 100);
    indexSet = [gridView indexesOfCellsInVisibleBounds:bounds];
    expectedRange = NSMakeRange(12, 4);
    STAssertEquals((NSUInteger)4, [indexSet count], @"One row");
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        STAssertTrue(NSLocationInRange(idx, expectedRange), @"%i in last row", idx);
    }];
    
    bounds = CGRectMake(0, 1500, 200, 100);
    indexSet = [gridView indexesOfCellsInVisibleBounds:bounds];
    STAssertEquals((NSUInteger)0, [indexSet count], @"No rows");
}

- (void)testFrameOfCell {
    MUKGridView *gridView = [[MUKGridView alloc] initWithFrame:CGRectMake(0, 0, 200, 240)];
    gridView.direction = MUKGridDirectionVertical;
    gridView.numberOfCells = 16; // 4 rows
    
    CGSize cellSize = CGSizeMake(50, 60);
    gridView.cellSize = [[MUKGridCellFixedSize alloc] initWithSize:cellSize];
    
    NSInteger cellIndex = 0;
    CGRect cellFrame = [gridView frameOfCellAtIndex:cellIndex];
    STAssertTrue(CGSizeEqualToSize(cellFrame.size, cellSize), @"Cell size preserved");
    STAssertEqualsWithAccuracy(0.0f, cellFrame.origin.y, 0.0000001, @"Origin");
    STAssertEqualsWithAccuracy(0.0f, cellFrame.origin.x, 0.0000001, @"Origin");
    
    cellIndex = 6;
    cellFrame = [gridView frameOfCellAtIndex:cellIndex];
    STAssertTrue(CGSizeEqualToSize(cellFrame.size, cellSize), @"Cell size preserved");
    STAssertEqualsWithAccuracy(cellSize.height, cellFrame.origin.y, 0.0000001, @"Coord: (1, 2)");
    STAssertEqualsWithAccuracy(cellSize.width * 2.0f, cellFrame.origin.x, 0.0000001, @"Coord: (1, 2)");
    
    
    
    // Horizontal (vertical rows)
    gridView.direction = MUKGridDirectionHorizontal;
    
    cellIndex = 0;
    cellFrame = [gridView frameOfCellAtIndex:cellIndex];
    STAssertTrue(CGSizeEqualToSize(cellFrame.size, cellSize), @"Cell size preserved");
    STAssertEqualsWithAccuracy(0.0f, cellFrame.origin.y, 0.0000001, @"Origin");
    STAssertEqualsWithAccuracy(0.0f, cellFrame.origin.x, 0.0000001, @"Origin");
    
    cellIndex = 6;
    cellFrame = [gridView frameOfCellAtIndex:cellIndex];
    STAssertTrue(CGSizeEqualToSize(cellFrame.size, cellSize), @"Cell size preserved");
    STAssertEqualsWithAccuracy(cellSize.width, cellFrame.origin.x, 0.0000001, @"Coord: (1, 2)");
    STAssertEqualsWithAccuracy(cellSize.height * 2.0f, cellFrame.origin.y, 0.0000001, @"Coord: (1, 2)");
}

- (void)testScrollToCell {
    MUKGridView *gridView = [[MUKGridView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    gridView.direction = MUKGridDirectionVertical;
    gridView.numberOfCells = 32; // 8 rows
    
    CGSize cellSize = CGSizeMake(50, 50);
    gridView.cellSize = [[MUKGridCellFixedSize alloc] initWithSize:cellSize];
    [gridView reloadData];
    
    NSInteger cellIndex = 15;
    CGFloat offset = 3.0 * cellSize.height;
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionHead animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, 0.0f, 0.000001, nil);
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, offset, 0.000001, @"4th row");
    
    offset = 3.0 * cellSize.height - gridView.bounds.size.height/2.0 + cellSize.height/2.0;
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionMiddle animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, 0.0f, 0.000001, nil);
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, offset, 0.000001, @"4th row");
    
    offset = 3.0 * cellSize.height - gridView.bounds.size.height + cellSize.height;
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionTail animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, 0.0f, 0.000001, nil);
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, offset, 0.000001, @"4th row");
    
    // Head preserved
    cellIndex = 0;
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionTail animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, 0.0f, 0.000001, nil);
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, 0.0f, 0.000001, @"1st row");
    
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionMiddle animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, 0.0f, 0.000001, nil);
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, 0.0f, 0.000001, @"1st row");
    
    // Tail preserved
    cellIndex = gridView.numberOfCells - 1;
    offset = gridView.contentSize.height - gridView.bounds.size.height;
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionHead animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, 0.0f, 0.000001, nil);
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, offset, 0.000001, @"Last row");
    
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionMiddle animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, 0.0f, 0.000001, nil);
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, offset, 0.000001, @"Last row");
    
    
    /////////////////////////////////////////
    // Horizontal
    cellIndex = 15;
    gridView.direction = MUKGridDirectionHorizontal;
    [gridView reloadData];
    
    offset = 3.0 * cellSize.width;
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionHead animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, offset, 0.000001, @"4th vertical row");
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, 0.0f, 0.000001, nil);
    
    offset = 3.0 * cellSize.width - gridView.bounds.size.width/2.0 + cellSize.width/2.0;
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionMiddle animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, offset, 0.000001, @"4th vertical row");
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, 0.0f, 0.000001, nil);
    
    offset = 3.0 * cellSize.width - gridView.bounds.size.width + cellSize.width;
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionTail animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, offset, 0.000001, @"4th vertical row");
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, 0.0f, 0.000001, nil);
    
    // Head preserved
    cellIndex = 0;
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionTail animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, 0.0f, 0.000001, nil);
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, 0.0f, 0.000001, @"1st row");
    
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionMiddle animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, 0.0f, 0.000001, nil);
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, 0.0f, 0.000001, @"1st row");
    
    // Tail preserved
    cellIndex = gridView.numberOfCells - 1;
    offset = gridView.contentSize.width - gridView.bounds.size.width;
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionHead animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, offset, 0.000001, nil);
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, 0.0f, 0.000001, @"Last row");
    
    [gridView scrollToCellAtIndex:cellIndex position:MUKGridScrollPositionMiddle animated:NO];
    STAssertEqualsWithAccuracy(gridView.contentOffset.x, offset, 0.000001, nil);
    STAssertEqualsWithAccuracy(gridView.contentOffset.y, 0.0f, 0.000001, @"Last row");
}

- (void)testCellViewAtIndex {
    MUKGridView *gridView = [[MUKGridView alloc] init];
    STAssertNil([gridView cellViewAtIndex:1], @"No cells");
    
    MUKGridCellView_ *cellView = [[MUKGridCellView_ alloc] init];
    cellView.cellIndex = 1;
    MUKDummyRecyclableView *guestView = [[MUKDummyRecyclableView alloc] init];
    guestView.recycleIdentifier = @"Foo";
    cellView.guestView = guestView;
    
    [gridView addSubview:cellView];
    STAssertNil([gridView cellViewAtIndex:0], nil);
    STAssertEqualObjects([gridView cellViewAtIndex:1], guestView, nil);
}

- (void)testScrollCompletionHandler {
    MUKGridView *gridView = [[MUKGridView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    gridView.numberOfCells = 100;
    gridView.cellSize = [[MUKGridCellFixedSize alloc] initWithSize:CGSizeMake(50, 50)];
    [gridView reloadData];
    
    __block MUKGridScrollKind originatedScrollKind = -1;
    __block BOOL handlerCalled = NO;
    gridView.scrollCompletionHandler = ^(MUKGridScrollKind scrollKind) {
        originatedScrollKind = scrollKind;
        handlerCalled = YES;
    };
    
    [gridView scrollToCellAtIndex:80 position:MUKGridScrollPositionHead animated:NO];
    STAssertFalse(handlerCalled, @"Not animated");
    
    [gridView scrollToCellAtIndex:0 position:MUKGridScrollPositionHead animated:YES];

    BOOL done = NO;
    [MUK waitForCompletion:&done timeout:2.0 runLoop:nil];
    
    STAssertTrue(handlerCalled, @"Animated");
    STAssertEquals(originatedScrollKind, MUKGridScrollKindAnimated, @"Programmatically animated");
}

@end
