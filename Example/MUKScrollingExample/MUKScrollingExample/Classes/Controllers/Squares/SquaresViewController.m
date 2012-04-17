//
//  SquaresViewController.m
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 14/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SquaresViewController.h"
#import "LabelCellView.h"

@interface SquaresViewController ()
- (MUKGridDirection)chosenDirection_;
- (NSInteger)chosenCellsNumber_;
@end

@implementation SquaresViewController
@synthesize cellsTextField;
@synthesize verticalSwitch;
@synthesize scrollTextField;

- (void)dealloc {
    self.cellsTextField.delegate = nil;
    self.scrollTextField.delegate = nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.cellsTextField = nil;
    self.verticalSwitch = nil;
    self.scrollTextField = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = self.gridView.frame;
    rect.origin.y += 44.0;
    rect.size.height -= 44.0;
    self.gridView.frame = rect;
	
    MUKGridCellFixedSize *cellSize = [[MUKGridCellFixedSize alloc] initWithSize:CGSizeMake(80, 80)];
    self.gridView.cellSize = cellSize;
    
    self.gridView.numberOfCells = [self chosenCellsNumber_];
    self.gridView.direction = [self chosenDirection_];
    
    __unsafe_unretained MUKGridView *weakGridView = self.gridView;
    self.gridView.cellCreationHandler = ^(NSInteger index) {
        LabelCellView *cellView = (LabelCellView *)[weakGridView dequeueViewWithIdentifier:@"Cell"];
        
        if (cellView == nil) {
            CGRect rect = CGRectZero;
            rect.size = cellSize.CGSize;
            
            cellView = [[LabelCellView alloc] initWithFrame:rect];
            cellView.recycleIdentifier = @"Cell";
        }
        
        cellView.label.text = [NSString stringWithFormat:@"%i", index];
        return cellView;
    };
}

- (void)verticalSwitchValueChanged:(id)sender {
    self.gridView.direction = [self chosenDirection_];
    [self.gridView reloadData];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (self.cellsTextField == textField) {
        self.gridView.numberOfCells = [self chosenCellsNumber_];
        [self.gridView reloadData];
    }
    else if (self.scrollTextField == textField) {
        [self.gridView scrollToCellAtIndex:[textField.text intValue] position:MUKGridScrollPositionMiddle animated:YES];
    }
    
    return NO;
}

#pragma mark - 

- (MUKGridDirection)chosenDirection_ {
    return (self.verticalSwitch.on ? MUKGridDirectionVertical : MUKGridDirectionHorizontal);
}

- (NSInteger)chosenCellsNumber_ {
    return [self.cellsTextField.text integerValue];
}

@end
