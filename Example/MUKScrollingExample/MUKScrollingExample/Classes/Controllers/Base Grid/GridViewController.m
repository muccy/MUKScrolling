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

- (void)dealloc {
    self.gridView.cellCreationHandler = nil;
    self.gridView.scrollCompletionHandler = nil;
    self.gridView.cellTapHandler = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.gridView = [[MUKGridView alloc] initWithFrame:self.view.bounds];
    __unsafe_unretained MUKGridView *weakGridView = self.gridView;
    
    self.gridView.scrollCompletionHandler = ^(MUKGridScrollKind scrollKind) {
        NSString *kind;
        switch (scrollKind) {
            case MUKGridScrollKindAnimated:
                kind = @"Animated";
                break;
                
            case MUKGridScrollKindUserDrag:
                kind = @"Drag";
                break;
                
            case MUKGridScrollKindUserDeceleration:
                kind = @"Deceleration";
                break;
                
            case MUKGridScrollKindUserScrollToTop:
                kind = @"Scroll to top";
                break;
                
            default:
                kind = @"Unknown";
                break;
        }
        
        NSLog(@"=============");
        NSLog(@"Scrolled with kind %@", kind);
        NSLog(@"Visible indexes %@", [weakGridView indexesOfVisibleCells]);
    };
    
    self.gridView.cellTapHandler = ^(NSInteger index) {
        NSLog(@"=============");
        NSLog(@"Cell at index %i tapped", index);
    };
    
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
