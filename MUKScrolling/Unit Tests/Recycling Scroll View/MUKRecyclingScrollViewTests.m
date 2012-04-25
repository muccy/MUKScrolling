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

#import "MUKRecyclingScrollViewTests.h"

#import "MUKRecyclingScrollView.h"
#import "MUKRecyclingScrollView_Memory.h"
#import "MUKRecyclingScrollView_Storage.h"

#import "MUKRecyclableView.h"

@implementation MUKRecyclingScrollViewTests

- (void)testViewEnqueueingCondition {
    CGRect viewRect = CGRectMake(0, 0, 200, 200);
    MUKRecyclableView *view = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:nil];
    
    CGRect scrollViewRect = viewRect;
    MUKRecyclingScrollView *scrollView = [[MUKRecyclingScrollView alloc] initWithFrame:scrollViewRect];
    
    STAssertFalse([scrollView shouldEnqueueView:view forVisibleBounds:scrollView.bounds], @"View is totally in bounds");
    
    viewRect.origin.x += 100;
    view.frame = viewRect;
    STAssertFalse([scrollView shouldEnqueueView:view forVisibleBounds:scrollView.bounds], @"View is partially in bounds");
    
    viewRect.origin.x += 1000;
    view.frame = viewRect;
    STAssertTrue([scrollView shouldEnqueueView:view forVisibleBounds:scrollView.bounds], @"View is out of bounds");
}

- (void)testViewEnqueueing {
    static NSString *const kIdentifier = @"Dummy";
    
    MUKRecyclableView *view = [[MUKRecyclableView alloc] init];
    view.recycleIdentifier = kIdentifier;
    
    MUKRecyclingScrollView *scrollView = [[MUKRecyclingScrollView alloc] init];
    
    STAssertEquals((NSUInteger)0, [[scrollView enqueuedViews] count], @"No views enqueued");
    STAssertEquals((NSUInteger)0, [scrollView.recyclableViews_ count], @"No identifiers enqueued");
    
    [scrollView enqueueView:view];
    STAssertEquals((NSUInteger)1, [[scrollView enqueuedViews] count], @"A view enqueued");
    STAssertEquals((NSUInteger)1, [scrollView.recyclableViews_ count], @"An identifier enqueued");
    
    STAssertTrue([[scrollView enqueuedViews] containsObject:view], @"The view is enqueued");
    STAssertEqualObjects(kIdentifier, [[scrollView.recyclableViews_ allKeys] lastObject], @"Identifier is the key");
}

- (void)testViewsEnqueuing {    
    /*
     Create views out of bounds because -enqueueViews:ifNeededForVisibleBounds:
     tests view positioning.
     */
    CGRect viewRect = CGRectMake(1000, 0, 200, 200);
    MUKRecyclableView *view0 = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Dummy"];
    
    viewRect = CGRectMake(1000, 0, 200, 200);
    MUKRecyclableView *view1 = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Foo"];
    
    viewRect = CGRectMake(0, 0, 200, 200);
    MUKRecyclableView *view2 = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Dummy"];
    
    viewRect = CGRectMake(1000, 0, 200, 200);
    MUKRecyclableView *view3 = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Dummy"];
    
    CGRect scrollViewRect = viewRect;
    MUKRecyclingScrollView *scrollView = [[MUKRecyclingScrollView alloc] initWithFrame:scrollViewRect];
    
    STAssertEquals((NSUInteger)0, [[scrollView enqueuedViews] count], @"No views enqueued");
    STAssertEquals((NSUInteger)0, [scrollView.recyclableViews_ count], @"No identifiers enqueued");
    
    [scrollView enqueueViews:[NSSet setWithObjects:view0, view1, view2, view3, nil] ifNeededForVisibleBounds:scrollView.bounds];
    STAssertEquals((NSUInteger)3, [[scrollView enqueuedViews] count], @"Three views enqueued");
    STAssertEquals((NSUInteger)2, [scrollView.recyclableViews_ count], @"Two identifiers enqueued");
    
    STAssertTrue([[scrollView enqueuedViews] containsObject:view0], @"view0 is enqueued");
    STAssertTrue([[scrollView enqueuedViews] containsObject:view1], @"view1 is enqueued");
    STAssertFalse([[scrollView enqueuedViews] containsObject:view2], @"view2 isn't enqueued");
    STAssertTrue([[scrollView enqueuedViews] containsObject:view3], @"view3 is enqueued");
    
    STAssertTrue([[scrollView.recyclableViews_ allKeys] containsObject:@"Dummy"], @"Identifier enqueued");
    STAssertTrue([[scrollView.recyclableViews_ allKeys] containsObject:@"Foo"], @"Identifier enqueued");
}

- (void)testDequeueing {
    /*
     Create views out of bounds because -enqueueViews:ifNeededForVisibleBounds:
     tests view positioning.
     */
    CGRect viewRect = CGRectMake(1000, 0, 200, 200);
    MUKRecyclableView *view0 = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Dummy"];
    
    viewRect = CGRectMake(1000, 0, 200, 200);
    MUKRecyclableView *view1 = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Foo"];
    
    viewRect = CGRectMake(0, 0, 200, 200);
    MUKRecyclableView *view2 = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Dummy"];
    
    viewRect = CGRectMake(1000, 0, 200, 200);
    MUKRecyclableView *view3 = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Dummy"];
    
    CGRect scrollViewRect = viewRect;
    MUKRecyclingScrollView *scrollView = [[MUKRecyclingScrollView alloc] initWithFrame:scrollViewRect];
    
    [scrollView enqueueViews:[NSSet setWithObjects:view0, view1, view2, view3, nil] ifNeededForVisibleBounds:scrollView.bounds];
    
    UIView<MUKRecyclable> *dequeuedView = [scrollView dequeueViewWithIdentifier:@"Dummy"];
    STAssertNotNil(dequeuedView, @"Dummy view exists in queue");
    STAssertEqualObjects(@"Dummy", dequeuedView.recycleIdentifier, @"Proper identifier");
    
    dequeuedView = [scrollView dequeueViewWithIdentifier:@"Foo"];
    STAssertNotNil(dequeuedView, @"Foo view exists in queue");
    STAssertEqualObjects(@"Foo", dequeuedView.recycleIdentifier, @"Proper identifier");
    
    dequeuedView = [scrollView dequeueViewWithIdentifier:@"Foo"];
    STAssertNil(dequeuedView, @"No more Foo views exist in queue");

    dequeuedView = [scrollView dequeueViewWithIdentifier:@"Bar"];
    STAssertNil(dequeuedView, @"No Bar views exist in queue");
    
    dequeuedView = [scrollView dequeueViewWithIdentifier:@"Dummy"];
    dequeuedView = [scrollView dequeueViewWithIdentifier:@"Dummy"];
    STAssertEquals((NSUInteger)0, [[scrollView enqueuedViews] count], @"Every view has been dequeued");
}

- (void)testMemoryWarning {
    /*
     Create views out of bounds because -enqueueViews:ifNeededForVisibleBounds:
     tests view positioning.
     */
    CGRect viewRect = CGRectMake(1000, 0, 200, 200);
    MUKRecyclableView *view0 = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Dummy"];
    
    viewRect = CGRectMake(1000, 0, 200, 200);
    MUKRecyclableView *view1 = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Foo"];
    
    viewRect = CGRectMake(0, 0, 200, 200);
    MUKRecyclableView *view2 = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Dummy"];
    
    viewRect = CGRectMake(1000, 0, 200, 200);
    MUKRecyclableView *view3 = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Dummy"];
    
    CGRect scrollViewRect = viewRect;
    MUKRecyclingScrollView *scrollView = [[MUKRecyclingScrollView alloc] initWithFrame:scrollViewRect];
    
    [scrollView enqueueViews:[NSSet setWithObjects:view0, view1, view2, view3, nil] ifNeededForVisibleBounds:scrollView.bounds];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:UIApplicationDidReceiveMemoryWarningNotification
                      object:self];
    
    STAssertEquals((NSUInteger)0, [[scrollView enqueuedViews] count], @"Every view has been dequeued in order to free memory");
}

- (void)testAddSubview {
    CGRect viewRect = CGRectMake(0, 0, 200, 200);
    MUKRecyclableView *view = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Foo"];
    
    CGRect scrollViewRect = viewRect;
    MUKRecyclingScrollView *scrollView = [[MUKRecyclingScrollView alloc] initWithFrame:scrollViewRect];
    
    [scrollView addSubview:view];
    STAssertTrue([[scrollView visibleViews] containsObject:view], @"Recyclable view added");
    STAssertTrue([[scrollView subviews] containsObject:view], @"Subview added");
    
    viewRect = CGRectMake(1000, 0, 200, 200);
    MUKRecyclableView *outsideView = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Foo"];
    
    [scrollView addSubview:outsideView];
    STAssertFalse([[scrollView visibleViews] containsObject:outsideView], @"Recyclable view not added because is not visible");
    STAssertFalse([[scrollView subviews] containsObject:outsideView], @"Subview not added because is not visible");
    STAssertTrue([[scrollView enqueuedViews] containsObject:outsideView], @"Subview enqueued");
    
    MUKRecyclableView *unnamedView = [[MUKRecyclableView alloc] initWithFrame:viewRect];

    [scrollView addSubview:unnamedView];
    STAssertFalse([[scrollView visibleViews] containsObject:unnamedView], @"Recyclable view not added because it has not an identifier");
    STAssertTrue([[scrollView subviews] containsObject:unnamedView], @"Subview added");
    
    UIView *regularView = [[UIView alloc] initWithFrame:viewRect];
    
    [scrollView addSubview:regularView];
    STAssertFalse([[scrollView visibleViews] containsObject:regularView], @"Regular view is not recyclable");
    STAssertTrue([[scrollView subviews] containsObject:regularView], @"Subview added");
}

- (void)testAutomaticDequeuingAfterMoving {
    CGRect viewRect = CGRectMake(0, 0, 200, 200);
    MUKRecyclableView *view = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Foo"];
    
    CGRect scrollViewRect = viewRect;
    MUKRecyclingScrollView *scrollView = [[MUKRecyclingScrollView alloc] initWithFrame:scrollViewRect];
    scrollView.contentSize = scrollViewRect.size;
    
    [scrollView addSubview:view];
    STAssertTrue([[scrollView visibleViews] containsObject:view], @"Recyclable view added");
    STAssertTrue([[scrollView subviews] containsObject:view], @"Subview added");
    
    // Move scroll view visible bounds
    scrollView.contentOffset = CGPointMake(1000, 0);
    [scrollView layoutSubviews];
    
    STAssertFalse([[scrollView visibleViews] containsObject:view], @"View is no more visible");
    STAssertFalse([[scrollView subviews] containsObject:view], @"View is no more a subview");
    STAssertTrue([[scrollView enqueuedViews] containsObject:view], @"View is enqueued");
}

- (void)testAutomaticDequeuingAfterScrolling {
    CGRect viewRect = CGRectMake(0, 0, 200, 200);
    MUKRecyclableView *view = [[MUKRecyclableView alloc] initWithFrame:viewRect recycleIdentifier:@"Foo"];
    
    CGRect scrollViewRect = viewRect;
    MUKRecyclingScrollView *scrollView = [[MUKRecyclingScrollView alloc] initWithFrame:scrollViewRect];
    scrollView.contentSize = scrollViewRect.size;
    
    [scrollView addSubview:view];
    STAssertTrue([[scrollView visibleViews] containsObject:view], @"Recyclable view added");
    STAssertTrue([[scrollView subviews] containsObject:view], @"Subview added");
    
    // Move scroll view visible bounds simulating a scrolling
    for (CGFloat f = 0.0; f < scrollViewRect.size.width * 1.5; f++) {
        scrollView.contentOffset = CGPointMake(f, 0);
        [scrollView layoutSubviews];
        
        if (f <= scrollViewRect.size.width) {
            STAssertTrue([[scrollView visibleViews] containsObject:view], @"View is visible");
            STAssertTrue([[scrollView subviews] containsObject:view], @"View is a subview");
            STAssertFalse([[scrollView enqueuedViews] containsObject:view], @"View is not enqueued");
        }
        else {
            STAssertFalse([[scrollView visibleViews] containsObject:view], @"View is no more visible");
            STAssertFalse([[scrollView subviews] containsObject:view], @"View is no more a subview");
            STAssertTrue([[scrollView enqueuedViews] containsObject:view], @"View is enqueued");
        }
    } // for
}

@end
