//
//  COLAudioContext.h
//  ColaLib
//
//  Created by Chris on 17/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface COLAudioContext : NSObject

@property (readonly, strong) NSArray *masterInputs;

+ (instancetype) globalContext;

@end
