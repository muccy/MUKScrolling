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

#import "MUKGridViewPrivateTests.h"

#import "MUKGridView_Layout.h"
#import "MUKGridView_RowsAndColumns.h"

#import "MUKGridCellFixedSize.h"
#import "MUKGridView.h"
#import "MUKGridCellView_.h"
#import "MUKRecyclableView.h"

#import "MUKRecyclingScrollView_Storage.h"

@interface GridViewMock : MUKGridView
- (void)enqueueVisibleViews;
@end

@implementation GridViewMock

- (void)enqueueVisibleViews {
    [[self visibleHostCellViews_] enumerateObjectsUsingBlock:^(id obj, BOOL *stop) 
    {
        [self enqueueView:obj];
    }];
}

@end


@implementation MUKGridViewPrivateTests

#pragma mark - Rows & Columns

- (void)testMaxCellsForRow {
    CGSize gridSize = CGSizeMake(200, 200);
    CGSize cellSize = CGSizeMake(50, 60);
    
    STAssertEquals(4, [MUKGridView maxCellsPerRowInContainerSize_:gridSize cellSize_:cellSize direction_:MUKGridDirectionVertical], nil);
    STAssertEquals(3, [MUKGridView maxCellsPerRowInContainerSize_:gridSize cellSize_:cellSize direction_:MUKGridDirectionHorizontal], nil);
}

- (void)testMaxRowsForCellsCount {
    CGSize gridSize = CGSizeMake(200, 200);
    CGSize cellSize = CGSizeMake(50, 60);
    
    NSInteger maxCellsPerRow_v = [MUKGridView maxCellsPerRowInContainerSize_:gridSize cellSize_:cellSize direction_:MUKGridDirectionVertical];
    NSInteger maxCellsPerRow_h = [MUKGridView maxCellsPerRowInContainerSize_:gridSize cellSize_:cellSize direction_:MUKGridDirectionHorizontal];
    
    STAssertEquals(0, [MUKGridView maxRowsForCellsCount_:0 maxCellsPerRow_:maxCellsPerRow_h direction_:MUKGridDirectionHorizontal], @"No cells no rows");
    STAssertEquals(0, [MUKGridView maxRowsForCellsCount_:0 maxCellsPerRow_:maxCellsPerRow_v direction_:MUKGridDirectionVertical], @"No cells no rows");
    
    STAssertEquals(1, [MUKGridView maxRowsForCellsCount_:1 maxCellsPerRow_:maxCellsPerRow_h direction_:MUKGridDirectionHorizontal], nil);
    STAssertEquals(1, [MUKGridView maxRowsForCellsCount_:1 maxCellsPerRow_:maxCellsPerRow_v direction_:MUKGridDirectionVertical], nil);
    
    // Look at previous -testMaxCellsForRow
    STAssertEquals(1, [MUKGridView maxRowsForCellsCount_:3 maxCellsPerRow_:maxCellsPerRow_h direction_:MUKGridDirectionHorizontal], nil);
    STAssertEquals(1, [MUKGridView maxRowsForCellsCount_:4 maxCellsPerRow_:maxCellsPerRow_v direction_:MUKGridDirectionVertical], nil);
    
    STAssertEquals(2, [MUKGridView maxRowsForCellsCount_:4 maxCellsPerRow_:maxCellsPerRow_h direction_:MUKGridDirectionHorizontal], nil);
    STAssertEquals(2, [MUKGridView maxRowsForCellsCount_:5 maxCellsPerRow_:maxCellsPerRow_v direction_:MUKGridDirectionVertical], nil);
}

- (void)testCoordinateOfCell {
    CGSize cellSize = CGSizeMake(50, 60);
    CGFloat row, column;
    
    CGPoint point = CGPointZero;
    MUKGridCoordinate *coordinate = [MUKGridView coordinateOfCellOfSize_:cellSize atPoint:point direction_:MUKGridDirectionHorizontal decimalRow_:&row decimalColumn_:&column];
    STAssertEquals(0, coordinate.row, @"Origin");
    STAssertEquals(0, coordinate.column, @"Origin");
    STAssertEqualsWithAccuracy(0.0f, row - (CGFloat)coordinate.row, 0.0000001, @"No carry");
    STAssertEqualsWithAccuracy(0.0f, column - (CGFloat)coordinate.column, 0.0000001, @"No carry");
    
    coordinate = [MUKGridView coordinateOfCellOfSize_:cellSize atPoint:point direction_:MUKGridDirectionVertical decimalRow_:&row decimalColumn_:&column];
    STAssertEquals(0, coordinate.row, @"Origin");
    STAssertEquals(0, coordinate.column, @"Origin");
    STAssertEqualsWithAccuracy(0.0f, row - (CGFloat)coordinate.row, 0.0000001, @"No carry");
    STAssertEqualsWithAccuracy(0.0f, column - (CGFloat)coordinate.column, 0.0000001, @"No carry");
    
    point.x = cellSize.width * 0.8;
    point.y = cellSize.height * 0.8;
    coordinate = [MUKGridView coordinateOfCellOfSize_:cellSize atPoint:point direction_:MUKGridDirectionHorizontal decimalRow_:&row decimalColumn_:&column];
    STAssertEquals(0, coordinate.row, nil);
    STAssertEquals(0, coordinate.column, nil);
    STAssertEqualsWithAccuracy(0.8f, row - (CGFloat)coordinate.row, 0.0000001, nil);
    STAssertEqualsWithAccuracy(0.8f, column - (CGFloat)coordinate.column, 0.0000001, nil);
    
    coordinate = [MUKGridView coordinateOfCellOfSize_:cellSize atPoint:point direction_:MUKGridDirectionVertical decimalRow_:&row decimalColumn_:&column];
    STAssertEquals(0, coordinate.row, nil);
    STAssertEquals(0, coordinate.column, nil);
    STAssertEqualsWithAccuracy(0.8f, row - (CGFloat)coordinate.row, 0.0000001, nil);
    STAssertEqualsWithAccuracy(0.8f, column - (CGFloat)coordinate.column, 0.0000001, nil);
    
    point.x = cellSize.width;
    point.y = cellSize.height;
    coordinate = [MUKGridView coordinateOfCellOfSize_:cellSize atPoint:point direction_:MUKGridDirectionHorizontal decimalRow_:&row decimalColumn_:&column];
    STAssertEquals(1, coordinate.row, nil);
    STAssertEquals(1, coordinate.column, nil);
    STAssertEqualsWithAccuracy(0.0f, row - (CGFloat)coordinate.row, 0.0000001, @"No carry");
    STAssertEqualsWithAccuracy(0.0f, column - (CGFloat)coordinate.column, 0.0000001, @"No carry");
    
    coordinate = [MUKGridView coordinateOfCellOfSize_:cellSize atPoint:point direction_:MUKGridDirectionVertical decimalRow_:&row decimalColumn_:&column];
    STAssertEquals(1, coordinate.row, nil);
    STAssertEquals(1, coordinate.column, nil);
    STAssertEqualsWithAccuracy(0.0f, row - (CGFloat)coordinate.row, 0.0000001, @"No carry");
    STAssertEqualsWithAccuracy(0.0f, column - (CGFloat)coordinate.column, 0.0000001, @"No carry");
    
    point.x = cellSize.width * 1.8;
    point.y = cellSize.height * 3.7;
    coordinate = [MUKGridView coordinateOfCellOfSize_:cellSize atPoint:point direction_:MUKGridDirectionHorizontal decimalRow_:&row decimalColumn_:&column];
    STAssertEquals(1, coordinate.row, nil);
    STAssertEquals(3, coordinate.column, nil);
    STAssertEqualsWithAccuracy(0.8f, row - (CGFloat)coordinate.row, 0.0000001, nil);
    STAssertEqualsWithAccuracy(0.7f, column - (CGFloat)coordinate.column, 0.0000001, nil);
    
    coordinate = [MUKGridView coordinateOfCellOfSize_:cellSize atPoint:point direction_:MUKGridDirectionVertical decimalRow_:&row decimalColumn_:&column];
    STAssertEquals(3, coordinate.row, nil);
    STAssertEquals(1, coordinate.column, nil);
    STAssertEqualsWithAccuracy(0.7f, row - (CGFloat)coordinate.row, 0.0000001, nil);
    STAssertEqualsWithAccuracy(0.8f, column - (CGFloat)coordinate.column, 0.0000001, nil);
}

- (void)testCoordinatesInBounds {
    CGSize cellSize = CGSizeMake(50, 50);
    CGRect bounds = CGRectMake(0, 0, 40, 40);
    
    MUKGridCoordinate *coordinate = [[MUKGridCoordinate alloc] init];
    
    NSArray *coordinates = [MUKGridView coordinatesOfCellsOfSize_:cellSize inVisibleBounds_:bounds direction_:MUKGridDirectionHorizontal];
    STAssertEquals((NSUInteger)1, [coordinates count], @"Bounds smaller than full cell");
    coordinate.row = 0;     coordinate.column = 0;
    STAssertTrue([coordinates containsObject:coordinate], @"Origin");
    
    coordinates = [MUKGridView coordinatesOfCellsOfSize_:cellSize inVisibleBounds_:bounds direction_:MUKGridDirectionVertical];
    STAssertEquals((NSUInteger)1, [coordinates count], @"Bounds smaller than full cell");
    coordinate.row = 0;     coordinate.column = 0;
    STAssertTrue([coordinates containsObject:coordinate], @"Origin");
    
    bounds = CGRectMake(20, 20, 40, 40);
    coordinates = [MUKGridView coordinatesOfCellsOfSize_:cellSize inVisibleBounds_:bounds direction_:MUKGridDirectionHorizontal];
    STAssertEquals((NSUInteger)4, [coordinates count], @"Bounds smaller than full cell, but between four cells");
    coordinate.row = 0;     coordinate.column = 0;
    STAssertTrue([coordinates containsObject:coordinate], @"Origin");
    coordinate.row = 1;     coordinate.column = 0;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    coordinate.row = 1;     coordinate.column = 1;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    coordinate.row = 0;     coordinate.column = 1;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    
    bounds = CGRectMake(20, 20, 40, 40);
    coordinates = [MUKGridView coordinatesOfCellsOfSize_:cellSize inVisibleBounds_:bounds direction_:MUKGridDirectionVertical];
    STAssertEquals((NSUInteger)4, [coordinates count], @"Bounds smaller than full cell, but between four cells");
    coordinate.row = 0;     coordinate.column = 0;
    STAssertTrue([coordinates containsObject:coordinate], @"Origin");
    coordinate.row = 1;     coordinate.column = 0;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    coordinate.row = 1;     coordinate.column = 1;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    coordinate.row = 0;     coordinate.column = 1;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    
    bounds = CGRectMake(20, -30, 40, 40);
    coordinates = [MUKGridView coordinatesOfCellsOfSize_:cellSize inVisibleBounds_:bounds direction_:MUKGridDirectionVertical];
    STAssertEquals((NSUInteger)4, [coordinates count], @"Bounds smaller than full cell, but between four cells");
    coordinate.row = 0;     coordinate.column = 0;
    STAssertTrue([coordinates containsObject:coordinate], @"Origin");
    coordinate.row = -1;     coordinate.column = 0;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    coordinate.row = -1;     coordinate.column = 1;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    coordinate.row = 0;     coordinate.column = 1;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    
    bounds = CGRectMake(-30, 20, 40, 40);
    coordinates = [MUKGridView coordinatesOfCellsOfSize_:cellSize inVisibleBounds_:bounds direction_:MUKGridDirectionHorizontal];
    STAssertEquals((NSUInteger)4, [coordinates count], @"Bounds smaller than full cell, but between four cells");
    coordinate.row = 0;     coordinate.column = 0;
    STAssertTrue([coordinates containsObject:coordinate], @"Origin");
    coordinate.row = -1;     coordinate.column = 0;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    coordinate.row = -1;     coordinate.column = 1;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    coordinate.row = 0;     coordinate.column = 1;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    
    /*
     7 horizontal rows (1-7; 1, 7 partially visible; 0 hidden)
     4 cells per row
     28 cells
     */
    bounds = CGRectMake(0, 60, 200, 320);
    coordinates = [MUKGridView coordinatesOfCellsOfSize_:cellSize inVisibleBounds_:bounds direction_:MUKGridDirectionVertical];
    STAssertEquals((NSUInteger)28, [coordinates count], nil);
    coordinate.row = 0;     coordinate.column = 1;
    STAssertFalse([coordinates containsObject:coordinate], nil);
    coordinate.row = 1;     coordinate.column = 4;
    STAssertFalse([coordinates containsObject:coordinate], nil);
    coordinate.row = 8;     coordinate.column = 4;
    STAssertFalse([coordinates containsObject:coordinate], nil);
    coordinate.row = 2;     coordinate.column = 2;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    coordinate.row = 7;     coordinate.column = 3;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    
    /*
     Horizontal grid with a single column (a sort of page view)
     Looking at page 1 and a piece of page 2 (0 hidden)
     
     Note: Rows are horizontal!!!
     */
    bounds = CGRectMake(60, 0, 50, 50);
    coordinates = [MUKGridView coordinatesOfCellsOfSize_:cellSize inVisibleBounds_:bounds direction_:MUKGridDirectionHorizontal];
    STAssertEquals((NSUInteger)2, [coordinates count], nil);
    coordinate.row = 0;     coordinate.column = 0;
    STAssertFalse([coordinates containsObject:coordinate], nil);
    coordinate.row = 0;     coordinate.column = 1;
    STAssertFalse([coordinates containsObject:coordinate], nil);
    coordinate.row = 4;     coordinate.column = 0;
    STAssertFalse([coordinates containsObject:coordinate], nil);
    coordinate.row = 1;     coordinate.column = 0;
    STAssertTrue([coordinates containsObject:coordinate], nil);
    coordinate.row = 2;     coordinate.column = 0;
    STAssertTrue([coordinates containsObject:coordinate], nil);
}

- (void)testIndexesOfCellsInGivenBounds {
    MUKGridView *gridView = [[MUKGridView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    gridView.direction = MUKGridDirectionVertical;
    gridView.numberOfCells = 16; // 4 rows
    
    CGSize cellSize = CGSizeMake(50, 50);
    gridView.cellSize = [[MUKGridCellFixedSize alloc] initWithSize:cellSize];
    
    NSInteger maxCellsPerRow = [MUKGridView maxCellsPerRowInContainerSize_:gridView.frame.size cellSize_:cellSize direction_:gridView.direction];
    
    CGRect bounds = CGRectMake(0, 0, 200, 100);
    NSIndexSet *indexSet = [gridView indexesOfCellsInBounds_:bounds cellSize_:cellSize maxCellsPerRow_:maxCellsPerRow];
    NSRange expectedRange = NSMakeRange(0, 8);
    STAssertEquals((NSUInteger)8, [indexSet count], @"Two rows");
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        STAssertTrue(NSLocationInRange(idx, expectedRange), @"%i in first two rows", idx);
    }];
    
    bounds = CGRectMake(0, -100, 200, 100);
    indexSet = [gridView indexesOfCellsInBounds_:bounds cellSize_:cellSize maxCellsPerRow_:maxCellsPerRow];
    expectedRange = NSMakeRange(0, 4);
    STAssertEquals((NSUInteger)4, [indexSet count], @"One row");
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        STAssertTrue(NSLocationInRange(idx, expectedRange), @"%i in first row", idx);
    }];
    
    bounds = CGRectMake(0, 50, 200, 100);
    indexSet = [gridView indexesOfCellsInBounds_:bounds cellSize_:cellSize maxCellsPerRow_:maxCellsPerRow];
    expectedRange = NSMakeRange(4, 8);
    STAssertEquals((NSUInteger)8, [indexSet count], @"Two rows");
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        STAssertTrue(NSLocationInRange(idx, expectedRange), @"%i in second and third row", idx);
    }];
    
    bounds = CGRectMake(0, 150, 200, 100);
    indexSet = [gridView indexesOfCellsInBounds_:bounds cellSize_:cellSize maxCellsPerRow_:maxCellsPerRow];
    expectedRange = NSMakeRange(12, 4);
    STAssertEquals((NSUInteger)4, [indexSet count], @"One row");
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        STAssertTrue(NSLocationInRange(idx, expectedRange), @"%i in last row", idx);
    }];
    
    bounds = CGRectMake(0, 1500, 200, 100);
    indexSet = [gridView indexesOfCellsInBounds_:bounds cellSize_:cellSize maxCellsPerRow_:maxCellsPerRow];
    STAssertEquals((NSUInteger)0, [indexSet count], @"No rows");
}

#pragma mark - Layout

- (void)testContentSize {
    CGSize gridSize = CGSizeMake(200, 200);
    CGSize cellSize = CGSizeMake(50, 60);
    
    NSInteger maxCellsPerRow_h = [MUKGridView maxCellsPerRowInContainerSize_:gridSize cellSize_:cellSize direction_:MUKGridDirectionHorizontal];
    NSInteger maxCellsPerRow_v = [MUKGridView maxCellsPerRowInContainerSize_:gridSize cellSize_:cellSize direction_:MUKGridDirectionVertical];
    
    ////////////////
    // Horizontal //
    ////////////////
    MUKGridDirection direction = MUKGridDirectionHorizontal;
    
    NSInteger numberOfCells = 0;
    NSInteger maxRows = [MUKGridView maxRowsForCellsCount_:numberOfCells maxCellsPerRow_:maxCellsPerRow_h direction_:direction];
    CGSize contentSize = [MUKGridView contentSizeForDirection_:direction cellSize_:cellSize maxRows_:maxRows maxCellsPerRow_:maxCellsPerRow_h numberOfCells_:numberOfCells];
    STAssertTrue(CGSizeEqualToSize(CGSizeZero, contentSize), @"No cells, no size");
    
    numberOfCells = 1;
    maxRows = [MUKGridView maxRowsForCellsCount_:numberOfCells maxCellsPerRow_:maxCellsPerRow_h direction_:direction];
    contentSize = [MUKGridView contentSizeForDirection_:direction cellSize_:cellSize maxRows_:maxRows maxCellsPerRow_:maxCellsPerRow_h numberOfCells_:numberOfCells];
    STAssertEqualsWithAccuracy(cellSize.height, contentSize.height, 0.0000001, @"One horizontal column");
    STAssertEqualsWithAccuracy(cellSize.width, contentSize.width, 0.0000001, @"One vertical row");
    
    // Look at previous -testMaxCellsForRow
    numberOfCells = 3;
    maxRows = [MUKGridView maxRowsForCellsCount_:numberOfCells maxCellsPerRow_:maxCellsPerRow_h direction_:direction];
    contentSize = [MUKGridView contentSizeForDirection_:direction cellSize_:cellSize maxRows_:maxRows maxCellsPerRow_:maxCellsPerRow_h numberOfCells_:numberOfCells];
    STAssertEqualsWithAccuracy(cellSize.height * (float)numberOfCells, contentSize.height, 0.0000001, @"3 horizontal columns");
    STAssertEqualsWithAccuracy(cellSize.width, contentSize.width, 0.0000001, @"One vertical row");
    
    numberOfCells = 4;
    maxRows = [MUKGridView maxRowsForCellsCount_:numberOfCells maxCellsPerRow_:maxCellsPerRow_h direction_:direction];
    contentSize = [MUKGridView contentSizeForDirection_:direction cellSize_:cellSize maxRows_:maxRows maxCellsPerRow_:maxCellsPerRow_h numberOfCells_:numberOfCells];
    STAssertEqualsWithAccuracy(cellSize.height * 3.0f, contentSize.height, 0.0000001, @"3 horizontal columns");
    STAssertEqualsWithAccuracy(cellSize.width * 2.0f, contentSize.width, 0.0000001, @"Two vertical rows");
    
    numberOfCells = 40;
    maxRows = [MUKGridView maxRowsForCellsCount_:numberOfCells maxCellsPerRow_:maxCellsPerRow_h direction_:direction];
    contentSize = [MUKGridView contentSizeForDirection_:direction cellSize_:cellSize maxRows_:maxRows maxCellsPerRow_:maxCellsPerRow_h numberOfCells_:numberOfCells];
    STAssertEqualsWithAccuracy(cellSize.height * 3.0f, contentSize.height, 0.0000001, @"3 horizontal columns");
    STAssertEqualsWithAccuracy(cellSize.width * 14.0f, contentSize.width, 0.0000001, @"14 vertical rows");
    
    
    //////////////
    // Vertical //
    //////////////
    direction = MUKGridDirectionVertical;
    
    numberOfCells = 0;
    maxRows = [MUKGridView maxRowsForCellsCount_:numberOfCells maxCellsPerRow_:maxCellsPerRow_v direction_:direction];
    contentSize = [MUKGridView contentSizeForDirection_:direction cellSize_:cellSize maxRows_:maxRows maxCellsPerRow_:maxCellsPerRow_v numberOfCells_:numberOfCells];
    STAssertTrue(CGSizeEqualToSize(CGSizeZero, contentSize), @"No cells, no size");
    
    numberOfCells = 1;
    maxRows = [MUKGridView maxRowsForCellsCount_:numberOfCells maxCellsPerRow_:maxCellsPerRow_v direction_:direction];
    contentSize = [MUKGridView contentSizeForDirection_:direction cellSize_:cellSize maxRows_:maxRows maxCellsPerRow_:maxCellsPerRow_v numberOfCells_:numberOfCells];
    STAssertEqualsWithAccuracy(cellSize.width, contentSize.width, 0.0000001, @"One vertical column");
    STAssertEqualsWithAccuracy(cellSize.height, contentSize.height, 0.0000001, @"One horizontal row");
    
    // Look at previous -testMaxCellsForRow
    numberOfCells = 4;
    maxRows = [MUKGridView maxRowsForCellsCount_:numberOfCells maxCellsPerRow_:maxCellsPerRow_v direction_:direction];
    contentSize = [MUKGridView contentSizeForDirection_:direction cellSize_:cellSize maxRows_:maxRows maxCellsPerRow_:maxCellsPerRow_v numberOfCells_:numberOfCells];
    STAssertEqualsWithAccuracy(cellSize.width * 4.0f, contentSize.width, 0.0000001, @"4 vertical columns");
    STAssertEqualsWithAccuracy(cellSize.height, contentSize.height, 0.0000001, @"One horizontal row");
    
    numberOfCells = 5;
    maxRows = [MUKGridView maxRowsForCellsCount_:numberOfCells maxCellsPerRow_:maxCellsPerRow_v direction_:direction];
    contentSize = [MUKGridView contentSizeForDirection_:direction cellSize_:cellSize maxRows_:maxRows maxCellsPerRow_:maxCellsPerRow_v numberOfCells_:numberOfCells];
    STAssertEqualsWithAccuracy(cellSize.width * 4.0f, contentSize.width, 0.0000001, @"4 vertical columns");
    STAssertEqualsWithAccuracy(cellSize.height * 2.0f, contentSize.height, 0.0000001, @"Two horizontal rows");
    
    numberOfCells = 41;
    maxRows = [MUKGridView maxRowsForCellsCount_:numberOfCells maxCellsPerRow_:maxCellsPerRow_v direction_:direction];
    contentSize = [MUKGridView contentSizeForDirection_:direction cellSize_:cellSize maxRows_:maxRows maxCellsPerRow_:maxCellsPerRow_v numberOfCells_:numberOfCells];
    STAssertEqualsWithAccuracy(cellSize.width * 4.0f, contentSize.width, 0.0000001, @"4 vertical columns");
    STAssertEqualsWithAccuracy(cellSize.height * 11.0f, contentSize.height, 0.0000001, @"11 horizontal rows");
}

- (void)testCellViewWithIndex {
    NSMutableSet *views = nil;
    MUKGridCellView_ *view = nil;
    NSInteger index = 1;
    
    view = [MUKGridView cellViewWithIndex_:index inViews_:views];
    STAssertNil(view, @"No views");
    
    views = [NSMutableSet set];
    view = [MUKGridView cellViewWithIndex_:index inViews_:views];
    STAssertNil(view, @"No views");
    
    [views addObject:[[MUKGridCellView_ alloc] init]];
    view = [MUKGridView cellViewWithIndex_:index inViews_:views];
    STAssertNil(view, @"No view matched");
    
    MUKGridCellView_ *viewWhichMatch = [[MUKGridCellView_ alloc] init];
    viewWhichMatch.cellIndex = index;
    [views addObject:viewWhichMatch];
    view = [MUKGridView cellViewWithIndex_:index inViews_:views];
    STAssertNotNil(view, @"View should be found");
    STAssertEqualObjects(view, viewWhichMatch, @"View should be found");
}

- (void)testCellFrame {
    NSInteger maxCellsPerRow = 4;
    CGSize cellSize = CGSizeMake(50, 60);
    MUKGridDirection direction = MUKGridDirectionVertical;
    
    NSInteger cellIndex = 0;
    CGRect cellFrame = [MUKGridView frameOfCellAtIndex_:cellIndex cellSize_:cellSize maxCellsPerRow_:maxCellsPerRow direction_:direction];
    STAssertTrue(CGSizeEqualToSize(cellFrame.size, cellSize), @"Cell size preserved");
    STAssertEqualsWithAccuracy(0.0f, cellFrame.origin.y, 0.0000001, @"Origin");
    STAssertEqualsWithAccuracy(0.0f, cellFrame.origin.x, 0.0000001, @"Origin");
    
    cellIndex = 6;
    cellFrame = [MUKGridView frameOfCellAtIndex_:cellIndex cellSize_:cellSize maxCellsPerRow_:maxCellsPerRow direction_:direction];
    STAssertTrue(CGSizeEqualToSize(cellFrame.size, cellSize), @"Cell size preserved");
    STAssertEqualsWithAccuracy(cellSize.height, cellFrame.origin.y, 0.0000001, @"Coord: (1, 2)");
    STAssertEqualsWithAccuracy(cellSize.width * 2.0f, cellFrame.origin.x, 0.0000001, @"Coord: (1, 2)");
    
    
    
    // Horizontal (vertical rows)
    direction = MUKGridDirectionHorizontal;
    
    cellIndex = 0;
    cellFrame = [MUKGridView frameOfCellAtIndex_:cellIndex cellSize_:cellSize maxCellsPerRow_:maxCellsPerRow direction_:direction];
    STAssertTrue(CGSizeEqualToSize(cellFrame.size, cellSize), @"Cell size preserved");
    STAssertEqualsWithAccuracy(0.0f, cellFrame.origin.y, 0.0000001, @"Origin");
    STAssertEqualsWithAccuracy(0.0f, cellFrame.origin.x, 0.0000001, @"Origin");
    
    cellIndex = 6;
    cellFrame = [MUKGridView frameOfCellAtIndex_:cellIndex cellSize_:cellSize maxCellsPerRow_:maxCellsPerRow direction_:direction];
    STAssertTrue(CGSizeEqualToSize(cellFrame.size, cellSize), @"Cell size preserved");
    STAssertEqualsWithAccuracy(cellSize.width, cellFrame.origin.x, 0.0000001, @"Coord: (1, 2)");
    STAssertEqualsWithAccuracy(cellSize.height * 2.0f, cellFrame.origin.y, 0.0000001, @"Coord: (1, 2)");
}

- (void)layoutCell {
    CGRect gridRect = CGRectMake(0, 0, 200, 200);
    GridViewMock *gridView = [[GridViewMock alloc] initWithFrame:gridRect];
    
    /*
     Layout a cell which is not existing
     */
    [gridView layoutCellAtIndex_:0 visibleCells_:[gridView visibleViews] maxCellsPerRow_:4];
    STAssertEquals((NSUInteger)0, [[gridView visibleViews] count], @"No visible views");
    STAssertEquals((NSUInteger)0, [[gridView subviews] count], @"No subviews");
    
    /*
     Layout a cell which is not existing,
     but is fed by the handler
     */
    __block BOOL creationHandlerCalled = NO;
    MUKRecyclableView *cellView = [[MUKRecyclableView alloc] init];
    cellView.recycleIdentifier = @"Foo";
    [gridView setCellCreationHandler:^UIView<MUKRecyclable> *(NSInteger index)
    {
        creationHandlerCalled = YES;
        return cellView;
    }];
    
    NSInteger cellIndex = 10;
    MUKGridCellView_ *returnedCellView = [gridView layoutCellAtIndex_:cellIndex visibleCells_:[gridView visibleViews] maxCellsPerRow_:4];
    STAssertTrue(creationHandlerCalled, @"Creation handler should be called");
    STAssertEquals((NSUInteger)1, [[gridView visibleViews] count], @"A visible view");
    STAssertEquals((NSUInteger)1, [[gridView subviews] count], @"A subview");
    
    id view = [[gridView visibleViews] anyObject];
    STAssertEqualObjects(view, cellView, nil);
    
    view = [[gridView subviews] lastObject];
    STAssertEqualObjects(view, cellView, nil);
    
    STAssertEquals(cellIndex, returnedCellView.cellIndex, nil);
    
    /*
     Layout a cell which exists (both index and identifier),
     so is reused from visibleViews set
     */
    creationHandlerCalled = NO;
    cellView = [[MUKRecyclableView alloc] init];
    cellView.recycleIdentifier = @"Foo";
    [gridView setCellCreationHandler:^UIView<MUKRecyclable> *(NSInteger index)
     {
         creationHandlerCalled = YES;
         return cellView;
     }];
    
    cellIndex = 10;
    returnedCellView = [gridView layoutCellAtIndex_:cellIndex visibleCells_:[gridView visibleViews] maxCellsPerRow_:4];
    STAssertFalse(creationHandlerCalled, @"Creation handler should not be called again");
    STAssertEquals((NSUInteger)1, [[gridView visibleViews] count], @"A visible view");
    STAssertEquals((NSUInteger)1, [[gridView subviews] count], @"A subview");
    
    view = [[gridView visibleViews] anyObject];
    STAssertEqualObjects(view, cellView, nil);
    
    view = [[gridView subviews] lastObject];
    STAssertEqualObjects(view, cellView, nil);
    
    STAssertEquals(cellIndex, returnedCellView.cellIndex, nil);
    
    /*
     Layout a cell which exists (only identifier),
     so is recycled from enqueued views
     */
    creationHandlerCalled = NO;
    cellView = [[MUKRecyclableView alloc] init];
    cellView.recycleIdentifier = @"Foo";
    
    __block BOOL recycledCell = NO;
    __unsafe_unretained GridViewMock *weakGridView = gridView;
    [gridView setCellCreationHandler:^UIView<MUKRecyclable> *(NSInteger index)
     {
         UIView<MUKRecyclable> *returnedCell = [weakGridView dequeueViewWithIdentifier:@"Foo"];
         recycledCell = (returnedCell != nil);
         creationHandlerCalled = YES;
         return returnedCell;
     }];
    
    cellIndex = 1000;
    [gridView enqueueVisibleViews];
    returnedCellView = [gridView layoutCellAtIndex_:cellIndex visibleCells_:[gridView visibleViews] maxCellsPerRow_:4];
    
    STAssertTrue(creationHandlerCalled, @"Creation handler should be called again");
    STAssertTrue(recycledCell, @"Cell should be recycled by handler");
    
    STAssertEquals((NSUInteger)1, [[gridView visibleViews] count], @"A visible view");
    STAssertEquals((NSUInteger)1, [[gridView subviews] count], @"A subview");
    
    view = [[gridView visibleViews] anyObject];
    STAssertEqualObjects(view, cellView, nil);
    
    view = [[gridView subviews] lastObject];
    STAssertEqualObjects(view, cellView, nil);
    
    STAssertEquals(cellIndex, returnedCellView.cellIndex, nil);
}

- (void)testHostCellViews {
    MUKRecyclableView *guestView = [[MUKRecyclableView alloc] init];
    guestView.recycleIdentifier = @"Foo";
    
    MUKGridCellView_ *cellView = [[MUKGridCellView_ alloc] init];
    cellView.guestView = guestView;
    
    MUKGridView *gridView = [[MUKGridView alloc] init];

    [gridView addSubview:cellView];
    STAssertEquals((NSUInteger)1, [[gridView visibleHostCellViews_] count], nil);
    [[gridView visibleHostCellViews_] enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
     {
         STAssertTrue([obj isMemberOfClass:[MUKGridCellView_ class]], nil);
     }];
    
    [gridView enqueueView:cellView];
    STAssertEquals((NSUInteger)1, [[gridView enqueuedHostCellViews_] count], nil);
    [[gridView enqueuedHostCellViews_] enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
    {
        STAssertTrue([obj isMemberOfClass:[MUKGridCellView_ class]], nil);
    }];
}

- (void)testNormalizedVisibleBounds {
    CGRect gridFrame = CGRectMake(0, 0, 200, 200);
    MUKGridView *gridView = [[MUKGridView alloc] initWithFrame:gridFrame];
    gridView.direction = MUKGridDirectionVertical;
    
    CGRect naturalBounds = gridView.bounds;
    CGRect normalizedBounds = [gridView normalizedVisibleBounds_];
    STAssertTrue(CGRectEqualToRect(normalizedBounds, naturalBounds), nil);
    
    gridView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    naturalBounds = gridView.bounds;
    normalizedBounds = [gridView normalizedVisibleBounds_];
    STAssertTrue(CGRectEqualToRect(normalizedBounds, naturalBounds), @"Insets are ignored");
    
    UIView *tailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    gridView.tailView = tailView;
    naturalBounds = gridView.bounds;
    normalizedBounds = [gridView normalizedVisibleBounds_];
    STAssertTrue(CGRectEqualToRect(normalizedBounds, naturalBounds), @"Tail view is ignored");
    
    /*
     Head view is subtracted, so all cell calculations are done without it
     */
    CGFloat origin = -gridView.contentInset.top;
    CGRect headViewFrame = CGRectMake(0, 0, 200, 50);
    UIView *headView = [[UIView alloc] initWithFrame:headViewFrame];
    gridView.headView = headView;
    CGFloat scrollTarget = origin;
    [gridView setContentOffset:CGPointMake(0, scrollTarget) animated:NO]; // Scroll to top
    [gridView layoutSubviews];
    naturalBounds = gridView.bounds;
    normalizedBounds = [gridView normalizedVisibleBounds_];
    STAssertFalse(CGRectEqualToRect(normalizedBounds, naturalBounds), @"Head view is not ignored");
    STAssertEqualsWithAccuracy(naturalBounds.origin.x, normalizedBounds.origin.x, 0.0000001f, nil);
    STAssertEqualsWithAccuracy(origin, normalizedBounds.origin.y, 0.0000001f, @"Shifted to origin");
    STAssertEqualsWithAccuracy(naturalBounds.size.width, normalizedBounds.size.width, 0.0000001f, nil);
    STAssertEqualsWithAccuracy(naturalBounds.size.height-headViewFrame.size.height, normalizedBounds.size.height, 0.0000001f, @"All head is shown");
    
    /*
     Scroll down a bit
     */
    CGFloat scrollDistance = headViewFrame.size.height/2.0f;
    scrollTarget = origin + scrollDistance;
    [gridView setContentOffset:CGPointMake(0, scrollTarget) animated:NO]; // Scroll a bit down
    [gridView layoutSubviews];
    naturalBounds = gridView.bounds;
    normalizedBounds = [gridView normalizedVisibleBounds_];
    STAssertFalse(CGRectEqualToRect(normalizedBounds, naturalBounds), @"Head view is not ignored");
    STAssertEqualsWithAccuracy(naturalBounds.origin.x, normalizedBounds.origin.x, 0.0000001f, nil);
    STAssertEqualsWithAccuracy(origin, normalizedBounds.origin.y, 0.0000001f, @"Shifted to scroll point");
    STAssertEqualsWithAccuracy(naturalBounds.size.width, normalizedBounds.size.width, 0.0000001f, nil);
    STAssertEqualsWithAccuracy(naturalBounds.size.height-scrollDistance, normalizedBounds.size.height, 0.0000001f, @"A piece of head is shown");
    
    /*
     Scroll down another bit, hiding head
     */
    scrollDistance = headViewFrame.size.height * 1.1f;;
    scrollTarget = origin + scrollDistance;
    [gridView setContentOffset:CGPointMake(0, scrollTarget) animated:NO]; // Scroll a bit down
    [gridView layoutSubviews];
    naturalBounds = gridView.bounds;
    normalizedBounds = [gridView normalizedVisibleBounds_];
    STAssertFalse(CGRectEqualToRect(normalizedBounds, naturalBounds), @"Head view is not ignored");
    STAssertEqualsWithAccuracy(naturalBounds.origin.x, normalizedBounds.origin.x, 0.0000001f, nil);
    STAssertEqualsWithAccuracy(naturalBounds.origin.y-headViewFrame.size.height, normalizedBounds.origin.y, 0.0000001f, @"Head is hidden");
    STAssertEqualsWithAccuracy(naturalBounds.size.width, normalizedBounds.size.width, 0.0000001f, nil);
    STAssertEqualsWithAccuracy(naturalBounds.size.height, normalizedBounds.size.height, 0.0000001f, @"Head is hidden");
}

- (void)testHeadViewFrame {
    CGRect gridFrame = CGRectMake(0, 0, 200, 200);
    CGRect headViewOriginalFrame = CGRectMake(20, 20, 300, 100);
    UIView *headView = [[UIView alloc] initWithFrame:headViewOriginalFrame];
    
    CGRect headFrame = [MUKGridView headView_:headView frameInBoundsSize_:gridFrame.size direction_:MUKGridDirectionVertical];
    STAssertTrue(CGPointEqualToPoint(CGPointZero, headFrame.origin), nil);
    STAssertEqualsWithAccuracy(headFrame.size.width, gridFrame.size.width, 0.00001f, @"Width to fill grid");
    STAssertEqualsWithAccuracy(headFrame.size.height, headViewOriginalFrame.size.height, 0.000001f, @"Height preserved");
    
    // Horizontal
    headViewOriginalFrame = CGRectMake(20, 20, 100, 300);
    headView = [[UIView alloc] initWithFrame:headViewOriginalFrame];
    
    headFrame = [MUKGridView headView_:headView frameInBoundsSize_:gridFrame.size direction_:MUKGridDirectionHorizontal];
    STAssertTrue(CGPointEqualToPoint(CGPointZero, headFrame.origin), nil);
    STAssertEqualsWithAccuracy(headFrame.size.width, headViewOriginalFrame.size.width, 0.00001f, @"Width preserved");
    STAssertEqualsWithAccuracy(headFrame.size.height, gridFrame.size.height, 0.000001f, @"Height to fill grid");
}

- (void)testTailViewFrame {
    CGRect gridFrame = CGRectMake(0, 0, 200, 200);
    CGRect tailViewOriginalFrame = CGRectMake(20, 20, 300, 100);
    UIView *tailView = [[UIView alloc] initWithFrame:tailViewOriginalFrame];
    CGRect lastCellFrame = CGRectMake(20, 20, 20, 20);
    
    CGRect tailFrame = [MUKGridView tailView_:tailView frameInBoundsSize_:gridFrame.size lastCellFrame:lastCellFrame direction_:MUKGridDirectionVertical];
    STAssertEqualsWithAccuracy(tailFrame.origin.x, 0.0f, 0.00001f, nil);
    STAssertEqualsWithAccuracy(tailFrame.origin.y, CGRectGetMaxY(lastCellFrame), 0.00001f, @"Under last cell");
    STAssertEqualsWithAccuracy(tailFrame.size.width, gridFrame.size.width, 0.00001f, @"Width to fill grid");
    STAssertEqualsWithAccuracy(tailFrame.size.height, tailViewOriginalFrame.size.height, 0.000001f, @"Height preserved");
    
    // Horizontal
    tailViewOriginalFrame = CGRectMake(20, 20, 100, 300);
    tailView = [[UIView alloc] initWithFrame:tailViewOriginalFrame];
    
    tailFrame = [MUKGridView tailView_:tailView frameInBoundsSize_:gridFrame.size lastCellFrame:lastCellFrame direction_:MUKGridDirectionHorizontal];
    STAssertEqualsWithAccuracy(tailFrame.origin.y, 0.0f, 0.00001f, nil);
    STAssertEqualsWithAccuracy(tailFrame.origin.x, CGRectGetMaxX(lastCellFrame), 0.00001f, @"At last cell right");
    STAssertEqualsWithAccuracy(tailFrame.size.width, tailViewOriginalFrame.size.width, 0.00001f, @"Width preserved");
    STAssertEqualsWithAccuracy(tailFrame.size.height, gridFrame.size.height, 0.000001f, @"Height to fill grid");
}

#pragma mark - Cell View

- (void)testCellViewIdentifier {
    NSString *identifier = @"Foo";
    
    MUKRecyclableView *guestView = [[MUKRecyclableView alloc] init];
    guestView.recycleIdentifier = identifier;
    
    MUKGridCellView_ *cellView = [[MUKGridCellView_ alloc] init];
    cellView.guestView = guestView;
    STAssertEqualObjects(cellView.recycleIdentifier, identifier, @"Recycle identifier is guest view's");
    
    identifier = @"Bar";
    cellView.recycleIdentifier = identifier;
    STAssertEqualObjects(guestView.recycleIdentifier, identifier, @"Cell view set identifier to guest");
}

- (void)testCellViewGuestFrame {
    CGRect guestFrame = CGRectMake(10, 10, 100, 100);
    CGRect cellFrame = CGRectMake(20, 20, 200, 158);
    
    MUKRecyclableView *guestView = [[MUKRecyclableView alloc] initWithFrame:guestFrame];
    MUKGridCellView_ *cellView = [[MUKGridCellView_ alloc] initWithFrame:cellFrame];
    cellView.guestView = guestView;
    
    STAssertTrue(CGRectEqualToRect(guestView.frame, cellView.bounds), @"Guest frame are cell bounds");
    
    cellFrame = CGRectMake(200, 20, 2000, 200);
    cellView.frame = cellFrame;
    STAssertTrue(CGRectEqualToRect(guestView.frame, cellView.bounds), @"Guest frame are cell bounds, also after resizing");
}

- (void)testTransformForScrollPosition {
    /*
     The only piece of logic is contained in the case of MUKGridScrollPositionNone
     */
    
    // Partially overlapped (cell comes a little before)
    MUKGridDirection direction = MUKGridDirectionVertical;
    CGRect cellFrame = CGRectMake(0, 50, 50, 50);
    CGRect bounds = CGRectMake(0, 80, 200, 200);
    MUKGeometryTransform transform = [MUKGridView geometryTransformForScrollPosition_:MUKGridScrollPositionNone direction_:direction cellFrame_:cellFrame visibleBounds_:bounds];
    STAssertEquals(MUKGeometryTransformTopLeft, transform, @"Scroll to head");
    
    // Partially overlapped (bounds come a little before)
    cellFrame = CGRectMake(0, 210, 50, 50);
    bounds = CGRectMake(0, 0, 200, 200);
    transform = [MUKGridView geometryTransformForScrollPosition_:MUKGridScrollPositionNone direction_:direction cellFrame_:cellFrame visibleBounds_:bounds];
    STAssertEquals(MUKGeometryTransformBottomLeft, transform, @"Scroll to tail");
    
    // Not overlapped (cell comes before)
    cellFrame = CGRectMake(0, 0, 50, 50);
    bounds = CGRectMake(0, 80, 200, 200);
    transform = [MUKGridView geometryTransformForScrollPosition_:MUKGridScrollPositionNone direction_:direction cellFrame_:cellFrame visibleBounds_:bounds];
    STAssertEquals(MUKGeometryTransformTopLeft, transform, @"Scroll to head");
    
    // Not overlapped (bounds come before)
    cellFrame = CGRectMake(0, 2100, 50, 50);
    bounds = CGRectMake(0, 0, 200, 200);
    transform = [MUKGridView geometryTransformForScrollPosition_:MUKGridScrollPositionNone direction_:direction cellFrame_:cellFrame visibleBounds_:bounds];
    STAssertEquals(MUKGeometryTransformBottomLeft, transform, @"Scroll to tail");
    
    // Overlapped
    cellFrame = CGRectMake(0, 50, 50, 50);
    bounds = CGRectMake(0, 0, 200, 200);
    transform = [MUKGridView geometryTransformForScrollPosition_:MUKGridScrollPositionNone direction_:direction cellFrame_:cellFrame visibleBounds_:bounds];
    STAssertEquals(MUKGeometryTransformIdentity, transform, @"Do not scroll");
    
    
    
    ////////////////
    // Horizontal //
    ////////////////
    direction = MUKGridDirectionHorizontal;
    
    // Partially overlapped (cell comes a little before)
    cellFrame = CGRectMake(50, 0, 50, 50);
    bounds = CGRectMake(80, 0, 200, 200);
    transform = [MUKGridView geometryTransformForScrollPosition_:MUKGridScrollPositionNone direction_:direction cellFrame_:cellFrame visibleBounds_:bounds];
    STAssertEquals(MUKGeometryTransformTopLeft, transform, @"Scroll to head");
    
    // Partially overlapped (bounds come a little before)
    cellFrame = CGRectMake(210, 0, 50, 50);
    bounds = CGRectMake(0, 0, 200, 200);
    transform = [MUKGridView geometryTransformForScrollPosition_:MUKGridScrollPositionNone direction_:direction cellFrame_:cellFrame visibleBounds_:bounds];
    STAssertEquals(MUKGeometryTransformTopRight, transform, @"Scroll to tail");
    
    // Not overlapped (cell comes before)
    cellFrame = CGRectMake(0, 0, 50, 50);
    bounds = CGRectMake(80, 0, 200, 200);
    transform = [MUKGridView geometryTransformForScrollPosition_:MUKGridScrollPositionNone direction_:direction cellFrame_:cellFrame visibleBounds_:bounds];
    STAssertEquals(MUKGeometryTransformTopLeft, transform, @"Scroll to head");
    
    // Not overlapped (bounds come before)
    cellFrame = CGRectMake(2100, 0, 50, 50);
    bounds = CGRectMake(0, 0, 200, 200);
    transform = [MUKGridView geometryTransformForScrollPosition_:MUKGridScrollPositionNone direction_:direction cellFrame_:cellFrame visibleBounds_:bounds];
    STAssertEquals(MUKGeometryTransformTopRight, transform, @"Scroll to tail");
    
    // Overlapped
    cellFrame = CGRectMake(50, 0, 50, 50);
    bounds = CGRectMake(0, 0, 200, 200);
    transform = [MUKGridView geometryTransformForScrollPosition_:MUKGridScrollPositionNone direction_:direction cellFrame_:cellFrame visibleBounds_:bounds];
    STAssertEquals(MUKGeometryTransformIdentity, transform, @"Do not scroll");
}

- (void)testBoundsFixing {
    MUKGridDirection direction = MUKGridDirectionVertical;
    CGRect bounds = CGRectMake(0, 50, 200, 200);
    CGSize containerSize = CGSizeMake(200, 500);
    
    CGRect fixedBounds = [MUKGridView bounds_:bounds inContainerSize_:containerSize direction_:direction];
    STAssertEqualsWithAccuracy(0.0f, fixedBounds.origin.x, 0.0000001, @"Aligned to left");
    STAssertEqualsWithAccuracy(bounds.origin.y, fixedBounds.origin.y, 0.0000001, @"Preserved");
    STAssertTrue(CGSizeEqualToSize(bounds.size, fixedBounds.size), @"Preserved");
    
    // Too up
    bounds.origin.y = -100.0;
    fixedBounds = [MUKGridView bounds_:bounds inContainerSize_:containerSize direction_:direction];
    STAssertEqualsWithAccuracy(0.0f, fixedBounds.origin.x, 0.0000001, @"Aligned to left");
    STAssertEqualsWithAccuracy(0.0f, fixedBounds.origin.y, 0.0000001, @"Aligned to top");
    STAssertTrue(CGSizeEqualToSize(bounds.size, fixedBounds.size), @"Preserved");
    
    // Too down
    bounds.origin.y = containerSize.height + 100.0;
    fixedBounds = [MUKGridView bounds_:bounds inContainerSize_:containerSize direction_:direction];
    STAssertEqualsWithAccuracy(0.0f, fixedBounds.origin.x, 0.0000001, @"Aligned to left");
    STAssertEqualsWithAccuracy(containerSize.height-fixedBounds.size.height, fixedBounds.origin.y, 0.0000001, @"Aligned to bottom");
    STAssertTrue(CGSizeEqualToSize(bounds.size, fixedBounds.size), @"Preserved");
    
    
    
    // Horizontal
    direction = MUKGridDirectionHorizontal;
    bounds = CGRectMake(50, 0, 200, 200);
    containerSize = CGSizeMake(500, 200);
    
    fixedBounds = [MUKGridView bounds_:bounds inContainerSize_:containerSize direction_:direction];
    STAssertEqualsWithAccuracy(0.0f, fixedBounds.origin.y, 0.0000001, @"Aligned to top");
    STAssertEqualsWithAccuracy(bounds.origin.x, fixedBounds.origin.x, 0.0000001, @"Preserved");
    STAssertTrue(CGSizeEqualToSize(bounds.size, fixedBounds.size), @"Preserved");
    
    // Too left
    bounds.origin.x = -100.0;
    fixedBounds = [MUKGridView bounds_:bounds inContainerSize_:containerSize direction_:direction];
    STAssertEqualsWithAccuracy(0.0f, fixedBounds.origin.y, 0.0000001, @"Aligned to top");
    STAssertEqualsWithAccuracy(0.0f, fixedBounds.origin.y, 0.0000001, @"Aligned to left");
    STAssertTrue(CGSizeEqualToSize(bounds.size, fixedBounds.size), @"Preserved");
    
    // Too right
    bounds.origin.x = containerSize.width + 100.0;
    fixedBounds = [MUKGridView bounds_:bounds inContainerSize_:containerSize direction_:direction];
    STAssertEqualsWithAccuracy(0.0f, fixedBounds.origin.y, 0.0000001, @"Aligned to top");
    STAssertEqualsWithAccuracy(containerSize.width-fixedBounds.size.width, fixedBounds.origin.x, 0.0000001, @"Aligned to right");
    STAssertTrue(CGSizeEqualToSize(bounds.size, fixedBounds.size), @"Preserved");
}

- (void)testCellZoomingEnabled {
    MUKGridCellView_ *cellView = [[MUKGridCellView_ alloc] init];
    
    STAssertFalse([cellView isZoomingEnabled], @"Zooming is disabled by default");
    
    cellView.minimumZoomScale = 1.0;
    cellView.maximumZoomScale = 3.0;
    STAssertTrue([cellView isZoomingEnabled], @"Zooming is enabled with different min/max scales");
}

@end
