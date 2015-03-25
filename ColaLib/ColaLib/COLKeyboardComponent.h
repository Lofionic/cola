//
//  COLKeyboardComponent.h
//  ColaLib
//
//  Created by Chris on 25/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponent.h"

@interface COLKeyboardComponent : COLComponent

-(void)noteOn:(NSInteger)note;
-(void)noteOff:(NSInteger)note;

@end
