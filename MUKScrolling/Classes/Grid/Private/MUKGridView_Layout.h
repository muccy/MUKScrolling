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

@class MUKGridCellView_;
@interface MUKGridView ()

/*
 This method returns content size given a list of params
 */
+ (CGSize)contentSizeForDirection_:(MUKGridDirection)direction cellSize_:(CGSize)cellSize maxRows_:(NSInteger)maxRows maxCellsPerRow_:(NSInteger)maxCellsPerRow numberOfCells_:(NSInteger)numberOfCells;
/*
 Shortend to apply content size calculated in previous method
 */
- (void)adjustContentSize_;

/*
 This method returns a cell view in a set searching for an index
 */
+ (MUKGridCellView_ *)cellViewWithIndex_:(NSInteger)index inViews_:(NSSet *)views;
/*
 This method return frame of a cell given a list of params
 */
+ (CGRect)frameOfCellAtIndex_:(NSInteger)index cellSize_:(CGSize)cellSize maxCellsPerRow_:(NSInteger)maxCellsPerRow direction_:(MUKGridDirection)direction;

/*
 Those methods layout cells into grid:
 - search for cell into visibleViews
 - if it does not exist it calls -createCellViewAtIndex: and it adds new cell
 as a subview
 - it sets frame every time with -frameOfCellAtIndex:
 */
- (void)layoutCellsAtIndexes_:(NSIndexSet *)indexes visibleCells_:(NSSet *)visibleCells maxCellsPerRow_:(NSInteger)maxCellsPerRow;
- (MUKGridCellView_ *)layoutCellAtIndex_:(NSInteger)index visibleCells_:(NSSet *)visibleCells maxCellsPerRow_:(NSInteger)maxCellsPerRow;

/*
 Those methods returns instances of MUKGridCellView_ (copied)
 */
- (NSSet *)visibleHostCellViews_;
- (NSSet *)enqueuedHostCellViews_;

@end
