//
//  PagesViewController.m
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 17/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PagesViewController.h"
#import "LabelCellView.h"

@interface PagesViewController ()
- (NSInteger)chosenPagesNumber_;
- (void)updatePageIndexLabel_;
@end

@implementation PagesViewController
@synthesize pagesTextField;
@synthesize scrollTextField;
@synthesize pageIndexLabel;

- (void)dealloc {
    self.pagesTextField.delegate = nil;
    self.scrollTextField.delegate = nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.pagesTextField = nil;
    self.scrollTextField = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CGRect rect = self.gridView.frame;
    rect.origin.y += 44.0;
    rect.size.height -= 44.0;
    self.gridView.frame = rect;
    
    self.gridView.cellSize = [[MUKGridCellSize alloc] initWithSizeHandler:^ (CGSize containerSize) 
    {
        // Full page
        return containerSize;
    }];
    
    self.gridView.numberOfCells = [self chosenPagesNumber_];
    self.gridView.direction = MUKGridDirectionHorizontal;
    self.gridView.pagingEnabled = YES;
    self.gridView.showsVerticalScrollIndicator = NO;
    self.gridView.showsHorizontalScrollIndicator = NO;
    
    __weak MUKGridView *weakGridView = self.gridView;
    __weak PagesViewController *weakSelf = self;
    
    self.gridView.cellCreationHandler = ^(NSInteger index) {
        LabelCellView *cellView = (LabelCellView *)[weakGridView dequeueViewWithIdentifier:@"Cell"];
        
        if (cellView == nil) {
            CGRect rect = CGRectMake(0, 0, 200, 200);
            cellView = [[LabelCellView alloc] initWithFrame:rect];
            cellView.recycleIdentifier = @"Cell";
        }
        
        cellView.label.text = [NSString stringWithFormat:@"%i", index];
        return cellView;
    };
    
    self.gridView.scrollCompletionHandler = ^(MUKGridScrollKind scrollKind)
    {
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
        
        NSLog(@"Scrolled with kind %@", kind);
        
        [weakSelf updatePageIndexLabel_];
    };
    
    [self.gridView reloadData];
    [self updatePageIndexLabel_];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (self.pagesTextField == textField) {
        self.gridView.numberOfCells = [self chosenPagesNumber_];
        [self.gridView reloadData];
    }
    else if (self.scrollTextField == textField) {
        [self.gridView scrollToCellAtIndex:[textField.text intValue] position:MUKGridScrollPositionMiddle animated:YES];
    }
    
    return NO;
}

#pragma mark - Private

- (NSInteger)chosenPagesNumber_ {
    return [self.pagesTextField.text integerValue];
}

- (void)updatePageIndexLabel_ {
    NSIndexSet *visibleIndexes = [self.gridView indexesOfVisibleCells];
    NSInteger visiblePageIndex = [visibleIndexes firstIndex];
    self.pageIndexLabel.text = [NSString stringWithFormat:@"Page %i", visiblePageIndex];
}

@end
