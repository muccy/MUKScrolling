//
//  MUKGridView_Cell.h
//  MUKScrolling
//
//  Created by Marco Muccinelli on 05/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MUKGridView.h"

@class MUKGridCellView_;
@interface MUKGridView ()
- (void)attachHandlersToNewCellView_:(MUKGridCellView_ *)cellView;
- (void)attachRequiredGestureRecognizersToCellView_:(MUKGridCellView_ *)cellView;

- (void)handleCellTap_:(UITapGestureRecognizer *)recognizer;
- (void)handleCellDoubleTap_:(UITapGestureRecognizer *)recognizer;
- (void)handleCellLongPress_:(UILongPressGestureRecognizer *)recognizer;
@end
