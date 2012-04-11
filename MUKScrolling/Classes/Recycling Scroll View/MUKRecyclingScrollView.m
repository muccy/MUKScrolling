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

#import "MUKRecyclingScrollView.h"

#import "MUKRecyclingScrollView_Storage.h"
#import "MUKRecyclingScrollView_Memory.h"

#define DEBUG_QUEUE_STATUS      0

@implementation MUKRecyclingScrollView
@synthesize visibleViews_ = visibleViews__;
@synthesize recyclableViews_ = recyclableViews__;

- (id)init {
    self = [super init];
    if (self) {
        [self registerToMemoryWarningNotifications_];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerToMemoryWarningNotifications_];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self registerToMemoryWarningNotifications_];
    }
    return self;
}

- (void)dealloc {
    [self unregisterFromMemoryWarningNotifications_];
}

#pragma mark - Accessors

- (NSMutableSet *)visibleViews_ {
    if (visibleViews__ == nil) {
        visibleViews__ = [[NSMutableSet alloc] init];
    }
    return visibleViews__;
}

- (NSMutableDictionary *)recyclableViews_ {
    if (recyclableViews__ == nil) {
        recyclableViews__ = [[NSMutableDictionary alloc] init];
    }
    return recyclableViews__;
}

#pragma mark - Overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutRecyclableSubviews];
}

- (void)addSubview:(UIView *)view {
    if (view) {
        if ([view conformsToProtocol:@protocol(MUKRecyclable)]) {
            UIView<MUKRecyclable> *recyclableView = (UIView<MUKRecyclable> *)view;
            
            if (recyclableView.recycleIdentifier != nil) {     
                if ([self shouldEnqueueView:recyclableView forVisibleBounds:self.bounds])
                {
                    [self enqueueView:recyclableView];
                    return; // Do not add subview
                }
                else {
                    // New subview is in bounds
                    NSMutableSet *recycleSet = [self recycleSetWithIdentifier_:recyclableView.recycleIdentifier create_:NO];
                    [recycleSet removeObject:recyclableView];
                    [self.visibleViews_ addObject:recyclableView];
                }
            }
        }
        
        [super addSubview:view];
    }
}

#pragma mark - Recycle

- (BOOL)shouldEnqueueView:(UIView<MUKRecyclable> *)view forVisibleBounds:(CGRect)bounds
{
    CGRect intersection = CGRectIntersection(view.frame, bounds);
    return CGRectIsNull(intersection);
}

- (void)enqueueView:(UIView<MUKRecyclable> *)view {
    NSMutableSet *recycleSet = [self recycleSetWithIdentifier_:view.recycleIdentifier create_:YES];
    
    [recycleSet addObject:view];
    [self.visibleViews_ removeObject:view];
    [view removeFromSuperview];
}

- (UIView<MUKRecyclable> *)dequeueViewWithIdentifier:(NSString *)recycleIdentifier
{
    NSMutableSet *recycleSet = [self recycleSetWithIdentifier_:recycleIdentifier create_:NO];
    UIView<MUKRecyclable> *view = [recycleSet anyObject];
    
    if (view == nil) return nil;
    
    [recycleSet removeObject:view];
    return view;
}

- (void)enqueueViews:(NSSet *)views ifNeededForVisibleBounds:(CGRect)bounds
{
    [views enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        BOOL recycle = [self shouldEnqueueView:obj forVisibleBounds:bounds];
        if (recycle) {
            [self enqueueView:obj];
        }
    }];
}

- (void)layoutRecyclableSubviews {
    CGRect visibleBounds = [self bounds];
    [self enqueueViews:[self.visibleViews_ copy] ifNeededForVisibleBounds:visibleBounds];
    [self layoutViews:[self.visibleViews_ copy] forVisibleBounds:visibleBounds];
    
    
#if DEBUG_QUEUE_STATUS
    NSLog(@"Visible views: %i", [self.visibleViews_ count]);
    NSLog(@"Enqueued view groups:");
    [self.recyclableViews_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) 
     {
         NSLog(@"\t• %@: %i", key, [obj count]);
     }];
#endif
}

#pragma mark - Layout

- (void)layoutViews:(NSSet *)visibleViews forVisibleBounds:(CGRect)bounds
{
    //
}

#pragma mark - Subviews

- (NSSet *)visibleViews {
    return [visibleViews__ copy];
}

- (NSSet *)enqueuedViews {
    if (recyclableViews__ == nil) return nil;
    
    NSMutableSet *set = [NSMutableSet set];
    [recyclableViews__ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         [set unionSet:obj];
     }];
    
    return set;
}

#pragma mark - Private: Memory

- (void)registerToMemoryWarningNotifications_ {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(memoryWarningNotification_:)
               name:UIApplicationDidReceiveMemoryWarningNotification
             object:nil];
}

- (void)unregisterFromMemoryWarningNotifications_ {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:UIApplicationDidReceiveMemoryWarningNotification
                object:nil];
}

- (void)memoryWarningNotification_:(NSNotification *)notification {
    self.recyclableViews_ = nil;
}

#pragma mark - Private: Storage

- (NSMutableSet *)recycleSetWithIdentifier_:(NSString *)recycleIdentifier create_:(BOOL)create
{
    NSMutableSet *recycleSet = [self.recyclableViews_ objectForKey:recycleIdentifier];
    
    // Create a recycle set
    if (create && recycleIdentifier != nil && recycleSet == nil) {
        recycleSet = [NSMutableSet set];
        [self.recyclableViews_ setObject:recycleSet forKey:recycleIdentifier];
    }
    
    return recycleSet;
}

@end
