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
 A wrapper to options you can assign to a grid cell.
 */
@interface MUKGridCellOptions : NSObject
/**
 Minimum zoom scale for the cell.
 
 Default is `1.0`.
 */
@property (nonatomic) float minimumZoomScale;
/**
 Maximum zoom scale for the cell.
 
 Default is `1.0`.
 */
@property (nonatomic) float maximumZoomScale;
/**
 The style of the scroll indicators.
 
 The default style is `UIScrollViewIndicatorStyleDefault`.
 */
@property (nonatomic) UIScrollViewIndicatorStyle indicatorStyle;
/**
 The distance the scroll indicators are inset from the edge of the cell.
 
 The default value is `UIEdgeInsetsZero`.
 */
@property(nonatomic) UIEdgeInsets scrollIndicatorInsets;
/**
 A Boolean value that controls whether the horizontal scroll indicator is 
 visible.
 
 The default value is `YES`.
 */
 @property(nonatomic) BOOL showsHorizontalScrollIndicator;
/**
 A Boolean value that controls whether the vertical scroll indicator is 
 visible.
 
 The default value is `YES`.
 */
@property(nonatomic) BOOL showsVerticalScrollIndicator;
@end
