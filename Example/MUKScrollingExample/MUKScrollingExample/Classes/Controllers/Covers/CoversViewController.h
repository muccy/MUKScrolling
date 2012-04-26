//
//  CoversViewController.h
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 25/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GridViewController.h"

@interface CoversViewController : GridViewController
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
- (IBAction)pageControlValueChanged:(id)sender;
@end


@interface CoversWrapperView : UIView
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet MUKGridView *gridView;
@end