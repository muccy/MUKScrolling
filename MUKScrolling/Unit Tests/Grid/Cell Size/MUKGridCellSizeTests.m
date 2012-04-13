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

#import "MUKGridCellSizeTests.h"
#import "MUKGridCellSize.h"

@implementation MUKGridCellSizeTests

- (void)testFixedSize {
    CGSize scalarSize = CGSizeMake(100, 100);
    MUKGridCellSize *size = [[MUKGridCellSize alloc] initWithSize:scalarSize];
    STAssertTrue(CGSizeEqualToSize(scalarSize, size.size), nil);
    STAssertTrue(CGSizeEqualToSize(scalarSize, [size sizeRespectSize:CGSizeMake(200, 200)]), nil);
}

- (void)testProportionalSize {
    CGSize scalarSize = CGSizeMake(1.0, 0.5);
    CGSize containerSize = CGSizeMake(200, 200);
    
    MUKGridCellSize *size = [[MUKGridCellSize alloc] initWithSize:scalarSize];
    size.kind = MUKGridCellSizeKindProportional;
    
    STAssertTrue(CGSizeEqualToSize(scalarSize, size.size), nil);
    
    CGSize expectedSize = CGSizeMake(200, 100);
    STAssertTrue(CGSizeEqualToSize(expectedSize, [size sizeRespectSize:containerSize]), nil);
}

@end
