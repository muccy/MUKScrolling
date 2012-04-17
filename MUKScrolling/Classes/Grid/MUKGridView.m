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

#define DEBUG_STATS     0

@interface MUKGridView ()
- (void)commonIntialization_;
- (void)setScrollViewDelegate_:(id<UIScrollViewDelegate>)scrollViewDelegate;
- (void)handleCellTap_:(UITapGestureRecognizer *)recognizer;
@end

@implementation MUKGridView {
    BOOL signalScrollCompletionInLayoutSubviews_;
    MUKGridScrollKind scrollKindToSignal_;
}
@synthesize direction = direction_;
@synthesize cellSize = cellSize_;
@synthesize numberOfCells = numberOfCells_;
@synthesize cellCreationHandler = cellCreationHandler_;
@synthesize scrollCompletionHandler = scrollCompletionHandler_;
@synthesize cellTapHandler = cellTapHandler_;

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
    [self setScrollViewDelegate_:nil];
}

#pragma mark - Overrides

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    // Disabled setter
}

- (void)layoutSubviews {
    // Recalculate content size everytime (useful during autorotations)
    [self adjustContentSize_];

    [super layoutSubviews];
    
    if (signalScrollCompletionInLayoutSubviews_) {
        [self didFinishScrollingOfKind:scrollKindToSignal_];
        signalScrollCompletionInLayoutSubviews_ = NO;
    }
    
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
    
    /*
     Enqueue visible views not in bounds.
     This may occur after autorotation.
     
     This job could be done into -shouldEnqueueView:forVisibleBounds: but
     I don't want to recalculate cellIndexes again.
     */
    NSMutableSet *filteredVisibleViews = [[NSMutableSet alloc] initWithCapacity:[visibleViews count]];
    [visibleViews enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        MUKGridCellView_ *cellView = obj;
        if ([cellIndexes containsIndex:cellView.cellIndex]) {
            // This view will be rendered
            [filteredVisibleViews addObject:cellView];
        }
        else {
            // This view is excluded
            [self enqueueView:cellView];
        }
    }];

    // Layout cells at those coordinates
    CGSize cellSize = [self.cellSize sizeRespectSize:self.bounds.size];
    NSInteger maxCellsPerRow = [[self class] maxCellsPerRowInContainerSize_:self.frame.size cellSize_:cellSize direction_:self.direction];
    [self layoutCellsAtIndexes_:cellIndexes visibleCells_:filteredVisibleViews maxCellsPerRow_:maxCellsPerRow];
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
    
    [[self visibleHostCellViews_] enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        MUKGridCellView_ *cellView = obj;
        [indexSet addIndex:cellView.cellIndex];
    }];
    
    return indexSet;
}

- (UIView<MUKRecyclable> *)cellViewAtIndex:(NSInteger)index {
    MUKGridCellView_ *cellView = [[self class] cellViewWithIndex_:index inViews_:[self visibleHostCellViews_]];
    return cellView.guestView;
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

#pragma mark - Scroll

- (void)scrollToCellAtIndex:(NSInteger)index position:(MUKGridScrollPosition)position animated:(BOOL)animated
{
    if (index < 0 || index >= self.numberOfCells) return;
    
    CGRect cellFrame = [self frameOfCellAtIndex:index];    
    MUKGeometryTransform transform = [[self class] geometryTransformForScrollPosition_:position direction_:self.direction cellFrame_:cellFrame visibleBounds_:self.bounds];
    
    // Move bounds to contain cell
    CGRect alignedBounds = [MUK rect:self.bounds transform:transform respectToRect:cellFrame];
    
    // Fix aligned bounds
    CGRect fixedBounds = [[self class] bounds_:alignedBounds inContainerSize_:self.contentSize direction_:self.direction];
    
    // Perform scroll
    [self setContentOffset:fixedBounds.origin animated:animated];
}

- (void)didFinishScrollingOfKind:(MUKGridScrollKind)scrollKind {
    if (self.scrollCompletionHandler) {
        self.scrollCompletionHandler(scrollKind);
    }
}

#pragma mark - Tap

- (void)didTapCellAtIndex:(NSInteger)index {
    if (self.cellTapHandler) {
        self.cellTapHandler(index);
    }
}

#pragma mark - Private

- (void)commonIntialization_ {
    [self setScrollViewDelegate_:self];
}

- (void)setScrollViewDelegate_:(id<UIScrollViewDelegate>)scrollViewDelegate 
{
    [super setDelegate:scrollViewDelegate];
}

- (void)handleCellTap_:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        MUKGridCellView_ *cellView = (MUKGridCellView_ *)recognizer.view;
        [self didTapCellAtIndex:cellView.cellIndex];
    }
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
        
        [cellView.singleTapGestureRecognizer addTarget:self action:@selector(handleCellTap_:)];
        
        [self addSubview:cellView];
    }
    else {
        // If found, adjust frame
        cellView.frame = cellFrame;
    }
    
    return cellView;
}

+ (CGSize)contentSizeForDirection_:(MUKGridDirection)direction cellSize_:(CGSize)cellSize maxRows_:(NSInteger)maxRows maxCellsPerRow_:(NSInteger)maxCellsPerRow numberOfCells_:(NSInteger)numberOfCells
{
    CGSize size = CGSizeZero;
    
    if (maxRows > 0) {
        switch (direction) {
            case MUKGridDirectionHorizontal:
                size.width = cellSize.width * maxRows;
                size.height = cellSize.height * MIN(numberOfCells, maxCellsPerRow);
                break;
                
            case MUKGridDirectionVertical:
                size.width = cellSize.width * MIN(numberOfCells, maxCellsPerRow);
                size.height = cellSize.height * maxRows;
                break;
        }
    }
    
    return size;
}

- (void)adjustContentSize_ {
    CGSize cellSize = [self.cellSize sizeRespectSize:self.bounds.size];
    NSInteger maxCellsPerRow = [[self class] maxCellsPerRowInContainerSize_:self.frame.size cellSize_:cellSize direction_:self.direction];
    NSInteger maxRows = [[self class] maxRowsForCellsCount_:self.numberOfCells maxCellsPerRow_:maxCellsPerRow direction_:self.direction];
    
    self.contentSize = [[self class] contentSizeForDirection_:self.direction cellSize_:cellSize maxRows_:maxRows maxCellsPerRow_:maxCellsPerRow numberOfCells_:self.numberOfCells];
}

- (NSSet *)visibleHostCellViews_ {
    return [super visibleViews];
}

- (NSSet *)enqueuedHostCellViews_ {
    return [super enqueuedViews];
}

+ (MUKGeometryTransform)geometryTransformForScrollPosition_:(MUKGridScrollPosition)position direction_:(MUKGridDirection)direction cellFrame_:(CGRect)cellFrame visibleBounds_:(CGRect)visibleBounds;
{
    if (MUKGridScrollPositionNone == position) {
        // Calculate position if cell is not shown
        
        if (!CGRectContainsRect(visibleBounds, cellFrame)) {
            // Cell not shown
            // Perform the minimum move
            CGFloat cellPos = (direction == MUKGridDirectionHorizontal ? cellFrame.origin.x : cellFrame.origin.y);
            CGFloat boundsPos = (direction == MUKGridDirectionHorizontal ? visibleBounds.origin.x : visibleBounds.origin.y);
            
            if (cellPos > boundsPos) {
                // Cell is after bounds
                position = MUKGridScrollPositionTail;
            }
            else {
                // Cell is before bounds
                position = MUKGridScrollPositionHead;
            }
        }
    }
    
    // Now calculate geometric transform from position
    MUKGeometryTransform transform;
    
    switch (position) {
        case MUKGridScrollPositionHead: {
            transform = MUKGeometryTransformTopLeft;
            break;
        }
            
        case MUKGridScrollPositionMiddle: {
            if (MUKGridDirectionVertical == direction) {
                transform = MUKGeometryTransformLeft;
            }
            else {
                transform = MUKGeometryTransformTop;
            }
            
            break;
        }
            
        case MUKGridScrollPositionTail: {
            if (MUKGridDirectionVertical == direction) {
                transform = MUKGeometryTransformBottomLeft;
            }
            else {
                transform = MUKGeometryTransformTopRight;
            }
            
            break;
        }
            
        default: {
            transform = MUKGeometryTransformIdentity;
            break;
        }
    }
    
    return transform;
}

+ (CGRect)bounds_:(CGRect)bounds inContainerSize_:(CGSize)containerSize direction_:(MUKGridDirection)direction
{
    CGRect alignedBounds = bounds;
    
    // Fix edge
    if (MUKGridDirectionVertical == direction) {
        alignedBounds.origin.x = 0.0f;
    }
    else {
        alignedBounds.origin.y = 0.0f;
    }
    
    // Check if new bounds are too big
    CGRect fullBounds = CGRectZero;
    fullBounds.size = containerSize;
    
    if (!CGRectContainsRect(fullBounds, alignedBounds)) {
        // New bounds will exceed frame
        MUKGeometryTransform excessTransform;
        
        if (MUKGridDirectionVertical == direction) {
            if (CGRectGetMinY(alignedBounds) < CGRectGetMinY(fullBounds)) {
                // Bounds are "too up"
                excessTransform = MUKGeometryTransformTopLeft;
            }
            else {
                // Bounds are "too down"
                excessTransform = MUKGeometryTransformBottomLeft;
            }
        }
        else {
            if (CGRectGetMinX(alignedBounds) < CGRectGetMinX(fullBounds)) {
                // Bounds are "too left"
                excessTransform = MUKGeometryTransformTopLeft;
            }
            else {
                // Bounds are "too right"
                excessTransform = MUKGeometryTransformTopRight;
            }
        }
        
        alignedBounds = [MUK rect:alignedBounds transform:excessTransform respectToRect:fullBounds];
    }
    
    return alignedBounds;
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

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self == scrollView) {
        NSIndexSet *teoricIndexSet = [self indexesOfCellsInVisibleBounds:self.bounds];
        NSIndexSet *realIndexSet = [self indexesOfVisibleCells];
        
        if ([teoricIndexSet isEqualToIndexSet:realIndexSet]) {
            [self didFinishScrollingOfKind:MUKGridScrollKindAnimated];
            signalScrollCompletionInLayoutSubviews_ = NO;
        }
        else {
            // Postpone because last -layoutSubviews has to happen
            scrollKindToSignal_ = MUKGridScrollKindAnimated;
            signalScrollCompletionInLayoutSubviews_ = YES;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self == scrollView) {
        if (decelerate == NO) {
            [self didFinishScrollingOfKind:MUKGridScrollKindUserDrag];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self == scrollView) {
        [self didFinishScrollingOfKind:MUKGridScrollKindUserDeceleration];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (self == scrollView) {
        NSIndexSet *teoricIndexSet = [self indexesOfCellsInVisibleBounds:self.bounds];
        NSIndexSet *realIndexSet = [self indexesOfVisibleCells];
        
        if ([teoricIndexSet isEqualToIndexSet:realIndexSet]) {
            [self didFinishScrollingOfKind:MUKGridScrollKindUserScrollToTop];
            signalScrollCompletionInLayoutSubviews_ = NO;
        }
        else {
            // Postpone because last -layoutSubviews has to happen
            scrollKindToSignal_ = MUKGridScrollKindUserScrollToTop;
            signalScrollCompletionInLayoutSubviews_ = YES;
        }
    }
}

@end
