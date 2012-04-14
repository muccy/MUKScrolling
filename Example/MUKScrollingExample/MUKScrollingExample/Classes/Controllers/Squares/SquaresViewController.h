//
//  SquaresViewController.h
//  MUKScrollingExample
//
//  Created by Marco Muccinelli on 14/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GridViewController.h"

@interface SquaresViewController : GridViewController <UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITextField *cellsTextField;
@property (nonatomic, strong) IBOutlet UISwitch *verticalSwitch;

- (IBAction)verticalSwitchValueChanged:(id)sender;
@end
