//
//  COLComponentInput.h
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "COLComponentIO.h"
#import "COLDefines.h"

@class COLComponentOutput;

@interface COLComponentInput : COLComponentIO

@property (nonatomic, weak) COLComponentOutput *connectedTo;

-(AudioSignalType*)getBuffer:(UInt32)numFrames;

-(void)renderComponents:(UInt32)numFrames;
-(void)engineDidRender;

@end
