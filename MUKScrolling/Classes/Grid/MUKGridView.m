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
#import "MUKRecyclingScrollView_Memory.h"

#import "MUKGridView_Storage.h"
#import "MUKGridView_RowsAndColumns.h"
#import "MUKGridView_Layout.h"
#import "MUKGridView_Cell.h"

#import "MUKGridCellView_.h"
#import "MUKGridCellViewTapGestureRecognizer_.h"

#define DEBUG_STATS                 0
#define DEBUG_SCROLL_INFOS_TIMER    0

@interface MUKGridView ()
- (void)commonIntialization_;
- (void)setScrollViewDelegate_:(id<UIScrollViewDelegate>)scrollViewDelegate;

#if DEBUG_SCROLL_INFOS_TIMER
@property (nonatomic, strong) NSTimer *debugScrollInfosTimer_;
- (void)startDebugScrollInfos_;
- (void)debugScrollInfosTimerFired_:(NSTimer *)timer;
#endif
@end

@implementation MUKGridView {
    BOOL firstLayout_;
    CGSize contentOffsetRatio_;
    CGSize lastBoundsSize_;
    CGSize lastHeadViewSize_, lastTailViewSize_;
    BOOL signalScrollCompletionInLayoutSubviews_;
    MUKGridScrollKind scrollKindToSignal_;
}
@synthesize direction = direction_;
@synthesize cellSize = cellSize_;
@synthesize numberOfCells = numberOfCells_;
@synthesize detectsDoubleTapGesture = detectsDoubleTapGesture_;
@synthesize doubleTapZoomScale = doubleTapZoomScale_, detectsLongPressGesture = detectsLongPressGesture_;
@synthesize changesZoomedViewFrameWhileZooming = changesZoomedViewFrameWhileZooming_;
@synthesize autoresizesContentOffset = autoresizesContentOffset_;
@synthesize headView = headView_, tailView = tailView_;

@synthesize cellCreationHandler = cellCreationHandler_;
@synthesize cellEnqueuedHandler = cellEnqueuedHandler_;
@synthesize didLayoutSubviewsHandler = didLayoutSubviewsHandler_;
@synthesize scrollHandler = scrollHandler_;
@synthesize scrollCompletionHandler = scrollCompletionHandler_;
@synthesize cellTouchedHandler = cellTouchedHandler_;
@synthesize cellTappedHandler = cellTappedHandler_;
@synthesize cellDoubleTappedHandler = cellDoubleTappedHandler_;
@synthesize cellLongPressedHandler = cellLongPressedHandler_;
@synthesize cellOptionsHandler = cellOptionsHandler_;
@synthesize cellZoomBeginningHandler = zoomBeginningHandler_;
@synthesize cellZoomCompletionHandler = zoomCompletionHandler_;
@synthesize cellZoomHandler = zoomHandler_;
@synthesize cellZoomViewHandler = cellZoomViewHandler_;
@synthesize cellWillLayoutSubviewsHandler = cellWillLayoutSubviewsHandler_;
@synthesize cellDidLayoutSubviewsHandler = cellDidLayoutSubviewsHandler_;
@synthesize cellZoomedViewFrameHandler = cellZoomedViewFrameHandler_;
@synthesize cellZoomedViewContentSizeHandler = cellZoomedViewContentSizeHandler_;
@synthesize visibleCellsBoundsHandler = visibleCellsBoundsHandler_;

@synthesize dequeuedHostCellViews_ = dequeuedHostCellViews__;
#if DEBUG_SCROLL_INFOS_TIMER
@synthesize debugScrollInfosTimer_ = debugScrollInfosTimer__;
#endif

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
    
#if DEBUG_SCROLL_INFOS_TIMER
    [self.debugScrollInfosTimer_ invalidate];
#endif
}

#pragma mark - Accessors

- (void)setHeadView:(UIView *)headView {
    if (headView_ != headView) {
        [headView_ removeFromSuperview];
        headView_ = headView;
        
        // Do not participate to enqueue/dequeue dance
        if ([headView conformsToProtocol:@protocol(MUKRecyclable)]) {
            [(UIView<MUKRecyclable> *)headView setRecycleIdentifier:nil];
        }
    }
}

- (void)setTailView:(UIView *)tailView {
    if (tailView_ != tailView) {
        [tailView_ removeFromSuperview];
        tailView_ = tailView;
        
        // Do not participate to enqueue/dequeue dance
        if ([tailView conformsToProtocol:@protocol(MUKRecyclable)]) {
            [(UIView<MUKRecyclable> *)tailView setRecycleIdentifier:nil];
        }
    }
}

- (NSMutableSet *)dequeuedHostCellViews_ {
    if (dequeuedHostCellViews__ == nil) {
        dequeuedHostCellViews__ = [[NSMutableSet alloc] init];
    }
    return dequeuedHostCellViews__;
}

#pragma mark - Overrides

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    // Disabled setter
}

- (void)setMaximumZoomScale:(float)maximumZoomScale {
    // Disabled setter
}

- (void)setMinimumZoomScale:(float)minimumZoomScale {
    // Disabled setter
}

- (void)layoutSubviews {    
    [self adjustContentSizeAndContentOffsetIfNeededOrForcing_:NO];
    
    // Do enqueue and dequeue dance
    [super layoutSubviews];
    
    // Signal pending scroll completions
    if (signalScrollCompletionInLayoutSubviews_) {
        [self didFinishScrollingOfKind:scrollKindToSignal_];
        signalScrollCompletionInLayoutSubviews_ = NO;
    }
    
    firstLayout_ = NO;
    
    if (self.didLayoutSubviewsHandler) {
        self.didLayoutSubviewsHandler();
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
    
    /*
     I layout head and tail views after new content size is calculated,
     so tail view could be properly placed at tail.
     Don't change call order, because tail uses head size indirectly.
     */
    [self layoutHeadViewIfNeeded_:self.headView];
    [self layoutTailViewIfNeeded_:self.tailView];
        
    // Take involved indexes
    NSIndexSet *cellIndexes = [self indexesOfCellsInVisibleBounds];
    
    /*
     Enqueue visible views not in bounds.
     This may occur after autorotation.
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
        // Don't release host cell view
        [self.dequeuedHostCellViews_ addObject:cellView];
        return [(MUKGridCellView_ *)cellView guestView];
    }
    
    return cellView;
}

- (BOOL)shouldEnqueueView:(UIView<MUKRecyclable> *)view forVisibleBounds:(CGRect)bounds
{
    if ([view isKindOfClass:[MUKGridCellView_ class]]) {
        MUKGridCellView_ *cellView = (MUKGridCellView_ *)view;
        
        // Take involved indexes
        NSIndexSet *cellIndexes = [self indexesOfCellsInVisibleBounds];
        
        // Is visible, do not enqueue
        if ([cellIndexes containsIndex:cellView.cellIndex]) {
            return NO;
        }
    }
    
    else if (view == self.headView || view == self.tailView) {
        return NO;
    }
    
    return [super shouldEnqueueView:view forVisibleBounds:bounds];
}

- (void)enqueueView:(UIView<MUKRecyclable> *)view {
    [super enqueueView:view];
    
    if ([view isKindOfClass:[MUKGridCellView_ class]]) {
        MUKGridCellView_ *cellView = (MUKGridCellView_ *)view;
        
        // Remove zoom
        cellView.zoomed = NO;
        cellView.zoomScale = 1.0;
        cellView.zoomView = nil;
        
        [self didEnqueueCellView:cellView.guestView atIndex:cellView.cellIndex];
    }
}

#pragma mark - Overrides (Private Methods)

- (void)memoryWarningNotification_:(NSNotification *)notification {
    [super memoryWarningNotification_:notification];
    self.dequeuedHostCellViews_ = nil;
}

#pragma mark - Methods

- (void)reloadData {    
    // Adjust content size and content offset
    [self adjustContentSizeAndContentOffsetIfNeededOrForcing_:YES];
    
    // Empty view and enqueue subviews for reuse
    self.dequeuedHostCellViews_ = nil;
    [[self visibleHostCellViews_] enumerateObjectsUsingBlock:^(id obj, BOOL *stop) 
    {
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

- (void)setOptions:(MUKGridCellOptions *)options forCellAtIndex:(NSInteger)index
{    
    MUKGridCellView_ *cellView = [[self class] cellViewWithIndex_:index inViews_:[self visibleHostCellViews_]];
    [cellView applyOptions:(options ?: [[MUKGridCellOptions alloc] init])];
}

- (void)removeAllHandlers {
    self.scrollHandler = nil;
    self.cellEnqueuedHandler = nil;
    self.didLayoutSubviewsHandler = nil;
    self.scrollCompletionHandler = nil;
    self.cellTouchedHandler = nil;
    self.cellTappedHandler = nil;
    self.cellDoubleTappedHandler = nil;
    self.cellLongPressedHandler = nil;
    self.cellOptionsHandler = nil;
    self.cellZoomViewHandler = nil;
    self.cellZoomBeginningHandler = nil;
    self.cellZoomCompletionHandler = nil;
    self.cellZoomHandler = nil;
    self.cellWillLayoutSubviewsHandler = nil;
    self.cellDidLayoutSubviewsHandler = nil;
    self.cellZoomedViewFrameHandler = nil;
    self.cellZoomedViewContentSizeHandler = nil;
    self.visibleCellsBoundsHandler = nil;
}

#pragma mark - Layout

- (NSIndexSet *)indexesOfCellsInVisibleBounds {
    // Normalize bounds of cells
    CGRect normalizedBounds = [self normalizedVisibleBounds_];
    
    CGRect visibleCellsBounds = CGRectZero;
    if (self.visibleCellsBoundsHandler) {
        visibleCellsBounds = self.visibleCellsBoundsHandler(normalizedBounds);
    }
    
    // Set default if needed
    if (CGRectEqualToRect(CGRectZero, visibleCellsBounds)) {
        visibleCellsBounds = normalizedBounds;
    }
    
    // Use bounds of proper size to perform calculations
    CGSize cellSize = [self.cellSize sizeRespectSize:normalizedBounds.size];
    NSInteger maxCellsPerRow = [[self class] maxCellsPerRowInContainerSize_:normalizedBounds.size cellSize_:cellSize direction_:self.direction];

    return [self indexesOfCellsInBounds_:visibleCellsBounds cellSize_:cellSize maxCellsPerRow_:maxCellsPerRow];
}

- (UIView<MUKRecyclable> *)createCellViewAtIndex:(NSInteger)index {
    if (self.cellCreationHandler) {
        return self.cellCreationHandler(index);
    }
    
    return nil;
}

- (CGRect)frameOfCellAtIndex:(NSInteger)index {
    // Normalize bounds of cells
    CGRect normalizedBounds = [self normalizedVisibleBounds_];
    
    CGSize cellSize = [self.cellSize sizeRespectSize:normalizedBounds.size];
    NSInteger maxCellsPerRow = [[self class] maxCellsPerRowInContainerSize_:normalizedBounds.size cellSize_:cellSize direction_:self.direction];
    
    CGRect cellFrame = [[self class] frameOfCellAtIndex_:index cellSize_:cellSize maxCellsPerRow_:maxCellsPerRow direction_:self.direction];
    
    // Consider head view
    return [[self class] rect_:cellFrame shiftingByHeadView_:self.headView direction_:self.direction];
}

- (MUKGridCellOptions *)optionsOfCellAtIndex:(NSInteger)index {
    MUKGridCellOptions *options = nil;
    if (self.cellOptionsHandler) {
        options = self.cellOptionsHandler(index);
    }
    
    return (options ?: [[MUKGridCellOptions alloc] init]);
}

- (void)willLayoutSubviewsOfCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index
{
    if (self.cellWillLayoutSubviewsHandler) {
        self.cellWillLayoutSubviewsHandler(cellView, index);
    }
}

- (void)didLayoutSubviewsOfCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index
{
    if (self.cellDidLayoutSubviewsHandler) {
        self.cellDidLayoutSubviewsHandler(cellView, index);
    }
}

- (void)didEnqueueCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index
{
    if (self.cellEnqueuedHandler) {
        self.cellEnqueuedHandler(cellView, index);
    }
}

#pragma mark - Scroll

- (void)scrollToCellAtIndex:(NSInteger)index position:(MUKGridScrollPosition)position shiftBackByHeadContentInset:(BOOL)shiftBackByHeadContentInset animated:(BOOL)animated
{
    if (index < 0 || index >= self.numberOfCells) return;
    
    // Calculate with an updated content size
    [self adjustContentSize_];
    
    // Where is the cell?
    CGRect cellFrame = [self frameOfCellAtIndex:index];    
    
    // Normalize bounds of cells
    CGRect normalizedBounds = [self normalizedVisibleBounds_];
    
    // Normalize content size
    CGSize normalizedContentSize = [[self class] size_:self.contentSize subtractingHeadView_:self.headView tailView_:self.tailView direction_:self.direction];
    
    // Get geometric transformation
    MUKGeometryTransform transform = [[self class] geometryTransformForScrollPosition_:position direction_:self.direction cellFrame_:cellFrame visibleBounds_:normalizedBounds];
    
    // Move bounds to contain cell
    CGRect alignedBounds = [MUK rect:normalizedBounds transform:transform respectToRect:cellFrame];
    
    // Fix aligned bounds
    CGRect fixedBounds = [[self class] bounds_:alignedBounds inContainerSize_:normalizedContentSize direction_:self.direction];
    
    // Head view height is already calculated in frameOfCellAtIndex
    CGPoint newContentOffset = fixedBounds.origin;
    
    // Do not calculate insets
    if (shiftBackByHeadContentInset) {
        if (self.direction == MUKGridDirectionVertical) {
            newContentOffset.y -= self.contentInset.top;
        }
        else {
            newContentOffset.x -= self.contentInset.left;
        }
    }

    // Perform scroll
    [self setContentOffset:newContentOffset animated:animated];
}

- (void)scrollToCellAtIndex:(NSInteger)index position:(MUKGridScrollPosition)position animated:(BOOL)animated
{
    [self scrollToCellAtIndex:index position:position shiftBackByHeadContentInset:YES animated:animated];
}

- (void)scrollToHeadShiftingBackByHeadContentInset:(BOOL)shiftBackByHeadContentInset animated:(BOOL)animated
{
    CGPoint newContentOffset = CGPointZero;
    
    // Do not calculate insets
    if (shiftBackByHeadContentInset) {
        if (self.direction == MUKGridDirectionVertical) {
            newContentOffset.y -= self.contentInset.top;
        }
        else {
            newContentOffset.x -= self.contentInset.left;
        }
    }
    
    // Perform scroll
    [self setContentOffset:newContentOffset animated:animated];
}

- (void)didFinishScrollingOfKind:(MUKGridScrollKind)scrollKind {
    if (self.scrollCompletionHandler) {
        self.scrollCompletionHandler(scrollKind);
    }
}

#pragma mark - Tap

- (void)didTouchCell:(NSSet *)touches atIndex:(NSInteger)index {
    if (self.cellTouchedHandler) {
        self.cellTouchedHandler(index, touches);
    }
}

- (void)didTapCellAtIndex:(NSInteger)index {
    if (self.cellTappedHandler) {
        self.cellTappedHandler(index);
    }
}

- (void)didDoubleTapCellAtIndex:(NSInteger)index {
    if (self.cellDoubleTappedHandler) {
        self.cellDoubleTappedHandler(index);
    }
}

- (void)didLongPressCellAtIndex:(NSInteger)index finished:(BOOL)finished {
    if (self.cellLongPressedHandler) {
        self.cellLongPressedHandler(index, finished);
    }
}

#pragma mark - Zoom

- (CGRect)frameOfZoomedView:(UIView *)zoomedView inCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index scale:(float)scale boundsSize:(CGSize)boundsSize
{
    CGRect rect = CGRectZero;
    if (self.cellZoomedViewFrameHandler) {
        rect = self.cellZoomedViewFrameHandler(cellView, zoomedView, index, scale, boundsSize);
    }
    
    if (CGRectEqualToRect(rect, CGRectZero)) {
        rect = [[self class] centeredZoomedViewFrame:zoomedView.frame boundsSize:boundsSize];
    }
    
    return rect;
}

+ (CGRect)centeredZoomedViewFrame:(CGRect)zoomedViewFrame boundsSize:(CGSize)boundsSize
{    
    /*
     Keep centered if contents are smaller than bounds.
     Otherwise fill.
     */
    if (zoomedViewFrame.size.width < boundsSize.width) {
        zoomedViewFrame.origin.x = (boundsSize.width - zoomedViewFrame.size.width) / 2.0f;
    } 
    else {
        zoomedViewFrame.origin.x = 0.0f;
    }
    
    if (zoomedViewFrame.size.height < boundsSize.height) {
        zoomedViewFrame.origin.y = (boundsSize.height - zoomedViewFrame.size.height) / 2.0f;
    } 
    else {
        zoomedViewFrame.origin.y = 0.0f;
    }
    
    return zoomedViewFrame;
}

- (CGSize)contentSizeOfZoomedView:(UIView *)zoomedView inCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index scale:(float)scale boundsSize:(CGSize)boundsSize
{
    CGSize size = CGSizeZero;
    if (self.cellZoomedViewContentSizeHandler) {
        size = self.cellZoomedViewContentSizeHandler(cellView, zoomedView, index, scale, boundsSize);
    }
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = zoomedView.frame.size;
    }
    
    return size;
}

- (UIView *)viewForZoomingCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index
{
    UIView *view = nil;
    if (self.cellZoomViewHandler) {
        view = self.cellZoomViewHandler(cellView, index);
    }
    
    return (view ?: cellView);
}

- (void)willBeginZoomingCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index zoomingView:(UIView *)zoomedView fromScale:(float)scale
{
    if (self.cellZoomBeginningHandler) {
        self.cellZoomBeginningHandler(cellView, zoomedView, index, scale);
    }
}

- (void)didEndZoomingCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index zoomedView:(UIView *)zoomedView atScale:(float)scale
{
    if (self.cellZoomCompletionHandler) {
        self.cellZoomCompletionHandler(cellView, zoomedView, index, scale);
    }
}

- (void)didZoomCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index zoomingView:(UIView *)zoomedView atScale:(float)scale
{
    if (self.cellZoomHandler) {
        self.cellZoomHandler(cellView, zoomedView, index, scale);
    }
}

- (void)zoomCellAtIndex:(NSInteger)index toRect:(CGRect)zoomRect animated:(BOOL)animated
{
    MUKGridCellView_ *cellView = [[self class] cellViewWithIndex_:index inViews_:[self visibleHostCellViews_]];
    [cellView zoomToRect:zoomRect animated:animated];

    if (!animated) {
        CGRect cellBounds = cellView.frame;
        cellBounds.origin = CGPointZero;
        cellView.zoomed = !CGRectEqualToRect(cellBounds, zoomRect);
    }
}

- (void)zoomCellAtIndex:(NSInteger)index toScale:(float)scale animated:(BOOL)animated
{
    MUKGridCellView_ *cellView = [[self class] cellViewWithIndex_:index inViews_:[self visibleHostCellViews_]];
    [cellView setZoomScale:scale animated:animated];
    
    if (!animated) {
        cellView.zoomed = (ABS(scale - 1.0f) > 0.000001f);
    }
}

- (float)zoomScaleOfCellAtIndex:(NSInteger)index {
    MUKGridCellView_ *cellView = [[self class] cellViewWithIndex_:index inViews_:[self visibleHostCellViews_]];
    
    if (!cellView) return -1.0f;
    return cellView.zoomScale;
}

#pragma mark - Private

- (void)commonIntialization_ {
    [self setScrollViewDelegate_:self];
    doubleTapZoomScale_ = 2.0f;
    autoresizesContentOffset_ = YES;
    changesZoomedViewFrameWhileZooming_ = YES;
    firstLayout_ = YES;
    detectsDoubleTapGesture_ = YES;
    
#if DEBUG_SCROLL_INFOS_TIMER
    [self startDebugScrollInfos_];
#endif
}

- (void)setScrollViewDelegate_:(id<UIScrollViewDelegate>)scrollViewDelegate 
{
    [super setDelegate:scrollViewDelegate];
}

#if DEBUG_SCROLL_INFOS_TIMER

- (void)startDebugScrollInfos_ {
    self.debugScrollInfosTimer_ = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(debugScrollInfosTimerFired_:) userInfo:nil repeats:YES];
}

- (void)debugScrollInfosTimerFired_:(NSTimer *)timer {
    NSLog(@"\n\n\nDebug scroll Infos:\nContent offset: %@\nContent inset: %@", NSStringFromCGPoint(self.contentOffset), NSStringFromUIEdgeInsets(self.contentInset));
}

#endif

#pragma mark - Private: Layout

- (BOOL)adjustContentSizeAndContentOffsetIfNeededOrForcing_:(BOOL)force {
    BOOL shouldAdjustContentSize = (force || !CGSizeEqualToSize(lastBoundsSize_, self.bounds.size));
    
    // Consider also head view and tail view changes
    if (shouldAdjustContentSize == NO) {
        shouldAdjustContentSize = (!CGSizeEqualToSize(lastHeadViewSize_, self.headView.frame.size) || !CGSizeEqualToSize(lastTailViewSize_, self.tailView.frame.size));
    }
    
    if (shouldAdjustContentSize) {
        // Recalculate content size everytime bounds changes (useful during autorotations)
        [self adjustContentSize_];
        
        // Calculate new content offset (if needed)
        if (self.autoresizesContentOffset && !firstLayout_) {
            CGPoint newContentOffset = [[self class] autoresizedContentOffsetWithRatio_:contentOffsetRatio_ updatedContentSize_:self.contentSize visibleBoundsSize_:self.bounds.size contentInset_:self.contentInset];
            
            // This comparison is done for performance
            if (!CGPointEqualToPoint(self.contentOffset, newContentOffset)) {
                self.contentOffset = newContentOffset;
            }
        }
        
        // Save last values
        lastBoundsSize_ = self.bounds.size;
        lastHeadViewSize_ = self.headView.frame.size;
        lastTailViewSize_ = self.tailView.frame.size;
    }
    
    // contentOffsetRatio_ is only used to autoresize content offset
    if (self.autoresizesContentOffset) {
        contentOffsetRatio_ = [[self class] contentOffsetRatioForContentOffset_:self.contentOffset contentSize_:self.contentSize contentInset_:self.contentInset];
    }
    
    return shouldAdjustContentSize;
}

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
    
    MUKGridCoordinate coordinate = MUKGridCoordinateFromCellIndex(index, maxCellsPerRow);
    
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
    
    // Create if not found in visible cells
    if (cellView == nil) {
        UIView<MUKRecyclable> *guestView = [self createCellViewAtIndex:index];
        
        /*
         If guest view is in a MUKGridCellView_, it means it is dequeued.
         Reuse also that view and remove from the dequeued pool.
         */
        if ([guestView.superview isKindOfClass:[MUKGridCellView_ class]])
        {
            cellView = (MUKGridCellView_ *)guestView.superview;
            if (!CGRectEqualToRect(cellFrame, cellView.frame)) {
                cellView.frame = cellFrame;
            }
            
            [self.dequeuedHostCellViews_ removeObject:cellView];
        }
        /*
         Not dequeued: create brand new host cell view.
         */
        else {
            cellView = [[MUKGridCellView_ alloc] initWithFrame:cellFrame];
            cellView.clipsToBounds = YES;
            cellView.guestView = guestView;
            cellView.delegate = self;
            
            [self attachHandlersToNewCellView_:cellView];
        }
        
        // Be sure to give the correct index to the cell
        cellView.cellIndex = index;
        
        // Adjust gesture recognizers
        [self attachRequiredGestureRecognizersToCellView_:cellView];       
        
        // Add cell
        [self addSubview:cellView];
    }
    
    // If found in visible views, adjust frame
    // This comparison is done for performance
    else if (!CGRectEqualToRect(cellFrame, cellView.frame)) {
        cellView.frame = cellFrame;
    }
    
    // In every case set zoom properties
    [cellView applyOptions:[self optionsOfCellAtIndex:index]];
        
    return cellView;
}

+ (CGSize)contentSize_:(CGSize)contentSize extendedByContentInset_:(UIEdgeInsets)contentInset 
{
    contentSize.width += contentInset.left + contentInset.right;
    contentSize.height += contentInset.top + contentInset.bottom;
    return contentSize;
}

+ (CGPoint)contentOffset_:(CGPoint)contentOffset shiftedByContentInset_:(UIEdgeInsets)contentInset
{
    contentOffset.x += contentInset.left;
    contentOffset.y += contentInset.top;
    return contentOffset;
}

+ (CGSize)contentOffsetRatioForContentOffset_:(CGPoint)contentOffset contentSize_:(CGSize)contentSize contentInset_:(UIEdgeInsets)contentInset
{
    CGSize extendedContentSize = [self contentSize_:contentSize extendedByContentInset_:contentInset];
    CGPoint shiftedContentOffset = [self contentOffset_:contentOffset shiftedByContentInset_:contentInset];
    
    CGSize ratio = CGSizeMake(shiftedContentOffset.x/extendedContentSize.width, shiftedContentOffset.y/extendedContentSize.height);
    return ratio;
}

+ (CGPoint)autoresizedContentOffsetWithRatio_:(CGSize)contentOffsetRatio updatedContentSize_:(CGSize)contentSize visibleBoundsSize_:(CGSize)boundsSize contentInset_:(UIEdgeInsets)contentInset
{
    CGPoint newContentOffset;
    if (!isnan(contentOffsetRatio.width) && !isnan(contentOffsetRatio.height))
    {
        CGSize extendedContentSize = [self contentSize_:contentSize extendedByContentInset_:contentInset];
        
        newContentOffset.x = contentOffsetRatio.width * extendedContentSize.width;
        newContentOffset.y = contentOffsetRatio.height * extendedContentSize.height;
        
        // Shift back content offset
        newContentOffset.x -= contentInset.left;
        newContentOffset.y -= contentInset.top;
        
        // Don't go under the tail
        CGFloat maxX = newContentOffset.x + boundsSize.width;
        CGFloat maxY = newContentOffset.y + boundsSize.height;
        
        CGFloat maxContainerX = contentSize.width + contentInset.right;
        CGFloat maxContainerY = contentSize.height + contentInset.bottom;
        
        if (maxX > maxContainerX) {
            newContentOffset.x -= (maxX - maxContainerX);
        }
        
        if (maxY > maxContainerY) {
            newContentOffset.y -= (maxY - maxContainerY);
        }
        
        // Don't go over the head
        // (also if it means to go under the tail)
        newContentOffset.x = MAX(-contentInset.left, newContentOffset.x);
        newContentOffset.y = MAX(-contentInset.top, newContentOffset.y);
    }
    else {
        newContentOffset = CGPointMake(-1.0f, -1.0f);
    }
    
    return newContentOffset;
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

- (CGRect)normalizedVisibleBounds_ {   
    CGRect normalizedBounds = self.bounds;
    
    /*
     Change only if there is an head view.
     Ignore insets, because insets produce negative origin, which is ok because
     negative coordinates are translated into 0 indexes.
     
     Do not consider tail because the more space is translated into cell indexes
     greater than self.numberOfCells
     */
    if (self.headView) {
        /*
         Perform calculations without insets
         */
        normalizedBounds.origin.x += self.contentInset.left;
        normalizedBounds.origin.y += self.contentInset.top;
        
        /*
         How much is head view visible?
         */
        CGFloat visibleDimension;
        if (MUKGridDirectionHorizontal == self.direction) {
            visibleDimension = self.headView.frame.size.width - normalizedBounds.origin.x;
        }
        else {
            // Vertical
            visibleDimension = self.headView.frame.size.height - normalizedBounds.origin.y;
        } // if direction 
        
        /*
         If head view is visible, substract size and force origin to (0,0)
         */
        if (visibleDimension > 0.0f) {
            // Head is visible
            if (MUKGridDirectionHorizontal == self.direction) {
                normalizedBounds.origin.x = 0.0f;
                normalizedBounds.size.width -= visibleDimension;
            }
            else {
                // Vertical
                normalizedBounds.origin.y = 0.0f;
                normalizedBounds.size.height -= visibleDimension;
            } // if direction 
        } 
        
        /*
         If head is hidden, do not calculate head view size anymore
         */
        else {
            // Head is hidden
            if (MUKGridDirectionHorizontal == self.direction) {
                normalizedBounds.origin.x -= self.headView.frame.size.width;
            }
            else {
                // Vertical
                normalizedBounds.origin.y -= self.headView.frame.size.height;
            } // if direction 
        }
        // if visible dimension
        
        /*
         Insets have to be ignored
         */
        normalizedBounds.origin.x -= self.contentInset.left;
        normalizedBounds.origin.y -= self.contentInset.top;
    } // if headView
    
    return normalizedBounds;
}

- (void)adjustContentSize_ {
    // Normalize bounds of cells
    CGRect normalizedBounds = [self normalizedVisibleBounds_];
    
    CGSize cellSize = [self.cellSize sizeRespectSize:normalizedBounds.size];
    NSInteger maxCellsPerRow = [[self class] maxCellsPerRowInContainerSize_:normalizedBounds.size cellSize_:cellSize direction_:self.direction];
    NSInteger maxRows = [[self class] maxRowsForCellsCount_:self.numberOfCells maxCellsPerRow_:maxCellsPerRow direction_:self.direction];
    
    CGSize newContentSize = [[self class] contentSizeForDirection_:self.direction cellSize_:cellSize maxRows_:maxRows maxCellsPerRow_:maxCellsPerRow numberOfCells_:self.numberOfCells];
    
    // Consider head view and tail view
    CGSize extendedContentSize = [[self class] size_:newContentSize addingHeadView_:self.headView tailView_:self.tailView direction_:self.direction];
    
    // This comparison is done for performance
    if (!CGSizeEqualToSize(extendedContentSize, self.contentSize)) {
        self.contentSize = extendedContentSize;
    }
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

+ (CGRect)rect_:(CGRect)rect shiftingByHeadView_:(UIView *)headView direction_:(MUKGridDirection)direction
{
    if (MUKGridDirectionVertical == direction) {
        rect.origin.y += headView.frame.size.height;
    }
    else {
        // Horizontal
        rect.origin.x += headView.frame.size.width;
    }
    
    return rect;
}

+ (CGSize)size_:(CGSize)size subtractingHeadView_:(UIView *)headView tailView_:(UIView *)tailView direction_:(MUKGridDirection)direction
{
    if (MUKGridDirectionVertical == direction) {
        size.height -= headView.frame.size.height + tailView.frame.size.height;
    }
    else {
        // Horizontal
        size.width -= headView.frame.size.width + tailView.frame.size.width;
    }
    
    return size;
}

+ (CGSize)size_:(CGSize)size addingHeadView_:(UIView *)headView tailView_:(UIView *)tailView direction_:(MUKGridDirection)direction
{
    if (MUKGridDirectionVertical == direction) {
        size.height += headView.frame.size.height + tailView.frame.size.height;
    }
    else {
        // Horizontal
        size.width += headView.frame.size.width + tailView.frame.size.width;
    }
    
    return size;
}

+ (CGRect)headView_:(UIView *)headView frameInBoundsSize_:(CGSize)boundsSize direction_:(MUKGridDirection)direction
{
    CGRect frame = headView.frame;
    frame.origin = CGPointZero;
    
    if (MUKGridDirectionVertical == direction) {
        frame.size.width = boundsSize.width;
    }
    else {
        // Horizontal
        frame.size.height = boundsSize.height;
    }
    
    return frame;
}

- (void)layoutHeadViewIfNeeded_:(UIView *)headView {
    if (headView) {
        // Add to grid if needed
        if (headView.superview != self) {
            [headView removeFromSuperview];
            [self addSubview:headView];
        }
        
        // Adjust frame
        CGRect frame = [[self class] headView_:headView frameInBoundsSize_:self.bounds.size direction_:self.direction];
        
        if (!CGRectEqualToRect(frame, headView.frame)) {
            headView.frame = frame;
        }
    }
}

+ (CGRect)tailView_:(UIView *)tailView frameInBoundsSize_:(CGSize)boundsSize lastCellFrame:(CGRect)lastCellFrame direction_:(MUKGridDirection)direction
{
    CGRect frame = tailView.frame;
    
    if (MUKGridDirectionVertical == direction) {
        frame.origin.x = 0.0f;
        frame.origin.y = CGRectGetMaxY(lastCellFrame);
        frame.size.width = boundsSize.width;
    }
    else {
        // Horizontal
        frame.origin.x = CGRectGetMaxX(lastCellFrame);
        frame.origin.y = 0.0f;
        frame.size.height = boundsSize.height;
    }
    
    return frame;
}

- (void)layoutTailViewIfNeeded_:(UIView *)tailView {
    if (tailView) {
        // Add to grid if needed
        if (tailView.superview != self) {
            [tailView removeFromSuperview];
            [self addSubview:tailView];
        }
        
        // Adjust frame
        CGRect lastCellFrame = [self frameOfCellAtIndex:self.numberOfCells-1];
        CGRect frame = [[self class] tailView_:tailView frameInBoundsSize_:self.bounds.size lastCellFrame:lastCellFrame direction_:self.direction];
        
        if (!CGRectEqualToRect(frame, tailView.frame)) {
            tailView.frame = frame;
        }
    }
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

+ (MUKGridCoordinate)coordinateOfCellOfSize_:(CGSize)cellSize atPoint:(CGPoint)point direction_:(MUKGridDirection)direction decimalRow_:(CGFloat *)decimalRow decimalColumn_:(CGFloat *)decimalColumn
{
    MUKGridCoordinate coordinate;
    
    switch (direction) {
        case MUKGridDirectionVertical: {
            // Horizontal rows
            CGFloat r = point.y/cellSize.height;
            CGFloat c = point.x/cellSize.width;
            
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
            
            coordinate.row = floorf(r);
            coordinate.column = floorf(c);
            
            if (decimalRow)     *decimalRow = r;
            if (decimalColumn)  *decimalColumn = c;
            
            break;
        }
            
        default:
            coordinate = MUKGridCoordinateMake(0, 0);
            break;
    }
    
    return coordinate;
}

- (NSIndexSet *)indexesOfCellsInBounds_:(CGRect)bounds cellSize_:(CGSize)cellSize maxCellsPerRow_:(NSInteger)maxCellsPerRow
{
    MUKGridCoordinate firstCellCoordinate = [[self class] coordinateOfCellOfSize_:cellSize atPoint:bounds.origin direction_:self.direction decimalRow_:NULL decimalColumn_:NULL];
    
    CGPoint bottomDownPoint = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
    CGFloat row = 0.0, column = 0.0;
    MUKGridCoordinate lastCellCoordinate = [[self class] coordinateOfCellOfSize_:cellSize atPoint:bottomDownPoint direction_:self.direction decimalRow_:&row decimalColumn_:&column];
    
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
    
    // Count how many coordinates are into the rectangle
    NSInteger coordsCount = MUKGridCoordinatesCountBetweenCoordinates(firstCellCoordinate, lastCellCoordinate);
    
    // Create buffer on the heap
    MUKGridCoordinate *coordinates = calloc(coordsCount, sizeof(MUKGridCoordinate));
    
    // Get coordinates
    MUKGridCoordinatesBetweenCoordinates(firstCellCoordinate, lastCellCoordinate, &coordinates, coordsCount);

    // Create index set
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];

    // Create indexes
    for (NSInteger i=0; i<coordsCount; i++) {
        NSInteger cellIndex = MUKGridCoordinateCellIndex(coordinates[i], maxCellsPerRow);
        
        // Validate index
        if (cellIndex >= 0 && cellIndex < self.numberOfCells) {
            [indexSet addIndex:cellIndex];
        }
    } // for
    
    // Dispose coordinates C array on the heap
    free(coordinates);

    return indexSet;
}

#pragma mark - Private: Cell

- (void)attachHandlersToNewCellView_:(MUKGridCellView_ *)cellView {
    __unsafe_unretained MUKGridView *weakSelf = self;
    __unsafe_unretained MUKGridCellView_ *weakCellView = cellView;
    cellView.willLayoutSubviewsHandler = ^{
        [weakSelf willLayoutSubviewsOfCellView:weakCellView.guestView atIndex:weakCellView.cellIndex];
    };
    
    cellView.didLayoutSubviewsHandler = ^{
        [weakSelf didLayoutSubviewsOfCellView:weakCellView.guestView atIndex:weakCellView.cellIndex];
    };
}

- (void)attachRequiredGestureRecognizersToCellView_:(MUKGridCellView_ *)cellView
{
    // Attach double tap gesture recognizer if needed
    if (self.detectsDoubleTapGesture == NO) {
        if (cellView.doubleTapGestureRecognizer) {
            [cellView removeGestureRecognizer:cellView.doubleTapGestureRecognizer];
            cellView.doubleTapGestureRecognizer = nil;
        }
    }
    else {
        if (cellView.doubleTapGestureRecognizer == nil) {
            cellView.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCellDoubleTap_:)];
            cellView.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
            [cellView addGestureRecognizer:cellView.doubleTapGestureRecognizer];
        }
    }
    
    // Attach single tap gesture recognizer
    MUKGridCellViewTapGestureRecognizer_ *singleTapRecognizer;
    
    if (cellView.singleTapGestureRecognizer) {
        singleTapRecognizer = cellView.singleTapGestureRecognizer;
    }
    else {
        singleTapRecognizer = [[MUKGridCellViewTapGestureRecognizer_ alloc] initWithTarget:self action:@selector(handleCellTap_:)];
        cellView.singleTapGestureRecognizer = singleTapRecognizer;
        
        __unsafe_unretained MUKGridView *weakSelf = self;
        __unsafe_unretained MUKGridCellView_ *weakCellView = cellView;
        singleTapRecognizer.touchesBeganHandler = ^(NSSet *touches) {
            [weakSelf didTouchCell:touches atIndex:weakCellView.cellIndex];
        };
        
        [cellView addGestureRecognizer:singleTapRecognizer];
    }
    
    if (cellView.doubleTapGestureRecognizer) {
        [singleTapRecognizer requireGestureRecognizerToFail:cellView.doubleTapGestureRecognizer];
    }
    
    // Attach long pressure gesture recognizer if needed
    if (self.detectsLongPressGesture == NO) {
        if (cellView.longPressGestureRecognizer) {
            [cellView removeGestureRecognizer:cellView.longPressGestureRecognizer];
            cellView.longPressGestureRecognizer = nil;
        }
    }
    else {
        if (cellView.longPressGestureRecognizer == nil) {
            cellView.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleCellLongPress_:)];
            [cellView addGestureRecognizer:cellView.longPressGestureRecognizer];
        }
    }
}

- (void)handleCellTap_:(UITapGestureRecognizer *)recognizer {    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        MUKGridCellView_ *cellView = (MUKGridCellView_ *)recognizer.view;
        [self didTapCellAtIndex:cellView.cellIndex];
    }
}

- (void)handleCellDoubleTap_:(UITapGestureRecognizer *)recognizer {    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        MUKGridCellView_ *cellView = (MUKGridCellView_ *)recognizer.view;
        
        CGRect zoomRect;
        BOOL performZoom = NO;
        
        if (cellView.zoomed) {
            // Zoom out
            zoomRect = cellView.frame;
            zoomRect.origin = CGPointZero;
            performZoom = YES;
        }
        else if (ABS(self.doubleTapZoomScale - 1.0f) > 0.0001f) {
            // Zoom in
            zoomRect.size.height = cellView.frame.size.height / self.doubleTapZoomScale;
            zoomRect.size.width  = cellView.frame.size.width  / self.doubleTapZoomScale;
            
            CGPoint center = [recognizer locationInView:cellView.zoomView];
            zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
            zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
            
            performZoom = YES;
        }
        
        if (performZoom) {
            [cellView zoomToRect:zoomRect animated:YES];
        }
        
        [self didDoubleTapCellAtIndex:cellView.cellIndex];
    }
}

- (void)handleCellLongPress_:(UILongPressGestureRecognizer *)recognizer { 
    MUKGridCellView_ *cellView = (MUKGridCellView_ *)recognizer.view;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self didLongPressCellAtIndex:cellView.cellIndex finished:NO];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self didLongPressCellAtIndex:cellView.cellIndex finished:YES];
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self == scrollView) {
        if (self.scrollHandler) {
            self.scrollHandler();
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self == scrollView) {
        NSIndexSet *teoricIndexSet = [self indexesOfCellsInVisibleBounds];
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
        NSIndexSet *teoricIndexSet = [self indexesOfCellsInVisibleBounds];
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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[MUKGridCellView_ class]]) {
        MUKGridCellView_ *cellView = (MUKGridCellView_ *)scrollView;
        
        if ([cellView isZoomingEnabled]) {
            UIView *zoomView = [self viewForZoomingCellView:cellView.guestView atIndex:cellView.cellIndex];
            cellView.zoomView = zoomView;
            return zoomView;
        }
    }
    
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if ([scrollView isKindOfClass:[MUKGridCellView_ class]]) {
        MUKGridCellView_ *cellView = (MUKGridCellView_ *)scrollView;        
        [self willBeginZoomingCellView:cellView.guestView atIndex:cellView.cellIndex zoomingView:view fromScale:cellView.zoomScale];
        
        if (cellView.zoomed == NO) {
            // Start zooming
            cellView.zoomed = YES;
        }
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if ([scrollView isKindOfClass:[MUKGridCellView_ class]]) {
        MUKGridCellView_ *cellView = (MUKGridCellView_ *)scrollView;
        [self didEndZoomingCellView:cellView.guestView atIndex:cellView.cellIndex zoomedView:cellView.zoomView atScale:scale];
        
        cellView.zoomed = (ABS(scale - 1.0f) > 0.00001f);
        if (cellView.zoomed == NO) {
            cellView.zoomView = nil;
        }
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[MUKGridCellView_ class]]) {
        MUKGridCellView_ *cellView = (MUKGridCellView_ *)scrollView;
        
        if (self.changesZoomedViewFrameWhileZooming) {
            CGRect newFrame = [self frameOfZoomedView:cellView.zoomView inCellView:cellView.guestView atIndex:cellView.cellIndex scale:cellView.zoomScale boundsSize:cellView.bounds.size];
            
            // This comparison is done for performance
            if (!CGRectEqualToRect(newFrame, cellView.zoomView.frame)) {
                cellView.zoomView.frame = newFrame;
            }
        }
        
        CGSize newContentSize = [self contentSizeOfZoomedView:cellView.zoomView inCellView:cellView.guestView atIndex:cellView.cellIndex scale:cellView.zoomScale boundsSize:cellView.bounds.size];
        
        // This comparison is done for performance
        if (!CGSizeEqualToSize(newContentSize, cellView.contentSize)) {
            cellView.contentSize = newContentSize;
        }
        
        [self didZoomCellView:cellView.guestView atIndex:cellView.cellIndex zoomingView:cellView.zoomView atScale:cellView.zoomScale];
    }
}

@end
