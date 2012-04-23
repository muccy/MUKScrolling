//
//  ThumbnailCellView.h
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 22/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbnailCellView : UIView <MUKRecyclable>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic) CGPoint imageOffset;
@end
