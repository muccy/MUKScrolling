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

#import "MUKGridView.h"

#import "MUKGridView_RowsAndColumns.h"
#import "MUKGridView_Layout.h"

#import "MUKGridCellView_.h"

#define DEBUG_STATS     1

@interface MUKGridView ()
- (void)commonIntialization_;
@end

@implementation MUKGridView
@synthesize direction = direction_;
@synthesize cellSize = cellSize_;
@synthesize numberOfCells = numberOfCells_;
@synthesize cellCreationHandler = cellCreationHandler_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonIntialization_];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonIntialization_];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonIntialization_];
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}

#pragma mark - Overrides

- (id<UIScrollViewDelegate>)delegate {
    return self;
}

- (void)layoutSubviews {
    // Recalculate content size everytime (useful during autorotations)
    [self adjustContentSize_];

    [super layoutSubviews];
    
#if DEBUG_STATS
    NSLog(@"=======");
    NSLog(@"Visible: %i", [[self visibleViews] count]);
    NSLog(@"Enqueued: %i", [[self enqueuedViews] count]);
    NSLog(@"Subviews: %i", [[self subviews] count]);
#endif
}

- (void)layoutViews:(NSSet *)visibleViews forVisibleBounds:(CGRect)bounds {
    [super layoutViews:visibleViews forVisibleBounds:bounds];
    
    // Take involved indexes
    NSIndexSet *cellIndexes = [self indexesOfCellsInVisibleBounds:bounds];

    // Layout cells at those coordinates
    CGSize cellSize = [self.cellSize sizeRespectSize:self.bounds.size];
    NSInteger maxCellsPerRow = [[self class] maxCellsPerRowInContainerSize_:self.frame.size cellSize_:cellSize direction_:self.direction];
    [self layoutCellsAtIndexes_:cellIndexes visibleCells_:visibleViews maxCellsPerRow_:maxCellsPerRow];
}

- (NSSet *)visibleViews {
    // Do not expose MUKGridCellView_
    return [[super visibleViews] valueForKey:@"guestView"];
}

- (NSSet *)enqueuedViews {
    // Do not expose MUKGridCellView_
    return [[super enqueuedViews] valueForKey:@"guestView"];
}

- (UIView<MUKRecyclable> *)dequeueViewWithIdentifier:(NSString *)recycleIdentifier
{
    UIView<MUKRecyclable> *cellView = [super dequeueViewWithIdentifier:recycleIdentifier];
    
    if ([cellView isKindOfClass:[MUKGridCellView_ class]]) {
        return [(MUKGridCellView_ *)cellView guestView];
    }
    
    return cellView;
}

#pragma mark - Methods

- (void)reloadData {
    [self adjustContentSize_];
    
    // Empty view and enqueue subviews for reuse
    [[self visibleHostCellViews_] enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self enqueueView:obj];
    }];
    
    // Relayout everything
    [self layoutRecyclableSubviews];
}

- (NSIndexSet *)indexesOfVisibleCells {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    

    
    return indexSet;
}

#pragma mark - Layout

- (NSIndexSet *)indexesOfCellsInVisibleBounds:(CGRect)visibleBounds {
    // Take coordinates
    CGSize cellSize = [self.cellSize sizeRespectSize:self.bounds.size];
    NSInteger maxCellsPerRow = [[self class] maxCellsPerRowInContainerSize_:self.frame.size cellSize_:cellSize direction_:self.direction];
    NSArray *coordinates = [[self class] coordinatesOfCellsOfSize_:cellSize inVisibleBounds_:visibleBounds direction_:self.direction];
    
    // Convert to indexes
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [coordinates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
    {
        MUKGridCoordinate *coordinate = obj;
        NSInteger index = [coordinate cellIndexWithMaxCellsPerRow:maxCellsPerRow];
        
        // Validate index
        if (index >= 0 && index < self.numberOfCells) {
            [indexSet addIndex:index];
        }
    }];
    
    return indexSet;
}

- (UIView<MUKRecyclable> *)createCellViewAtIndex:(NSInteger)index {
    if (self.cellCreationHandler) {
        return self.cellCreationHandler(index);
    }
    
    return nil;
}

- (CGRect)frameOfCellAtIndex:(NSInteger)index {
    CGSize cellSize = [self.cellSize sizeRespectSize:self.bounds.size];
    NSInteger maxCellsPerRow = [[self class] maxCellsPerRowInContainerSize_:self.frame.size cellSize_:cellSize direction_:self.direction];
    
    return [[self class] frameOfCellAtIndex_:index cellSize_:cellSize maxCellsPerRow_:maxCellsPerRow direction_:self.direction];
}

#pragma mark - Private

- (void)commonIntialization_ {
    //
}

- (NSSet *)visibleHostCellViews_ {
    return [super visibleViews];
}

- (NSSet *)enqueuedHostCellViews_ {
    return [super enqueuedViews];
}

#pragma mark - Private: Layout

+ (MUKGridCellView_ *)cellViewWithIndex_:(NSInteger)index inViews_:(NSSet *)views
{
    __block MUKGridCellView_ *cellView = nil;
    
    [views enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([obj isKindOfClass:[MUKGridCellView_ class]]) {
            MUKGridCellView_ *v = obj;
            if (v.cellIndex == index) {
                cellView = v;
                *stop = YES;
            }
        }
    }];
    
    return cellView;
}

+ (CGRect)frameOfCellAtIndex_:(NSInteger)index cellSize_:(CGSize)cellSize maxCellsPerRow_:(NSInteger)maxCellsPerRow direction_:(MUKGridDirection)direction
{
    CGRect cellFrame;
    cellFrame.size = cellSize;
    
    MUKGridCoordinate *coordinate = [[MUKGridCoordinate alloc] init];
    [coordinate setCellIndex:index withMaxCellsPerRow:maxCellsPerRow];
    
    if (MUKGridDirectionVertical == direction) {
        cellFrame.origin.x = coordinate.column * cellSize.width;
        cellFrame.origin.y = coordinate.row * cellSize.height;
    }
    else {
        cellFrame.origin.x = coordinate.row * cellSize.width;
        cellFrame.origin.y = coordinate.column * cellSize.height;
    }
    
    return cellFrame;
}

- (void)layoutCellsAtIndexes_:(NSIndexSet *)indexes visibleCells_:(NSSet *)visibleCells maxCellsPerRow_:(NSInteger)maxCellsPerRow
{
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self layoutCellAtIndex_:idx visibleCells_:visibleCells maxCellsPerRow_:maxCellsPerRow];
    }];
}

- (MUKGridCellView_ *)layoutCellAtIndex_:(NSInteger)index visibleCells_:(NSSet *)visibleCells maxCellsPerRow_:(NSInteger)maxCellsPerRow
{
    MUKGridCellView_ *cellView = [[self class] cellViewWithIndex_:index inViews_:visibleCells];
    
    CGRect cellFrame = [self frameOfCellAtIndex:index];
    
    // Create if not found
    if (cellView == nil) {
        UIView<MUKRecyclable> *guestView = [self createCellViewAtIndex:index];
        cellView = [[MUKGridCellView_ alloc] initWithFrame:cellFrame];
        cellView.guestView = guestView;
        cellView.cellIndex = index;
        
        [self addSubview:cellView];
    }
    else {
        // If found, adjust frame
        cellView.frame = cellFrame;
    }
    
    return cellView;
}

+ (CGSize)contentSizeForDirection_:(MUKGridDirection)direction containerSize_:(CGSize)containerSize cellSize_:(CGSize)cellSize maxRows_:(NSInteger)maxRows
{
    CGSize size = CGSizeZero;
    
    switch (direction) {
        case MUKGridDirectionHorizontal:
            size.width = cellSize.width * maxRows;
            size.height = containerSize.height;
            break;
            
        case MUKGridDirectionVertical:
            size.width = containerSize.width;
            size.height = cellSize.height * maxRows;
            break;
    }

    return size;
}

- (void)adjustContentSize_ {
    CGSize cellSize = [self.cellSize sizeRespectSize:self.frame.size];
    NSInteger maxCellsPerRow = [[self class] maxCellsPerRowInContainerSize_:self.frame.size cellSize_:cellSize direction_:self.direction];
    NSInteger maxRows = [[self class] maxRowsForCellsCount_:self.numberOfCells maxCellsPerRow_:maxCellsPerRow direction_:self.direction];
    self.contentSize = [[self class] contentSizeForDirection_:self.direction containerSize_:self.frame.size cellSize_:cellSize maxRows_:maxRows];
}

#pragma mark - Private: Rows & Columns

+ (NSInteger)maxCellsPerRowInContainerSize_:(CGSize)containerSize cellSize_:(CGSize)cellSize direction_:(MUKGridDirection)direction
{
    CGFloat containerDimension, cellDimension;
    if (MUKGridDirectionHorizontal == direction) {
        // Vertical rows
        containerDimension = containerSize.height;
        cellDimension = cellSize.height;
    }
    else {
        // Horizontal rows
        containerDimension = containerSize.width;
        cellDimension = cellSize.width;
    }
    
    return floorf(containerDimension/cellDimension);
}

+ (NSInteger)maxRowsForCellsCount_:(NSInteger)cellsCount maxCellsPerRow_:(NSInteger)maxCellsPerRow direction_:(MUKGridDirection)direction
{
    if (cellsCount == 0 || maxCellsPerRow == 0) return 0;

    NSInteger naturalRows = cellsCount/maxCellsPerRow;
    NSInteger rows = (cellsCount % maxCellsPerRow == 0 ? naturalRows : naturalRows+1);
    return rows;
}

+ (MUKGridCoordinate *)coordinateOfCellOfSize_:(CGSize)cellSize atPoint:(CGPoint)point direction_:(MUKGridDirection)direction decimalRow_:(CGFloat *)decimalRow decimalColumn_:(CGFloat *)decimalColumn
{
    MUKGridCoordinate *coordinate;
    
    switch (direction) {
        case MUKGridDirectionVertical: {
            // Horizontal rows
            CGFloat r = point.y/cellSize.height;
            CGFloat c = point.x/cellSize.width;
            
            coordinate = [[MUKGridCoordinate alloc] init];
            coordinate.row = floorf(r);
            coordinate.column = floorf(c);
            
            if (decimalRow)     *decimalRow = r;
            if (decimalColumn)  *decimalColumn = c;
            
            break;
        }
                        
        case MUKGridDirectionHorizontal: {
            // Vertical rows
            CGFloat r = point.x/cellSize.width;
            CGFloat c = point.y/cellSize.height;
            
            coordinate = [[MUKGridCoordinate alloc] init];
            coordinate.row = floorf(r);
            coordinate.column = floorf(c);
            
            if (decimalRow)     *decimalRow = r;
            if (decimalColumn)  *decimalColumn = c;
            
            break;
        }
            
        default:
            coordinate = nil;
            break;
    }
    
    return coordinate;
}

+ (NSArray *)coordinatesOfCellsOfSize_:(CGSize)cellSize inVisibleBounds_:(CGRect)visibleBounds direction_:(MUKGridDirection)direction;
{
    MUKGridCoordinate *firstCellCoordinate = [self coordinateOfCellOfSize_:cellSize atPoint:visibleBounds.origin direction_:direction decimalRow_:NULL decimalColumn_:NULL];
    
    CGPoint bottomDownPoint = CGPointMake(CGRectGetMaxX(visibleBounds), CGRectGetMaxY(visibleBounds));
    CGFloat row = 0.0, column = 0.0;
    MUKGridCoordinate *lastCellCoordinate = [self coordinateOfCellOfSize_:cellSize atPoint:bottomDownPoint direction_:direction decimalRow_:&row decimalColumn_:&column];
    
    if (ABS(row - (CGFloat)lastCellCoordinate.row) < 0.000001) {
        // No carry means that bottom down point is exactly between two cells
        // and we took next cell!!!
        lastCellCoordinate.row--;
    }
    
    if (ABS(column - (CGFloat)lastCellCoordinate.column) < 0.000001) {
        // No carry means that bottom down point is exactly between two cells
        // and we took next cell!!!
        lastCellCoordinate.column--;
    }
    
    return [MUKGridCoordinate coordinatesInRectangleBetweenCoordinate:firstCellCoordinate andCoordinate:lastCellCoordinate];
}

@end
