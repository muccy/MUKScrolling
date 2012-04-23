//
//  ThumbnailCellView.m
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 22/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailCellView.h"
#import <QuartzCore/QuartzCore.h>

@interface ThumbnailCellView ()
- (CGRect)imageViewFrame_;
@end

@implementation ThumbnailCellView
@synthesize imageView = imageView_;
@synthesize label = label_;
@synthesize imageOffset = imageOffset_;
@synthesize recycleIdentifier;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:[self imageViewFrame_]];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.layer.borderWidth = 1.0f;
        self.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self addSubview:self.imageView];
        
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = [UIFont boldSystemFontOfSize:28.0f];
        self.label.textAlignment = UITextAlignmentCenter;
        self.label.textColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        [self addSubview:self.label];
    }
    return self;
}

- (void)setImageOffset:(CGPoint)imageOffset {
    if (!CGPointEqualToPoint(imageOffset, imageOffset_)) {
        imageOffset_ = imageOffset;
        self.imageView.frame = [self imageViewFrame_];
    }
}

#pragma mark - Private

- (CGRect)imageViewFrame_ {    
    CGRect rect = self.bounds;
    rect.origin = self.imageOffset;
    rect.size.width -= self.imageOffset.x;
    rect.size.height -= self.imageOffset.y;
    return rect;
}

@end
