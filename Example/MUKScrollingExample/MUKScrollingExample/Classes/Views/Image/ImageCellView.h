//
//  ImageCellView.h
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 18/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCellView : UIView <MUKRecyclable>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) UIEdgeInsets insets;

/*
 Cells are stretched to fit their rect.
 Preserve image position in order not to zoom to whitespaces
 */
- (void)setCenteredImage:(UIImage *)image;

- (CGRect)centeredImageFrame;
- (void)centerImage;

/*
 Centers at next layout
 */
- (void)setNeedsImageCentering;
@end
