//
//  ModuleControl.h
//  ColaApp
//
//  Created by Chris on 01/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <ColaLib/ColaLib.h>
#import "ModuleDescription.h"

@interface ModuleControl : UIControl

+(ModuleControl*)controlForParameter:(COLParameter*)parameter Description:(ControlDescription*)description;
-(void)updateFromParameter;

@end
