//
//  RootViewController.m
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 14/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#import "SquaresViewController.h"
#import "PagesViewController.h"
#import "ImagesViewController.h"
#import "ThumbnailsViewController.h"

@interface RootViewControllerRow_ : NSObject
@property (nonatomic, strong) NSString *title, *subtitle;
@property (nonatomic, copy) void (^selectionHandler)(void);
@end

@implementation RootViewControllerRow_
@synthesize title, subtitle;
@synthesize selectionHandler;
@end

#pragma mark - 
#pragma mark - 

@interface RootViewController ()
@property (nonatomic, strong) NSArray *rows_;
@end

@implementation RootViewController
@synthesize rows_;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Accessors

- (NSArray *)rows_ {
    if (rows_ == nil) {
        __unsafe_unretained RootViewController *weakSelf = self;
        NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
        RootViewControllerRow_ *row;
        
        row = [[RootViewControllerRow_ alloc] init];
        row.title = @"Squares";
        row.subtitle = @"Grid view with squares";
        row.selectionHandler = ^{
            SquaresViewController *viewController = [[SquaresViewController alloc] initWithNibName:nil bundle:nil];
            viewController.title = @"Squares";
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        };
        [mutableArray addObject:row];
        
        
        row = [[RootViewControllerRow_ alloc] init];
        row.title = @"Pages";
        row.subtitle = @"Grid view with horizontal paging";
        row.selectionHandler = ^{
            PagesViewController *viewController = [[PagesViewController alloc] initWithNibName:nil bundle:nil];
            viewController.title = @"Pages";
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        };
        [mutableArray addObject:row];
        
        
        row = [[RootViewControllerRow_ alloc] init];
        row.title = @"Images";
        row.subtitle = @"Grid view with images carousel";
        row.selectionHandler = ^{
            ImagesViewController *viewController = [[ImagesViewController alloc] initWithNibName:nil bundle:nil];
            viewController.title = @"Images";
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        };
        [mutableArray addObject:row];
        
        
        row = [[RootViewControllerRow_ alloc] init];
        row.title = @"Thumbnails";
        row.subtitle = @"Thumbnails grid";
        row.selectionHandler = ^{
            ThumbnailsViewController *viewController = [[ThumbnailsViewController alloc] initWithNibName:nil bundle:nil];
            viewController.title = @"Thumbnails";
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        };
        [mutableArray addObject:row];
        
        
        rows_ = mutableArray;
    }
    
    return rows_;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.rows_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    RootViewControllerRow_ *row = [self.rows_ objectAtIndex:indexPath.row];
    cell.textLabel.text = row.title;
    cell.detailTextLabel.text = row.subtitle;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RootViewControllerRow_ *row = [self.rows_ objectAtIndex:indexPath.row];
    if (row.selectionHandler) {
        row.selectionHandler();
    }
}

@end
