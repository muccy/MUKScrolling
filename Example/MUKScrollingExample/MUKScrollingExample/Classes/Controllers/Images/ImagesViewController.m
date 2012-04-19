//
//  ImagesViewController.m
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 18/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImagesViewController.h"
#import "ImageCellView.h"
#import <MUKToolkit/MUKToolkit.h>

@interface ImagesViewController ()
@property (nonatomic, strong) NSArray *images_;
@end

@implementation ImagesViewController
@synthesize images_ = images__;
@synthesize currentImageIndex = currentImageIndex_;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.gridView.backgroundColor = [UIColor blackColor];
    
    self.gridView.cellSize = [[MUKGridCellSize alloc] initWithSizeHandler:^ (CGSize containerSize)
    {
        // Full page
        return containerSize;
    }];
    
    self.gridView.numberOfCells = [self.images_ count];
    self.gridView.direction = MUKGridDirectionHorizontal;
    self.gridView.pagingEnabled = YES;
    self.gridView.showsVerticalScrollIndicator = NO;
    self.gridView.showsHorizontalScrollIndicator = NO;
    
    __unsafe_unretained MUKGridView *weakGridView = self.gridView;
    __unsafe_unretained ImagesViewController *weakSelf = self;
    
    self.gridView.cellCreationHandler = ^(NSInteger index) {
        ImageCellView *cellView = (ImageCellView *)[weakGridView dequeueViewWithIdentifier:@"Cell"];
        
        if (cellView == nil) {
            CGRect cellRect = CGRectMake(0, 0, 200, 200);
            cellView = [[ImageCellView alloc] initWithFrame:cellRect];
            cellView.recycleIdentifier = @"Cell";
            cellView.backgroundColor = weakSelf.view.backgroundColor;
        }
        
        UIImage *image = [weakSelf.images_ objectAtIndex:index];
        [cellView setCenteredImage:image];
        
        return cellView;
    };
    
    self.gridView.cellOptionsHandler = ^(NSInteger index) {
        MUKGridCellOptions *options = [[MUKGridCellOptions alloc] init];
        options.maximumZoomScale = 3.0f;
        return options;
    };
    
    self.gridView.cellZoomViewHandler = ^(UIView<MUKRecyclable> *cellView, NSInteger index)
    {
        ImageCellView *view = (ImageCellView *)cellView;
        return view.imageView;
    };
    
    self.gridView.scrollCompletionHandler = ^(MUKGridScrollKind kind) {
        weakSelf.currentImageIndex = [[weakGridView indexesOfVisibleCells] firstIndex];
    };
    
    self.gridView.cellWillLayoutHandler = ^(UIView<MUKRecyclable> *cellView, NSInteger index)
    {
        ImageCellView *view = (ImageCellView *)cellView;
        if (!view.zoomed) {
            [view setNeedsImageCentering];
        }
    };
    
    self.gridView.cellZoomedViewFrameHandler = ^(UIView<MUKRecyclable> *cellView, UIView *zoomedView, NSInteger cellIndex, float scale, CGSize boundsSize)
    {
        CGRect rect;
        if (ABS(scale - 1.0f) > 0.00001f) {
            // Zoomed
            rect = CGRectZero; // Let grid decide automatically
        }
        else {
            // Not zoomed
            ImageCellView *view = (ImageCellView *)cellView;
            rect = [view centeredImageFrame];
        }
        
        return rect;
    };
    
    [self.gridView reloadData];
}

#pragma mark - Accessors

- (NSArray *)images_ {
    if (images__ == nil) {        
        images__ = [[NSArray alloc] initWithObjects:
                    [UIImage imageNamed:@"autumn.jpg"],
                    [UIImage imageNamed:@"building.jpg"],
                    [UIImage imageNamed:@"cat.jpg"],
                    [UIImage imageNamed:@"colors.jpg"],
                    [UIImage imageNamed:@"garden.jpg"],
                    nil];
    }
    return images__;
}

@end
