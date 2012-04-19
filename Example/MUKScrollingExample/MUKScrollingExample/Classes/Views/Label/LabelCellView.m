//
//  LabelCellView.m
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 13/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LabelCellView.h"

@implementation LabelCellView
@synthesize label = label_;
@synthesize recycleIdentifier;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor blackColor];
        self.label.font = [UIFont boldSystemFontOfSize:14.0];
        self.label.textAlignment = UITextAlignmentCenter;
        [self addSubview:self.label];
        
        float r = (arc4random()%255)/255.0;
        float g = (arc4random()%255)/255.0;
        float b = (arc4random()%255)/255.0;
        self.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
