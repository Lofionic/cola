//
//  LFOComponent.h
//  ColaLib
//
//  Created by Chris on 13/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLComponent.h"

@interface LFOComponent : COLComponent

@property (readonly) COLComponentOutput *mainOut;
@property float frequency;

@end
