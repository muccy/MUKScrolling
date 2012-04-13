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

#import "MUKGridCoordinate.h"

@implementation MUKGridCoordinate
@synthesize row = row_, column = column_;

- (id)initWithRow:(NSInteger)row column:(NSInteger)column {
    self = [super init];
    if (self) {
        self.row = row;
        self.column = column;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL equals = [super isEqual:object];
    
    if (!equals && [object isKindOfClass:[self class]]) {
        MUKGridCoordinate *coordinate = object;
        equals = (coordinate.row == self.row && coordinate.column == self.column);
    }
    
    return equals;
}

#pragma mark - 

+ (NSArray *)coordinatesInRectangleBetweenCoordinate:(MUKGridCoordinate *)coord1 andCoordinate:(MUKGridCoordinate *)coord2
{
    if (!coord1 || !coord2) return nil;
    NSMutableArray *coordinates = [NSMutableArray array];
    
    for (NSInteger c = coord1.column; c <= coord2.column; c++) {
        for (NSInteger r = coord1.row; r <= coord2.row; r++) {
            MUKGridCoordinate *coordinate = [[MUKGridCoordinate alloc] init];
            if (coordinate) {
                coordinate.row = r;
                coordinate.column = c;
                
                [coordinates addObject:coordinate];
            }
        } // for r
    } // for column
    
    return coordinates;
}

#pragma mark - Cell

- (void)setCellIndex:(NSInteger)index withMaxCellsPerRow:(NSInteger)maxCellsPerRow
{
    index = (index < 0 ? 0 : index);
    
    self.row = index / maxCellsPerRow;
    self.column = index % maxCellsPerRow;
}

- (NSInteger)cellIndexWithMaxCellsPerRow:(NSInteger)maxCellsPerRow {
    NSInteger row = (self.row < 0 ? 0 : self.row);
    NSInteger column = (self.column < 0 ? 0 : self.column);
    return (row * maxCellsPerRow) + column;
}

@end
