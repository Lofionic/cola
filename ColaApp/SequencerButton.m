//
//  SequencerButton.m
//  ColaApp
//
//  Created by Chris Rivers on 25/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import "SequencerButton.h"

const NSInteger ButtonStyleVertical       = 0;
const NSInteger ButtonStyleHorizontal     = 1;
const NSInteger ButtonStyleLarge          = 2;

@interface SequencerButton()

@property (nonatomic) IBInspectable     NSInteger buttonStyle;
@property (nonatomic, strong)           UIImage *ibImage;

#if TARGET_INTERFACE_BUILDER
@property (nonatomic) CGRect ibDrawRect;
#endif

@end

@implementation SequencerButton

-(void)setButtonStyle:(NSInteger)buttonStyle {
    _buttonStyle = buttonStyle;
    
    switch (self.buttonStyle) {
        case ButtonStyleVertical:
            [self setImage:[UIImage imageNamed:@"sequencer_button_vertical"] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"sequencer_button_vertical_down"] forState:UIControlStateHighlighted];
            break;
        case ButtonStyleHorizontal:
            [self setImage:[UIImage imageNamed:@"sequencer_button_horizontal"] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"sequencer_button_horizontal_down"] forState:UIControlStateHighlighted];
            break;
        default:
            self.ibImage = nil;
            break;
    }
}

#if TARGET_INTERFACE_BUILDER
-(void)prepareForInterfaceBuilder {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    switch (self.buttonStyle) {
        case ButtonStyleVertical:
            self.ibImage = [UIImage imageNamed:@"sequencer_button_vertical" inBundle:bundle compatibleWithTraitCollection:self.traitCollection];
            break;
        case ButtonStyleHorizontal:
            self.ibImage = [UIImage imageNamed:@"sequencer_button_horizontal" inBundle:bundle compatibleWithTraitCollection:self.traitCollection];
            break;
        default:
            self.ibImage = nil;
            break;
    }
    
    if (self.ibImage) {
        // Calculate a centered rect to draw into
        float offsetX = (self.bounds.size.width - self.ibImage.size.width) / 2.0;
        float offsetY = (self.bounds.size.height - self.ibImage.size.height) / 2.0;
        
        self.ibDrawRect = CGRectMake(offsetX, offsetY, self.ibImage.size.width, self.ibImage.size.height);
    } else {
        self.ibDrawRect = CGRectMake(0, 0, 0, 0);
    }
}

// Custom renderer for IB
- (void)drawRect:(CGRect)rect {
    if (self.ibImage) {
        [self.ibImage drawInRect:self.ibDrawRect];
    }
}
#endif

@end

