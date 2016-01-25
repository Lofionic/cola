//
//  SequencerButton.h
//  ColaApp
//
//  Created by Chris Rivers on 25/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface SequencerButton : UIButton

typedef enum : NSUInteger {
    VerticalLight,
    Horizontal,
    Large
} SequencerButtonType;

@end
