//
//  RotaryEncoder.h
//  ColaApp
//
//  Created by Chris on 23/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <ColaLib/ColaLib.h>
#import <UIKit/UIKit.h>

@class EncoderDescription;
@interface RotaryEncoder : UIControl

@property (readonly, weak) COLComponentParameter *parameter;
@property (nonatomic) double value;

-(instancetype)initWithDescription:(EncoderDescription*)encoderDescription forComponent:(COLComponent*)component;

@end
