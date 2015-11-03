//
//  ModuleControl.h
//  ColaApp
//
//  Created by Chris on 01/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <ColaLib/CCOLTypes.h>
#import "ModuleDescription.h"

@interface ControlView : UIControl

@property (readonly) CCOLParameterAddress parameter;

+(ControlView*)controlForParameter:(CCOLParameterAddress)parameter Description:(ControlDescription*)description;
-(instancetype)initWithParameter:(CCOLParameterAddress)parameter Description:(ControlDescription*)description;

-(void)updateFromParameter;

-(NSObject*)getDictionaryObject;
-(void)setFromDictionaryObject:(NSObject*)object;

@end
