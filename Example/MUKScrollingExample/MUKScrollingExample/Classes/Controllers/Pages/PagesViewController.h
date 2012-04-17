//
//  PagesViewController.h
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 17/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GridViewController.h"

@interface PagesViewController : GridViewController
@property (nonatomic, strong) IBOutlet UITextField *pagesTextField, *scrollTextField;
@property (nonatomic, strong) IBOutlet UILabel *pageIndexLabel;
@end
