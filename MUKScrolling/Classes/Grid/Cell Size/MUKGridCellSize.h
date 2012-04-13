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

typedef enum {
    MUKGridCellSizeKindFixed = 0,
    MUKGridCellSizeKindProportional
} MUKGridCellSizeKind;

/**
 This class represents the size of a cell in a grid.
*/
@interface MUKGridCellSize : NSObject
/** @name Properties */
/**
 Kind of size.
 
 Size could be:
 * `MUKGridCellSizeKindFixed`, which means size ivar represents size of cell in 
 points (*default*).
 * `MUKGridCellSizeKindProportional`, which means size ivar represents size of
 cell respect its grid. So, if you give a size of `(1.0, 0.5)` in a grid of 
 `(320,200)`, computed size will be `(320,100)`.
 */
@property (nonatomic) MUKGridCellSizeKind kind;
/**
 `CGSize` of cell.
 */
@property (nonatomic) CGSize size;

/** @name Initializers */
/**
 Designated initializer.
 @param size Value which will be put in size ivar.
 @return A new instance.
 */
- (id)initWithSize:(CGSize)size;

/** @name Methods */
/**
 Size respect a container size, using instance kind.
 @param size Container size.
 @return Size respect container, using instance kind.
 @warning If kind is `MUKGridCellSizeKindProportional`, width and height will
 be rounded.
 */
- (CGSize)sizeRespectSize:(CGSize)size;

@end
