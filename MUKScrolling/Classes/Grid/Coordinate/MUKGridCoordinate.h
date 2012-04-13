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

#import <Foundation/Foundation.h>

/**
 This class expresses the position into a grid in terms of row and column couple.
 
 Please note that a grid may have horizontal rows (in a vertical grid) or
 vertical rows (in an horizontal grid).
 */
@interface MUKGridCoordinate : NSObject
/** @name Properties */
/**
 Row dimension of the coordinate.
 
 Zero-based index.
 */
@property (nonatomic) NSInteger row;
/**
 Column dimension of the coordinate.
 
 Zero-based index.
 */
@property (nonatomic) NSInteger column;

/** @name Initializers */
/**
 Designated initializer.
 @param row Row dimension of the coordinate.
 @param column Column dimension of the coordinate.
 @return
 */
- (id)initWithRow:(NSInteger)row column:(NSInteger)column;

/** @name Methods */
/**
 Coordinates between two given coordinates which form a rectangle.
 
 Say you pass `(0,1)` and `(1,3)`, it returns `{(0,1), (0,2), (0,3), (1,1), (1,2), (1,3)}`.
 
 @param coord1 First coordinate.
 @param coord2 Last coordinate.
 @return Array of coordinates, including `coord1` and `coord2`.
 */
+ (NSArray *)coordinatesInRectangleBetweenCoordinate:(MUKGridCoordinate *)coord1 andCoordinate:(MUKGridCoordinate *)coord2;
@end


@interface MUKGridCoordinate (Cell)
/**
 Sets row and column given a cell index.
 @param index Cell index.
 @param maxCellsPerRow Number of cells which could be contained in a row.
 @warning If `index` is less than `0`, `index` will be clamped to `0`. 
 */
- (void)setCellIndex:(NSInteger)index withMaxCellsPerRow:(NSInteger)maxCellsPerRow;
/**
 Cell index represented by this coordinate.
 @param maxCellsPerRow Number of cells which could be contained in a row.
 @return Cell index represented by this coordinate.
 @warning If `row` or `column` are less than `0`, they will be clamped to `0`.
 */
- (NSInteger)cellIndexWithMaxCellsPerRow:(NSInteger)maxCellsPerRow;
@end