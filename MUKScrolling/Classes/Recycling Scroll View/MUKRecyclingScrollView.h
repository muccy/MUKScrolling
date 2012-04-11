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

#import <UIKit/UIKit.h>
#import <MUKScrolling/MUKRecyclable.h>

/**
 This UIScrollView subclass implements some methods to recycle views while
 scrolling (like UITableView does).
 
 To do so, layoutSubviews is overridden to call layoutRecyclableSubviews.
 
 @warning This subclass overrides addSubview: method. If passed view conforms
 to MUKRecyclable protocol, and recycleIdentifier is not nil, the new subview
 will participate to reusing dance.
 */
@interface MUKRecyclingScrollView : UIScrollView

@end


@interface MUKRecyclingScrollView (Recycle)
/**
 @param view The view which is asked if it has to be put into recycling queue.
 @param bounds Visible bounds of the scroll view.
 @return `YES` if view's frame is outside visible bounds.
 */
- (BOOL)shouldEnqueueView:(UIView<MUKRecyclable> *)view forVisibleBounds:(CGRect)bounds;
/**
 Mark a view as reusable.
 
 This method inserts this view into the proper recycle bin and remove it
 from visible ones (calling removeFromSuperview, too).
 
 @param view The view which will be marked as recyclable.
 */
- (void)enqueueView:(UIView<MUKRecyclable> *)view;
/**
 Dequeue a view.
 
 @param recycleIdentifier Recycling identifier of the view.
 @return Dequeued view with given recycleIdentifier, ready to be reinserted as 
 a subview.
 */
- (UIView<MUKRecyclable> *)dequeueViewWithIdentifier:(NSString *)recycleIdentifier;
/**
 Mark some views as recyclable checking visible bounds.
 
 This method iterates through views and calls shouldEnqueueView:forVisibleBounds:
 and, then, enqueueView:
 
 @param views Views which will be checked.
 @param bounds Visible bounds of the scroll view.
 */
- (void)enqueueViews:(NSSet *)views ifNeededForVisibleBounds:(CGRect)bounds;
/**
 Enqueue views and layout visible views.
 
 @warning This method is called for each layoutSubviews invocation.
 */
- (void)layoutRecyclableSubviews;
@end


@interface MUKRecyclingScrollView (Layout)
/**
 Layout visible views into the scroll view.
 
 In this method you have a chance to tweak displayed views, given views marked
 as visible and currently visibile bounds.
 
 @param visibleViews A set containg views marked as visible.
 @param bounds Visible bounds of the scroll view.
 @warning Default implementation does nothing, because it's up to *concrete*
 classes to implement layout reusing views.
 @warning This method is fired for each layoutSubviews call, so you
 should return as quick as you can to optimize performance. On the other side
 you have a deep control over subviews positioning.
 */
- (void)layoutViews:(NSSet *)visibleViews forVisibleBounds:(CGRect)bounds;
@end


@interface MUKRecyclingScrollView (Subviews)
/**
 Visible views.
 @return Views marked as visible.
 */
- (NSSet *)visibleViews;
/**
 Enqueued view.
 @return Views marked as recyclable.
 */
- (NSSet *)enqueuedViews;
@end