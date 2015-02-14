//
//  COLComponentOutput.h
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "COLComponentIO.h"
#import "COLDefines.h"

@class COLComponent;
@class COLComponentInput;
@class COLComponentOutput;
@protocol COLOutputDelegate <NSObject>

-(void)renderOutput:(COLComponentOutput *)output toBuffer:(AudioSignalType *)outA samples:(UInt32)numFrames;

@end

@interface COLComponentOutput : COLComponentIO

@property (nonatomic, weak) COLComponentInput *connectedTo;

-(void)renderBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames;

@end
