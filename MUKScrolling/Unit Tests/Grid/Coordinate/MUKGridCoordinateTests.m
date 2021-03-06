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

#import "MUKGridCoordinateTests.h"
#import "MUKGridCoordinate.h"

@implementation MUKGridCoordinateTests

- (void)testInitializer {
    MUKGridCoordinate coordinate = MUKGridCoordinateMake(2, 3);
    STAssertEquals(2, coordinate.row, nil);
    STAssertEquals(3, coordinate.column, nil);
}

- (void)testCoordinatesEquality {
    MUKGridCoordinate coord1 = MUKGridCoordinateMake(1, 0);
    MUKGridCoordinate coord2 = MUKGridCoordinateMake(1, 0);
    STAssertTrue(MUKGridCoordinateEqualToCoordinate(coord1, coord2), nil);
    
    coord2.row++;
    STAssertFalse(MUKGridCoordinateEqualToCoordinate(coord1, coord2), nil);
    
    coord2.row = coord1.row;
    coord2.column++;
    STAssertFalse(MUKGridCoordinateEqualToCoordinate(coord1, coord2), nil);
    
    coord2.row++;
    STAssertFalse(MUKGridCoordinateEqualToCoordinate(coord1, coord2), nil);
}

- (void)testCoordinatesInRectangle {
    MUKGridCoordinate coord1 = MUKGridCoordinateMake(1, 0);
    MUKGridCoordinate coord2 = MUKGridCoordinateMake(1, 0);
    
    NSInteger coordsCount = MUKGridCoordinatesCountBetweenCoordinates(coord1, coord2);
    STAssertEquals(1, coordsCount, nil);
    
    coord2.row = 2; coord2.column = 2;
    /*
     0,0    0,1     0,2     0,3
     1,0    1,1     1,2     1,3
     2,0    2,1     2,2     2,3
     ...
     
     And take from (1,0) to (2,2)
     ---> 6 coordinates
     */
    coordsCount = MUKGridCoordinatesCountBetweenCoordinates(coord1, coord2);
    STAssertEquals(6, coordsCount, nil);
    
    MUKGridCoordinate *coordinates = calloc(coordsCount, sizeof(MUKGridCoordinate));
    MUKGridCoordinatesBetweenCoordinates(coord1, coord2, &coordinates, coordsCount);
    
    for (NSInteger i=0; i<coordsCount; i++) {
        MUKGridCoordinate coord = coordinates[i];
        STAssertTrue(coord.row >= coord1.row && coord.row <= coord2.row, nil);
        STAssertTrue(coord.column >= coord1.column && coord.column <= coord2.column, nil);
    }
    
    free(coordinates);
}

- (void)testCoordinateToIndexConversion {
    MUKGridCoordinate coordinate = MUKGridCoordinateMake(0, 0);
    STAssertEquals(0, MUKGridCoordinateCellIndex(coordinate, 3), @"Origin");
    
    coordinate.row = 0;     coordinate.column = 2;
    STAssertEquals(2, MUKGridCoordinateCellIndex(coordinate, 3), @"Last cell of first row");
    
    coordinate.row = 1;     coordinate.column = 0;
    STAssertEquals(3, MUKGridCoordinateCellIndex(coordinate, 3), @"First cell of second row");
    
    coordinate.row = 2;     coordinate.column = 1;
    STAssertEquals(7, MUKGridCoordinateCellIndex(coordinate, 3), nil);
    
    coordinate.row = -2;     coordinate.column = 1;
    STAssertEquals(1, MUKGridCoordinateCellIndex(coordinate, 3), @"row clamped to 0");
    
    coordinate.row = 0;     coordinate.column = -1;
    STAssertEquals(0, MUKGridCoordinateCellIndex(coordinate, 3), @"column clamped to 0");
    
    coordinate.row = -2;     coordinate.column = -1;
    STAssertEquals(0, MUKGridCoordinateCellIndex(coordinate, 3), @"row and column clamped to 0");
}

- (void)testIndexToCoordinateConversion {
    MUKGridCoordinate coordinate = MUKGridCoordinateFromCellIndex(2, 3);
    STAssertEquals(0, coordinate.row, @"Last cell of first row");
    STAssertEquals(2, coordinate.column, @"Last cell of first row");
    
    coordinate = MUKGridCoordinateFromCellIndex(0, 3);
    STAssertEquals(0, coordinate.row, @"Origin");
    STAssertEquals(0, coordinate.column, @"Origin");
    
    coordinate = MUKGridCoordinateFromCellIndex(-1, 3);
    STAssertEquals(0, coordinate.row, @"Clamped to 0");
    STAssertEquals(0, coordinate.column, @"Clamped to 0");
    
    coordinate = MUKGridCoordinateFromCellIndex(3, 3);
    STAssertEquals(1, coordinate.row, @"First cell of second row");
    STAssertEquals(0, coordinate.column, @"First cell of second row");
    
    coordinate = MUKGridCoordinateFromCellIndex(7, 3);
    STAssertEquals(2, coordinate.row, nil);
    STAssertEquals(1, coordinate.column, nil);
}

@end
