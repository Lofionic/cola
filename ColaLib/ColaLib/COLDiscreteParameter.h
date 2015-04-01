//
//  COLComponentIndexedParameter.h
//  ColaLib
//
//  Created by Chris on 01/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLParameter.h"

@interface COLDiscreteParameter : COLParameter

@property (nonatomic, readonly) NSInteger maxIndex;
@property (nonatomic) NSInteger selectedIndex;

-(instancetype)initWithComponent:(COLComponent*)component withName:(NSString*)name max:(NSInteger)max;

@end
