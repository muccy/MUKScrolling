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
@end
