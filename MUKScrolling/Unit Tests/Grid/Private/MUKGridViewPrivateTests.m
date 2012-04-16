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

#import "MUKGridView.h"
#import "MUKGridCellView_.h"
#import "MUKDummyRecyclableView.h"

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

#pragma mark - Layout

- (void)testContentSize {
    CGSize gridSize = CGSizeMake(200, 200);
    CGSize cellSize = CGSizeMake(50, 60);
    
    NSInteger maxCellsPerRow_h = [MUKGridView maxCellsPerRowInContainerSize_:gridSize cellSize_:cellSize direction_:MUKGridDirectionHorizontal];
    NSInteger maxCellsPerRow_v = [MUKGridView maxCellsPerRowInContainerSize_:gridSize cellSize_:cellSize direction_:MUKGridDirectionVertical];
    
    NSInteger maxRows = [MUKGridView maxRowsForCellsCount_:0 maxCellsPerRow_:maxCellsPerRow_h direction_:MUKGridDirectionHorizontal];
    CGSize contentSize = [MUKGridView contentSizeForDirection_:MUKGridDirectionHorizontal containerSize_:gridSize cellSize_:cellSize maxRows_:maxRows];
    STAssertEqualsWithAccuracy(gridSize.height, contentSize.height, 0.0000001, @"Also with no cells, height should be preserved with horizontal direction");
    STAssertEqualsWithAccuracy(0.0f, contentSize.width, 0.0000001, @"No cells, no width");
    
    maxRows = [MUKGridView maxRowsForCellsCount_:1 maxCellsPerRow_:maxCellsPerRow_h direction_:MUKGridDirectionHorizontal];
    contentSize = [MUKGridView contentSizeForDirection_:MUKGridDirectionHorizontal containerSize_:gridSize cellSize_:cellSize maxRows_:maxRows];
    STAssertEqualsWithAccuracy(gridSize.height, contentSize.height, 0.0000001, @"Height should be preserved with horizontal direction");
    STAssertEqualsWithAccuracy(cellSize.width, contentSize.width, 0.0000001, @"One vertical row");
    
    // Look at previous -testMaxCellsForRow
    maxRows = [MUKGridView maxRowsForCellsCount_:3 maxCellsPerRow_:maxCellsPerRow_h direction_:MUKGridDirectionHorizontal];
    contentSize = [MUKGridView contentSizeForDirection_:MUKGridDirectionHorizontal containerSize_:gridSize cellSize_:cellSize maxRows_:maxRows];
    STAssertEqualsWithAccuracy(gridSize.height, contentSize.height, 0.0000001, @"Height should be preserved with horizontal direction");
    STAssertEqualsWithAccuracy(cellSize.width, contentSize.width, 0.0000001, @"One vertical row");
    
    maxRows = [MUKGridView maxRowsForCellsCount_:4 maxCellsPerRow_:maxCellsPerRow_h direction_:MUKGridDirectionHorizontal];
    contentSize = [MUKGridView contentSizeForDirection_:MUKGridDirectionHorizontal containerSize_:gridSize cellSize_:cellSize maxRows_:maxRows];
    STAssertEqualsWithAccuracy(gridSize.height, contentSize.height, 0.0000001, @"Height should be preserved with horizontal direction");
    STAssertEqualsWithAccuracy(cellSize.width * 2.0f, contentSize.width, 0.0000001, @"Two vertical rows");
    
    maxRows = [MUKGridView maxRowsForCellsCount_:40 maxCellsPerRow_:maxCellsPerRow_h direction_:MUKGridDirectionHorizontal];
    contentSize = [MUKGridView contentSizeForDirection_:MUKGridDirectionHorizontal containerSize_:gridSize cellSize_:cellSize maxRows_:maxRows];
    STAssertEqualsWithAccuracy(gridSize.height, contentSize.height, 0.0000001, @"Height should be preserved with horizontal direction");
    STAssertEqualsWithAccuracy(cellSize.width * 14.0f, contentSize.width, 0.0000001, @"14 vertical rows");
    
    
    //////////////
    // Vertical //
    //////////////
    maxRows = [MUKGridView maxRowsForCellsCount_:0 maxCellsPerRow_:maxCellsPerRow_v direction_:MUKGridDirectionVertical];
    contentSize = [MUKGridView contentSizeForDirection_:MUKGridDirectionVertical containerSize_:gridSize cellSize_:cellSize maxRows_:maxRows];
    STAssertEqualsWithAccuracy(gridSize.width, contentSize.width, 0.0000001, @"Also with no cells, width should be preserved with vertical direction");
    STAssertEqualsWithAccuracy(0.0f, contentSize.height, 0.0000001, @"No cells, no height");
    
    maxRows = [MUKGridView maxRowsForCellsCount_:1 maxCellsPerRow_:maxCellsPerRow_v direction_:MUKGridDirectionVertical];
    contentSize = [MUKGridView contentSizeForDirection_:MUKGridDirectionVertical containerSize_:gridSize cellSize_:cellSize maxRows_:maxRows];
    STAssertEqualsWithAccuracy(gridSize.width, contentSize.width, 0.0000001, @"Width should be preserved with vertical direction");
    STAssertEqualsWithAccuracy(cellSize.height, contentSize.height, 0.0000001, @"One horizontal row");
    
    // Look at previous -testMaxCellsForRow
    maxRows = [MUKGridView maxRowsForCellsCount_:4 maxCellsPerRow_:maxCellsPerRow_v direction_:MUKGridDirectionVertical];
    contentSize = [MUKGridView contentSizeForDirection_:MUKGridDirectionVertical containerSize_:gridSize cellSize_:cellSize maxRows_:maxRows];
    STAssertEqualsWithAccuracy(gridSize.width, contentSize.width, 0.0000001, @"Width should be preserved with vertical direction");
    STAssertEqualsWithAccuracy(cellSize.height, contentSize.height, 0.0000001, @"One horizontal row");
    
    maxRows = [MUKGridView maxRowsForCellsCount_:5 maxCellsPerRow_:maxCellsPerRow_v direction_:MUKGridDirectionVertical];
    contentSize = [MUKGridView contentSizeForDirection_:MUKGridDirectionVertical containerSize_:gridSize cellSize_:cellSize maxRows_:maxRows];
    STAssertEqualsWithAccuracy(gridSize.width, contentSize.width, 0.0000001, @"Width should be preserved with vertical direction");
    STAssertEqualsWithAccuracy(cellSize.height * 2.0f, contentSize.height, 0.0000001, @"Two horizontal rows");
    
    maxRows = [MUKGridView maxRowsForCellsCount_:41 maxCellsPerRow_:maxCellsPerRow_v direction_:MUKGridDirectionVertical];
    contentSize = [MUKGridView contentSizeForDirection_:MUKGridDirectionVertical containerSize_:gridSize cellSize_:cellSize maxRows_:maxRows];
    STAssertEqualsWithAccuracy(gridSize.width, contentSize.width, 0.0000001, @"Width should be preserved with vertical direction");
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
    MUKDummyRecyclableView *cellView = [[MUKDummyRecyclableView alloc] init];
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
    cellView = [[MUKDummyRecyclableView alloc] init];
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
    cellView = [[MUKDummyRecyclableView alloc] init];
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
    MUKDummyRecyclableView *guestView = [[MUKDummyRecyclableView alloc] init];
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

#pragma mark - Cell View

- (void)testCellViewIdentifier {
    NSString *identifier = @"Foo";
    
    MUKDummyRecyclableView *guestView = [[MUKDummyRecyclableView alloc] init];
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
    
    MUKDummyRecyclableView *guestView = [[MUKDummyRecyclableView alloc] initWithFrame:guestFrame];
    MUKGridCellView_ *cellView = [[MUKGridCellView_ alloc] initWithFrame:cellFrame];
    cellView.guestView = guestView;
    
    STAssertTrue(CGRectEqualToRect(guestView.frame, cellView.bounds), @"Guest frame are cell bounds");
    
    cellFrame = CGRectMake(200, 20, 2000, 200);
    cellView.frame = cellFrame;
    STAssertTrue(CGRectEqualToRect(guestView.frame, cellView.bounds), @"Guest frame are cell bounds, also after resizing");
}

@end
