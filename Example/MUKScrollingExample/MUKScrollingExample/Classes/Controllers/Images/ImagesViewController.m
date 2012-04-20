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
    
    // Space between photos
    CGFloat const kOffset = 10.0f;
    CGRect gridFrame = self.gridView.frame;
    gridFrame.origin.x -= kOffset;
    gridFrame.size.width += kOffset * 2.0f;
    self.gridView.frame = gridFrame;
    
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
            cellView = [[ImageCellView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
            cellView.recycleIdentifier = @"Cell";
            cellView.backgroundColor = weakSelf.view.backgroundColor;
            cellView.insets = UIEdgeInsetsMake(0, kOffset, 0, kOffset);
        }
        
        UIImage *image = [weakSelf.images_ objectAtIndex:index];
        [cellView setCenteredImage:image];
        
        return cellView;
    };
    
    self.gridView.cellOptionsHandler = ^(NSInteger index) {
        MUKGridCellOptions *options = [[MUKGridCellOptions alloc] init];
        options.maximumZoomScale = 30.0f;
        options.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        options.scrollIndicatorInsets = UIEdgeInsetsMake(0, kOffset, 0, kOffset);
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
    
    self.gridView.cellDidLayoutSubviewsHandler = ^(UIView<MUKRecyclable> *cellView, NSInteger index)
    {
        ImageCellView *view = (ImageCellView *)cellView;
        float scale = [weakGridView zoomScaleOfCellAtIndex:index];
        
        if (ABS(scale - 1.0f) < 0.00001f) {
            // Not zoomed
            [view centerImage];
        }
    };
    
    self.gridView.cellZoomedViewFrameHandler = ^(UIView<MUKRecyclable> *cellView, UIView *zoomedView, NSInteger cellIndex, float scale, CGSize boundsSize)
    {
        CGRect rect;
        if (ABS(scale - 1.0f) > 0.00001f) {
            // Zoomed
            // Pay attention to offset: don't show left black space
            boundsSize.width -= kOffset * 2.0f;
            rect = [MUKGridView centeredZoomedViewFrame:zoomedView.frame boundsSize:boundsSize];
            rect.origin.x += kOffset;          
        }
        else {
            // Not zoomed
            ImageCellView *view = (ImageCellView *)cellView;
            rect = [view centeredImageFrame];
        }
        
        return rect;
    };
    
    self.gridView.cellZoomedViewContentSizeHandler = ^(UIView<MUKRecyclable> *cellView, UIView *zoomedView, NSInteger cellIndex, float scale, CGSize boundsSize)
    {
        // Pay attention to offset: compensate origin shifting
        CGSize size = zoomedView.frame.size;
        size.width += kOffset * 2.0f;
        return size;
    };
    
    [self.gridView reloadData];
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
                    nil];
    }
    return images__;
}

@end
