//
//  GridViewController.m
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 14/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GridViewController.h"

@interface GridViewController ()

@end

@implementation GridViewController
@synthesize gridView = gridView_;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.gridView = [[MUKGridView alloc] initWithFrame:self.view.bounds];
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.gridView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.gridView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
