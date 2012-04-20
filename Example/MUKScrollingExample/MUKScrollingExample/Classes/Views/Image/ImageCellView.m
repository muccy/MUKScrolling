//
//  ImageCellView.m
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 18/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageCellView.h"
#import <MUKToolkit/MUKToolkit.h>

@implementation ImageCellView {
    BOOL centerImage_;
}
@synthesize recycleIdentifier;
@synthesize imageView;
@synthesize insets;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (centerImage_) {
        centerImage_ = NO;
        [self centerImage];
    }
}

- (void)setCenteredImage:(UIImage *)image {
    self.imageView.image = image;
    [self setNeedsImageCentering];
}

- (void)setNeedsImageCentering {
    centerImage_ = YES;
    [self setNeedsLayout];
}

- (CGRect)centeredImageFrame {
    CGRect imageRect = CGRectZero;
    imageRect.size = self.imageView.image.size;    
    
    CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, self.insets);
    
    CGRect fittedRect = [MUK rect:imageRect transform:MUKGeometryTransformScaleAspectFit respectToRect:bounds];
    return fittedRect;
}

- (void)centerImage {
    self.imageView.frame = [self centeredImageFrame];
}

@end
