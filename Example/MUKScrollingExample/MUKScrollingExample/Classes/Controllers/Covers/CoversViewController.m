//
//  CoversViewController.m
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 25/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoversViewController.h"
#import "CoverView.h"

static NSString *const kCoverViewIdentifier = @"Cover";

@interface Cover_ : NSObject  
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *color, *titleColor;
@end

@implementation Cover_
@synthesize title;
@synthesize color, titleColor;
@end

#pragma mark - 
#pragma mark - 

@implementation CoversWrapperView
@synthesize gridView;
@synthesize pageControl;

// Extend grid touch area
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self.pageControl) {
        return hitView;
    }
    
    return self.gridView;
}

@end

#pragma mark - 
#pragma mark - 

#define kMainCoverAlpha     1.0f
#define kOtherCoversAlpha   0.7f

@interface CoversViewController ()
@property (nonatomic, strong) NSArray *covers_;
@property (nonatomic) NSInteger currentCoverIndex_;

- (void)updateCurrentCoverIndex_;
- (void)updatePageControl_;
- (void)configureCoverView_:(CoverView *)coverView withCover_:(Cover_ *)cover;
@end

@implementation CoversViewController
@synthesize pageControl = pageControl_;
@synthesize covers_ = covers__;
@synthesize currentCoverIndex_ = currentCoverIndex__;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [(CoversWrapperView *)self.view setGridView:self.gridView];
    
    CGFloat inset = 40.0f;
    CGRect rect = self.gridView.frame;
    rect.origin.x += inset;
    rect.size.width -= inset * 2.0f;
    rect.size.height -= self.pageControl.frame.size.height;

    self.gridView.frame = rect;
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    self.gridView.clipsToBounds = NO;
    self.gridView.direction = MUKGridDirectionHorizontal;
    self.gridView.showsHorizontalScrollIndicator = NO;
    self.gridView.showsVerticalScrollIndicator = NO;
    self.gridView.pagingEnabled = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    self.gridView.backgroundColor = [UIColor blackColor];
    
    [self updatePageControl_];
    
    __unsafe_unretained MUKGridView *weakGridView = self.gridView;
    __unsafe_unretained CoversViewController *weakSelf = self;
    
    self.gridView.cellSize = [[MUKGridCellSize alloc] initWithSizeHandler:^CGSize(CGSize containerSize) 
    {
        return containerSize;
    }];
    
    self.gridView.numberOfCells = [self.covers_ count];
    
    CGFloat const kCoverContentWidth = 320.0f - (inset * 2.0f + 30.0f);
    self.gridView.cellCreationHandler = ^(NSInteger cellIndex) {
        CoverView *coverView = (CoverView *)[weakGridView dequeueViewWithIdentifier:kCoverViewIdentifier];
        
        if (coverView == nil) {
            coverView = [[CoverView alloc] initWithFrame:CGRectMake(0, 0, kCoverContentWidth, 200) recycleIdentifier:kCoverViewIdentifier];
            coverView.backgroundColor = [UIColor clearColor];
        }
        
        Cover_ *cover = [weakSelf.covers_ objectAtIndex:cellIndex];
        [weakSelf configureCoverView_:coverView withCover_:cover];
        coverView.alpha = kOtherCoversAlpha;
        
        return coverView;
    };
    
    self.gridView.visibleCellsBoundsHandler = ^(CGRect bounds) {
        // Use extended bounds
        CGFloat extendedWidth = weakGridView.superview.frame.size.width;
        CGFloat diff = extendedWidth - bounds.size.width;
        
        bounds.origin.x -= diff / 2.0f;
        bounds.size.width = extendedWidth;
        return bounds;
    };
    
    self.gridView.scrollHandler = ^{
        [[weakGridView visibleViews] enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
        {
            CoverView *coverView = obj;
            coverView.alpha = kOtherCoversAlpha;
        }];
    };
    
    self.gridView.scrollCompletionHandler = ^(MUKGridScrollKind kind) {
        [weakSelf updateCurrentCoverIndex_];
        [weakSelf updatePageControl_];
        
        CoverView *coverView = (CoverView *)[weakGridView cellViewAtIndex:weakSelf.currentCoverIndex_];
        [UIView animateWithDuration:0.1 animations:^{
            coverView.alpha = kMainCoverAlpha;
        }];
    };
    
    [self.gridView reloadData];
    
    CoverView *coverView = (CoverView *)[weakGridView cellViewAtIndex:self.currentCoverIndex_];
    coverView.alpha = kMainCoverAlpha;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.pageControl = nil;
}

#pragma mark - 

- (IBAction)pageControlValueChanged:(id)sender {
    [self.gridView scrollToCellAtIndex:self.pageControl.currentPage position:MUKGridScrollPositionHead animated:YES];
}

#pragma mark - Accessors

- (NSArray *)covers_ {
    if (covers__ == nil) {
        NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
        
        Cover_ *cover = [[Cover_ alloc] init];
        cover.title = @"Foundation";
        cover.titleColor = [UIColor blackColor];
        cover.color = [UIColor lightGrayColor];
        [mutableArray addObject:cover];
        
        cover = [[Cover_ alloc] init];
        cover.title = @"War and Peace";
        cover.titleColor = [UIColor whiteColor];
        cover.color = [UIColor redColor];
        [mutableArray addObject:cover];
        
        cover = [[Cover_ alloc] init];
        cover.title = @"The Picture of Dorian Gray";
        cover.titleColor = [UIColor blackColor];
        cover.color = [UIColor greenColor];
        [mutableArray addObject:cover];
        
        cover = [[Cover_ alloc] init];
        cover.title = @"A Farewell to Arms";
        cover.titleColor = [UIColor whiteColor];
        cover.color = [UIColor brownColor];
        [mutableArray addObject:cover];
        
        cover = [[Cover_ alloc] init];
        cover.title = @"Steve Jobs";
        cover.titleColor = [UIColor darkGrayColor];
        cover.color = [UIColor whiteColor];
        [mutableArray addObject:cover];
        
        covers__ = mutableArray;
    }
    
    return covers__;
}

#pragma mark - Private

- (void)updateCurrentCoverIndex_ {
    float f = self.gridView.contentOffset.x/self.gridView.bounds.size.width;
    NSInteger index = floorf(f);
    self.currentCoverIndex_ = index;
}

- (void)updatePageControl_ {
    self.pageControl.numberOfPages = [self.covers_ count];
    self.pageControl.currentPage = self.currentCoverIndex_;
}

- (void)configureCoverView_:(CoverView *)coverView withCover_:(Cover_ *)cover
{
    coverView.contentView.backgroundColor = cover.color;
    coverView.titleLabel.text = cover.title;
    coverView.titleLabel.textColor = cover.titleColor;
}

@end
