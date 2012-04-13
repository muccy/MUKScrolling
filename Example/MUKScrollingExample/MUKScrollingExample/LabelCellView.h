//
//  LabelCellView.h
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 13/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LabelCellView : UIView <MUKRecyclable>
@property (nonatomic, strong) UILabel *label;
@end
