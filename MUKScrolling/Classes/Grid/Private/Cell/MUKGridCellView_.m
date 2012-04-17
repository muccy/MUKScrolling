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

#import "MUKGridCellView_.h"

@implementation MUKGridCellView_
@synthesize cellIndex;
@synthesize guestView = guestView_;
@synthesize singleTapGestureRecognizer = singleTapGestureRecognizer_, doubleTapGestureRecognizer = doubleTapGestureRecognizer_;
@synthesize zoomed = zoomed_;

- (UITapGestureRecognizer *)singleTapGestureRecognizer {
    if (singleTapGestureRecognizer_ == nil) {
        singleTapGestureRecognizer_ = [[UITapGestureRecognizer alloc] init];
        [singleTapGestureRecognizer_ requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
        [self addGestureRecognizer:singleTapGestureRecognizer_];
    }
    
    return singleTapGestureRecognizer_;
}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer {
    if (doubleTapGestureRecognizer_ == nil) {
        doubleTapGestureRecognizer_ = [[UITapGestureRecognizer alloc] init];
        doubleTapGestureRecognizer_.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGestureRecognizer_];
    }
    
    return doubleTapGestureRecognizer_;
}

- (void)setRecycleIdentifier:(NSString *)recycleIdentifier {
    self.guestView.recycleIdentifier = recycleIdentifier;
}

- (NSString *)recycleIdentifier {
    return self.guestView.recycleIdentifier;
}

- (void)setGuestView:(UIView<MUKRecyclable> *)guestView {
    if (guestView != self.guestView) {
        [self.guestView removeFromSuperview];
        guestView_ = guestView;
        
        self.guestView.frame = self.bounds;
        self.contentSize = self.guestView.frame.size;
        self.guestView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:self.guestView];
    }
}

- (void)setZoomScale:(float)scale animated:(BOOL)animated {
    [super setZoomScale:scale animated:animated];
    
    if (animated == NO) {
        self.zoomed = (ABS(scale - 1.0f) > 0.00001f);
    }
}

#pragma mark - 

- (BOOL)isZoomingEnabled {
    return (ABS(self.minimumZoomScale - self.maximumZoomScale) > 0.00001f);
}

@end
