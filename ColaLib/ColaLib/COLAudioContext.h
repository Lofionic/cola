//
//  COLAudioContext.h
//  ColaLib
//
//  Created by Chris on 17/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>
@class COLComponentInput;
@interface COLAudioContext : NSObject

+ (instancetype) globalContext;
- (COLComponentInput*)masterInputAtIndex:(NSInteger)index;

@end
