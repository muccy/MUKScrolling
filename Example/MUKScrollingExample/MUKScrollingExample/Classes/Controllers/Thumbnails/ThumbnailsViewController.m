//
//  ThumbnailsViewController.m
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 22/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailsViewController.h"
#import "ThumbnailCellView.h"

#define kImageOffset    (CGPointMake(4, 4))
#define kCellSize       (CGSizeMake(79, 79))

@interface ThumbnailsViewController ()
@property (nonatomic, strong) NSArray *images_;

- (void)adjustGridView_;
+ (CGRect)gridFrameForBounds:(CGRect)bounds cellSize:(CGSize)cellSize imageOffset:(CGPoint)imageOffset;
- (UIEdgeInsets)gridInsets;
@end

@implementation ThumbnailsViewController
@synthesize images_ = images__;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.gridView.backgroundColor = [UIColor whiteColor];
    self.gridView.clipsToBounds = NO;
    
    self.gridView.cellSize = [[MUKGridCellFixedSize alloc] initWithSize:kCellSize];
    self.gridView.numberOfCells = [self.images_ count];
    self.gridView.direction = MUKGridDirectionVertical;
    
    __unsafe_unretained MUKGridView *weakGridView = self.gridView;
    __unsafe_unretained ThumbnailsViewController *weakSelf = self;
    
    self.gridView.cellCreationHandler = ^(NSInteger index) {
        ThumbnailCellView *cellView = (ThumbnailCellView *)[weakGridView dequeueViewWithIdentifier:@"Cell"];
        
        if (cellView == nil) {
            CGRect rect = CGRectZero;
            rect.size = kCellSize;
            
            cellView = [[ThumbnailCellView alloc] initWithFrame:rect];
            cellView.recycleIdentifier = @"Cell";
            cellView.backgroundColor = weakSelf.view.backgroundColor;
            cellView.imageOffset = kImageOffset;
        }
        
        UIImage *image = [weakSelf.images_ objectAtIndex:index];
        cellView.imageView.image = image;
        cellView.label.text = [NSString stringWithFormat:@"%i", index];
        
        return cellView;
    };
    
    UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    headLabel.backgroundColor = [UIColor lightGrayColor];
    headLabel.font = [UIFont boldSystemFontOfSize:18.0];
    headLabel.textAlignment = UITextAlignmentCenter;
    headLabel.textColor = [UIColor darkGrayColor];
    headLabel.text = @"Colorful";
    self.gridView.headView = headLabel;
    
    UILabel *tailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 65)];
    tailLabel.backgroundColor = [UIColor whiteColor];
    tailLabel.font = [UIFont systemFontOfSize:18.0];
    tailLabel.textAlignment = UITextAlignmentCenter;
    tailLabel.textColor = [UIColor darkGrayColor];
    tailLabel.text = [NSString stringWithFormat:@"%i photos", [self.images_ count]];
    self.gridView.tailView = tailLabel;
    
    [self.gridView reloadData];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self adjustGridView_];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self adjustGridView_];
    [self.gridView scrollToCellAtIndex:0 position:MUKGridScrollPositionTail animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

#pragma mark - Accessors

- (NSArray *)images_ {
    if (images__ == nil) {        
        images__ = [[NSArray alloc] initWithObjects:
                    [UIImage imageNamed:@"colors.jpg"],
                    [UIImage imageNamed:@"autumn.jpg"],
                    [UIImage imageNamed:@"building.jpg"],
                    [UIImage imageNamed:@"cat.jpg"],
                    [UIImage imageNamed:@"garden.jpg"],
                    [UIImage imageNamed:@"colors.jpg"],
                    [UIImage imageNamed:@"autumn.jpg"],
                    [UIImage imageNamed:@"building.jpg"],
                    [UIImage imageNamed:@"cat.jpg"],
                    [UIImage imageNamed:@"garden.jpg"],
                    [UIImage imageNamed:@"colors.jpg"],
                    [UIImage imageNamed:@"autumn.jpg"],
                    [UIImage imageNamed:@"building.jpg"],
                    [UIImage imageNamed:@"cat.jpg"],
                    [UIImage imageNamed:@"garden.jpg"],
                    [UIImage imageNamed:@"colors.jpg"],
                    [UIImage imageNamed:@"autumn.jpg"],
                    [UIImage imageNamed:@"building.jpg"],
                    [UIImage imageNamed:@"cat.jpg"],
                    [UIImage imageNamed:@"garden.jpg"],
                    [UIImage imageNamed:@"colors.jpg"],
                    [UIImage imageNamed:@"autumn.jpg"],
                    [UIImage imageNamed:@"building.jpg"],
                    [UIImage imageNamed:@"cat.jpg"],
                    [UIImage imageNamed:@"garden.jpg"],
                    [UIImage imageNamed:@"colors.jpg"],
                    [UIImage imageNamed:@"autumn.jpg"],
                    [UIImage imageNamed:@"building.jpg"],
                    [UIImage imageNamed:@"cat.jpg"],
                    [UIImage imageNamed:@"garden.jpg"],
                    [UIImage imageNamed:@"colors.jpg"],
                    [UIImage imageNamed:@"autumn.jpg"],
                    [UIImage imageNamed:@"building.jpg"],
                    [UIImage imageNamed:@"cat.jpg"],
                    [UIImage imageNamed:@"garden.jpg"],
                    [UIImage imageNamed:@"colors.jpg"],
                    [UIImage imageNamed:@"autumn.jpg"],
                    [UIImage imageNamed:@"building.jpg"],
                    [UIImage imageNamed:@"cat.jpg"],
                    [UIImage imageNamed:@"garden.jpg"],
                    [UIImage imageNamed:@"colors.jpg"],
                    [UIImage imageNamed:@"autumn.jpg"],
                    [UIImage imageNamed:@"building.jpg"],
                    [UIImage imageNamed:@"cat.jpg"],
                    [UIImage imageNamed:@"garden.jpg"],
                    [UIImage imageNamed:@"colors.jpg"],
                    [UIImage imageNamed:@"autumn.jpg"],
                    [UIImage imageNamed:@"building.jpg"],
                    [UIImage imageNamed:@"cat.jpg"],
                    [UIImage imageNamed:@"garden.jpg"],
                    [UIImage imageNamed:@"colors.jpg"],
                    [UIImage imageNamed:@"autumn.jpg"],
                    [UIImage imageNamed:@"building.jpg"],
                    [UIImage imageNamed:@"cat.jpg"],
                    [UIImage imageNamed:@"garden.jpg"],
                    nil];
    }
    return images__;
}

#pragma mark - Private

- (void)adjustGridView_ {
    self.gridView.frame = [[self class] gridFrameForBounds:self.view.bounds cellSize:kCellSize imageOffset:kImageOffset];
    self.gridView.contentInset = [self gridInsets];
    self.gridView.scrollIndicatorInsets = UIEdgeInsetsMake(self.gridView.contentInset.top, 0, 0, -kImageOffset.x);
}

+ (CGRect)gridFrameForBounds:(CGRect)bounds cellSize:(CGSize)cellSize imageOffset:(CGPoint)imageOffset
{
    CGRect frame = bounds;
    
    // Set same border to right
    frame.size.width -= imageOffset.x;
    
    // How much whitespace?
    NSInteger whiteSpace = (NSInteger)frame.size.width % (NSInteger)cellSize.width;
    
    // Center to divide whitespace
    if (whiteSpace > 0) { 
        frame.origin.x += whiteSpace/2;
        frame.size.width -= whiteSpace;
    }
    
    return frame;
}

- (UIEdgeInsets)gridInsets {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    CGFloat statusBarHeight;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) 
    {
        statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    else {
        statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.width;
    }
    
    insets.top = statusBarHeight + self.navigationController.navigationBar.frame.size.height;
    
    return insets;
}

@end
