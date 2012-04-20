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

#import <MUKScrolling/MUKRecyclingScrollView.h>
#import <MUKScrolling/MUKGridCoordinate.h>
#import <MUKScrolling/MUKGridCellSize.h>
#import <MUKScrolling/MUKGridCellOptions.h>

typedef enum {
    MUKGridDirectionHorizontal = 0,
    MUKGridDirectionVertical
} MUKGridDirection;

typedef enum {
    MUKGridScrollPositionNone = 0,
    MUKGridScrollPositionHead,
    MUKGridScrollPositionMiddle,
    MUKGridScrollPositionTail
} MUKGridScrollPosition;

typedef enum {
    MUKGridScrollKindAnimated = 0,
    MUKGridScrollKindUserDrag,
    MUKGridScrollKindUserDeceleration,
    MUKGridScrollKindUserScrollToTop
} MUKGridScrollKind;

/**
 This class is a concrete implementation of MUKRecyclingScrollView, used to 
 realize a grid of cells, both vertical and horizontal.
 
 Horizontal grids have vertical rows, with this index pattern:
     0   3   6   9
     1   4   7   ...
     2   5   8
 
 Vertical grids have horizontal rows, with this index pattern:
     0   1   2
     3   4   5
     6   7   8
     9   ...
 
 This class implements following methods of `UIScrollViewDelegate` protocol:
 
 * `- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView`
 * `- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate`
 * `- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView`
 * `- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView`
 * `- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView`
 * `- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view`
 * `- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale`
 * `- (void)scrollViewDidZoom:(UIScrollView *)scrollView`
 
 Zoom is not available at this time for the whole grid: you can zoom only inside
 single cells.
 */
@interface MUKGridView : MUKRecyclingScrollView <UIScrollViewDelegate>
/** @name Properties */
/**
 Grid's direction.
 
 `MUKGridDirectionHorizontal` is default.
 */
@property (nonatomic) MUKGridDirection direction;
/**
 Cell size.
 
 You have to assign a size in order to display grid properly.
 */
@property (nonatomic, strong) MUKGridCellSize *cellSize;
/**
 Number of cells displayed by the grid.
 
 `0` is default.
 */
@property (nonatomic) NSInteger numberOfCells;
/**
 Zoom scale to adopt with double tap gesture.
 
 `2.0` is default.
 */
@property (nonatomic) float doubleTapZoomScale;
/**
 It changes zoomed view at every zoom step.
 
 Default is `YES`.
 
 @see frameOfZoomedView:inCellView:atIndex:scale:boundsSize:
 */
@property (nonatomic) BOOL changesZoomedViewFrameWhileZooming;
/**
 Keep `contentOffset` proportional to `contentSize` everytime frame changes.
 
 Default is `YES`.
 */
@property (nonatomic) BOOL autoresizesContentOffset;



/** @name Handlers */
/**
 Creates cells to be displayed by the grid.
 
 Block takes index of requested cell view and must return a recyclable view.
 
 Please use recycling. Example:
     __unsafe_unretained MUKGridView *weakGridView = self.gridView;
     [self.gridView setCellCreationHandler:^(NSInteger index) 
     {
        MyCellView *cellView = (MyCellView *)[weakGridView dequeueViewWithIdentifier:@"MyCell"];
     
        if (cellView == nil) {
            cellView = [[MyCellView alloc] initWithFrame:...];
            cellView.recycleIdentifier = @"MyCell";
        }
     
        // Customize cell
        return cellView;
     }];
*/
@property (nonatomic, copy) UIView<MUKRecyclable>* (^cellCreationHandler)(NSInteger cellIndex);
/**
 Callback which signals when an animated scrolling did finish.
 
 @see didFinishScrollingOfKind:
 */
@property (nonatomic, copy) void (^scrollCompletionHandler)(MUKGridScrollKind scrollKind);
/**
 Callback which signals when a cell is tapped.
 
 @see didTapCellAtIndex:
 */
@property (nonatomic, copy) void (^cellTapHandler)(NSInteger cellIndex);
/**
 Callback which signals when a cell is double tapped.
 
 @see didDoubleTapCellAtIndex:
 */
@property (nonatomic, copy) void (^cellDoubleTapHandler)(NSInteger cellIndex);
/**
 Handler to set options for a cell.

 @see optionsOfCellAtIndex:
 */
@property (nonatomic, copy) MUKGridCellOptions* (^cellOptionsHandler)(NSInteger cellIndex);
/**
 Handler which provides a view to zoom in a cell.
 
 Set handler to `nil` in order to use cell view itself.
 
 @see viewForZoomingCellView:atIndex:
 */
@property (nonatomic, copy) UIView* (^cellZoomViewHandler)(UIView<MUKRecyclable> *cellView, NSInteger cellIndex);
/**
 Handler which is called as zoom is about to start.
 
 @see willBeginZoomingCellView:atIndex:zoomingView:fromScale:
 */
@property (nonatomic, copy) void (^cellZoomBeginningHandler)(UIView<MUKRecyclable> *cellView, UIView *zoomedView, NSInteger cellIndex, float scale);
/**
 Handler which is called as zoom has finished.
 
 @see didEndZoomingCellView:atIndex:zoomedView:atScale:
 */
@property (nonatomic, copy) void (^cellZoomCompletionHandler)(UIView<MUKRecyclable> *cellView, UIView *zoomedView, NSInteger cellIndex, float scale);
/**
 Handler which is called as zoom changes.
 
 @see didZoomCellView:atIndex:zoomingView:atScale:
 */
@property (nonatomic, copy) void (^cellZoomHandler)(UIView<MUKRecyclable> *cellView, UIView *zoomedView, NSInteger cellIndex, float scale);
/**
 Handler which is called to provide a proper frame to zoomed view at every zoom
 step.
 
 @see frameOfZoomedView:inCellView:atIndex:scale:boundsSize:
 */
@property (nonatomic, copy) CGRect (^cellZoomedViewFrameHandler)(UIView<MUKRecyclable> *cellView, UIView *zoomedView, NSInteger cellIndex, float scale, CGSize boundsSize);
/**
 Handler which is called just before cell subviews are layed out.
 
 @see willLayoutSubviewsOfCellView:atIndex:
 */
@property (nonatomic, copy) void (^cellWillLayoutSubviewsHandler)(UIView<MUKRecyclable> *cellView, NSInteger cellIndex);
/**
 Handler which is called just after cell subviews are layed out.
 
 @see didLayoutSubviewsOfCellView:atIndex:
 */
@property (nonatomic, copy) void (^cellDidLayoutSubviewsHandler)(UIView<MUKRecyclable> *cellView, NSInteger cellIndex);



/** @name Methods */
/**
 Reloads cells.
 
 It enqueues every visible views, then it relayouts using current visible
 bounds (calling layoutRecyclableSubviews).
 */
- (void)reloadData;
/**
 Indexes of cells layed out at this time.
 @return Indexes of cells which exist and are subviews of the grid.
 */
- (NSIndexSet *)indexesOfVisibleCells;
/**
 View of a cell layed out at this time.
 @param index Index of the cell in the grid.
 @return The view of a the cell if visible or `nil`.
 */
- (UIView<MUKRecyclable> *)cellViewAtIndex:(NSInteger)index;
/**
 Shortend to set all handlers to `nil`.
 */
- (void)removeAllHandlers;
@end


@interface MUKGridView (Layout)
/**
 Indexes of cells which should be layed out for given bounds.
 @param visibleBounds Bounds where cells wants to be displayed.
 @return Indexes of cells to display. Those indexes are less than numberOfCells
 and are greater than `0`.
 */
- (NSIndexSet *)indexesOfCellsInVisibleBounds:(CGRect)visibleBounds;
/**
 Create a cell for given index.
 
 Default implementation calls cellCreationHandler.
 
 @param index Index of cell view into the grid.
 @return A new or dequeued cell view.
 */
- (UIView<MUKRecyclable> *)createCellViewAtIndex:(NSInteger)index;
/**
 Frame of a cell into the grid.
 
 Default implementation calculates frame only using cellSize.
 
 @param index Index of cell into the grid.
 @return Frame of the cell.
 */
- (CGRect)frameOfCellAtIndex:(NSInteger)index;
/**
 Options to apply to a cell into the grid.
 
 You can activate zoom for a cell providing different minimum and maximum
 zoom scales.
 
 Default implementation calls cellOptionsHandler or, if handler is not set or
 returns `nil`, it returns a standard set of options.
 
 @param index Index of cell into the grid.
 @return Options of the cell.
 */
- (MUKGridCellOptions *)optionsOfCellAtIndex:(NSInteger)index;
/**
 Callback invoked at top of `layoutSubviews` implementation of cell.
 
 Default implementation calls cellWillLayoutSubviewsHandler.
 
 @param cellView Cell view will be layed out.
 @param index Cell index in the grid.
 */
- (void)willLayoutSubviewsOfCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index;
/**
 Callback invoked at bottom of `layoutSubviews` implementation of cell.
 
 Default implementation calls cellDidLayoutSubviewsHandler.
 
 @param cellView Cell view layed out.
 @param index Cell index in the grid.
 */
- (void)didLayoutSubviewsOfCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index;
@end


@interface MUKGridView (Scroll)
/**
 Scroll grid to a cell.
 @param index Index of cell to show.
 @param position How to show cell scrolling.
 @param animated `YES` if scroll will be animated.
 
 You could set cell position after scroll in four ways:
 
 * `MUKGridScrollPositionNone` performs the minimum scroll to show the cell.
 * `MUKGridScrollPositionHead` scrolls to show cell head (top for vertical grids, 
 left for horizontal grids). If cell is at tail of the grid, cell could not be 
 at exact head after scrolling.
 * `MUKGridScrollPositionMiddle` scrolls to show cell at middle of the grid. If
 cell is at head/tail of the grid, cell could not be at exact middle after
 scrolling.
 * `MUKGridScrollPositionTail` scrolls to show cell tail (bottom for vertical 
 grids, right for horizontal grids). If cell is at head of the grid, cell could
 not be at exact tail after scrolling.
 */
- (void)scrollToCellAtIndex:(NSInteger)index position:(MUKGridScrollPosition)position animated:(BOOL)animated;
/**
 Callback for animated scroll.
 @param scrollKind The kind of scroll animation.
 
 This method is fired in response of scrollToCellAtIndex:position:animated:
 (with `animated` = `YES`) or in response of user touches.
 
 There are three kinds of scrolling:
 
 * `MUKGridScrollKindAnimated`, originated programmatically from 
 scrollToCellAtIndex:position:animated:.
 * `MUKGridScrollKindUserDrag`, originated from a user which drags the grid
 and lifts up the finger causing no deceleration.
 * `MUKGridScrollKindUserDeceleration`, originated from a user which drags the
 grid and lifts up the finger causing a deceleration.
 
 Default implementation calls scrollCompletionHandler.
 
 @warning It is possible to see subsequents invocations of this method with
 `MUKGridScrollKindUserDrag` and `MUKGridScrollKindUserDeceleration`: this 
 happens when user makes grid to decelerate and, then, he stops deceleration 
 putting his finger again on the screen.
 */
- (void)didFinishScrollingOfKind:(MUKGridScrollKind)scrollKind;
@end


@interface MUKGridView (Taps)
/**
 Callback which signals when a cell is tapped.
 @param index Cell index in the grid.
 
 Default implementation calls cellTapHandler.
 */
- (void)didTapCellAtIndex:(NSInteger)index;
/**
 Callback which signals when a cell is double tapped.
 @param index Cell index in the grid.
 
 Default implementation calls cellDoubleTapHandler.
 */
- (void)didDoubleTapCellAtIndex:(NSInteger)index;
@end


@interface MUKGridView (Zoom)
/**
 Provides a valid frame at every zoom step.
 
 Default implementation calls cellZoomedViewFrame or returns a centered frame
 if handler is not set or if handler returns `CGRectZero`.
 
 Please mind this method is called only if changesZoomedViewFrameWhileZooming is
 set to `YES`.
 
 @param zoomedView The view will be zoomed.
 @param cellView Cell view involved in zooming.
 @param index Cell index in the grid.
 @param scale Scale of cell before zooming.
 @param boundsSize Size of cell bounds.
 @return A frame proper for zoomedView at given scale, with given boundsSize.
 */
- (CGRect)frameOfZoomedView:(UIView *)zoomedView inCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index scale:(float)scale boundsSize:(CGSize)boundsSize;
/**
 Provides view for zooming a cell.
 
 Default implementation calls cellZoomViewHandler or returns cellView itself 
 if handler is not set or handler returns `nil`.
 
 @param cellView Cell view involved in zooming.
 @param index Cell index in the grid.
 @return View to zoom.
 */
- (UIView *)viewForZoomingCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index;
/**
 Callback which signals when zoom of a cell is starting.
 @param cellView Cell view involved in zooming.
 @param index Cell index in the grid.
 @param zoomedView The view will be zoomed.
 @param scale Scale of cell before zooming.
 
 Default implementation calls zoomBeginningHandler.
 */
- (void)willBeginZoomingCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index zoomingView:(UIView *)zoomedView fromScale:(float)scale;
/**
 Callback which signals when zoom of a cell ends.
 @param cellView Cell view involved in zooming.
 @param index Cell index in the grid.
 @param zoomedView The view has been zoomed.
 @param scale Scale of cell after zooming.
 
 Default implementation calls zoomCompletionHandler.
 */
- (void)didEndZoomingCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index zoomedView:(UIView *)zoomedView atScale:(float)scale;
/**
 Callback which signals when zoom of a cell is happening.
 @param cellView Cell view involved in zooming.
 @param index Cell index in the grid.
 @param zoomedView The view is being zoomed.
 @param scale Scale of cell zooming.
 
 Default implementation calls zoomHandler.
 */
- (void)didZoomCellView:(UIView<MUKRecyclable> *)cellView atIndex:(NSInteger)index zoomingView:(UIView *)zoomedView atScale:(float)scale;
/**
 Zoom a visible cell to a rect.
 @param index Cell index in the grid.
 @param zoomRect Rect used to zoom cell.
 @param animated `YES` the transition has to be animated.
 */
- (void)zoomCellAtIndex:(NSInteger)index toRect:(CGRect)zoomRect animated:(BOOL)animated;
/**
 Zoom a visible cell to a scale.
 @param index Cell index in the grid.
 @param scale New zoom scale.
 @param animated `YES` the transition has to be animated.
 */
- (void)zoomCellAtIndex:(NSInteger)index toScale:(float)scale animated:(BOOL)animated;
/**
 Zoom scale of visible cell.
 @param index Cell index in the grid.
 @return Zoom scale of cell if it visible, or a negative value if it is not
 visible.
 */
- (float)zoomScaleOfCellAtIndex:(NSInteger)index;
@end
