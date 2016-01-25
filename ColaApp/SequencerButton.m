//
//  SequencerButton.m
//  ColaApp
//
//  Created by Chris Rivers on 25/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import "SequencerButton.h"

const NSInteger ButtonStyleVerticalLight  = 0;
const NSInteger ButtonStyleHorizontal     = 1;
const NSInteger ButtonStyleLarge          = 2;

@interface SequencerButton()

@property (nonatomic) IBInspectable NSInteger buttonStyle;
@property (nonatomic, strong) UIImage *ibImage;

@end

@implementation SequencerButton

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setButtonStyle:VerticalLight];
    }
    
    return self;
}

//@synthesize buttonStyle = _buttonStyle;
-(void)setButtonStyle:(NSInteger)buttonStyle {
    _buttonStyle = buttonStyle;
    
    if (buttonStyle == ButtonStyleVerticalLight) {
        [self setImage:[UIImage imageNamed:@"sequencer_button_vertical_off"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"sequencer_button_vertical_on"] forState:UIControlStateSelected];
        [self setImage:[UIImage imageNamed:@"sequencer_button_vertical_highlight"] forState:UIControlStateHighlighted];
    }
}

#if TARGET_INTERFACE_BUILDER
-(void)awakeFromNib {
    // Default button style
    self.buttonStyle = ButtonStyleVerticalLight;
}

-(void)prepareForInterfaceBuilder {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    if (self.buttonStyle == ButtonStyleVerticalLight) {
    self.ibImage = [UIImage imageNamed:@"sequencer_button_vertical_off" inBundle:bundle compatibleWithTraitCollection:self.traitCollection];
    } else {
        self.ibImage = nil;
    }
}

// Custom renderer for IB
- (void)drawRect:(CGRect)rect {
    if (self.ibImage) {
        [self.ibImage drawInRect:self.bounds];
    }
}
#endif

@end

