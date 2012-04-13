//
//  ViewController.m
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 11/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "LabelCellView.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize gridView = gridView_;

- (void)dealloc {
    self.gridView.cellCreationHandler = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.gridView = [[MUKGridView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.gridView];
//    
//    MUKGridCellSize *cellSize = [[MUKGridCellSize alloc] initWithSize:CGSizeMake(self.gridView.frame.size.width/4.0, self.gridView.frame.size.width/4.0)];
    MUKGridCellSize *cellSize = [[MUKGridCellSize alloc] initWithSize:CGSizeMake(1.0, 1.0)];
    cellSize.kind = MUKGridCellSizeKindProportional;
    self.gridView.cellSize = cellSize;
    
    self.gridView.direction = MUKGridDirectionHorizontal;
    self.gridView.numberOfCells = 1002;
    
    __unsafe_unretained MUKGridView *weakGridView = self.gridView;
    [self.gridView setCellCreationHandler:^UIView<MUKRecyclable> *(NSInteger index) 
    {
        LabelCellView *cellView = (LabelCellView *)[weakGridView dequeueViewWithIdentifier:@"LabelCellView"];
        
        if (cellView == nil) {
            CGRect rect = CGRectZero;
            rect.size = cellSize.size;
            cellView = [[LabelCellView alloc] initWithFrame:rect];
            cellView.recycleIdentifier = @"LabelCellView";
        }
        
        cellView.label.text = [NSString stringWithFormat:@"%i", index];
        return cellView;
    }];    
    
    [self.gridView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.gridView = nil;
}

@end
