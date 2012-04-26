//
//  CoverView.m
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 25/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoverView.h"

@implementation CoverView
@synthesize contentView;
@synthesize titleLabel;

- (id)initWithFrame:(CGRect)frame recycleIdentifier:(NSString *)recycleIdentifier
{
    self = [super initWithFrame:frame recycleIdentifier:recycleIdentifier];
    if (self) {
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
        
        CGRect titleFrame = CGRectInset(self.contentView.bounds, 3, 3);
        self.titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:self.titleLabel];
        [self addSubview:self.contentView];
    }
    return self;
}

@end
