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
 Block used to calculate the size respect a container.
 
 The block takes size of container and returns size of the cell.
 */
@property (nonatomic, copy) CGSize (^sizeHandler)(CGSize containerSize);


/** @name Initializers */
/**
 Designated initializer.
 @param sizeHandler Handler which will be put in sizeHandler ivar.
 @return A new instance.
 */
- (id)initWithSizeHandler:(CGSize (^)(CGSize containerSize))sizeHandler;

/** @name Methods */
/**
 Size respect a container size, using instance sizeHandler.
 @param size Container size.
 @return Size respect container, using instance sizeHandler.
 */
- (CGSize)sizeRespectSize:(CGSize)size;

@end
