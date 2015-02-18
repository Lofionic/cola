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

-(void)renderInputs:(UInt32)numFrames;
-(void)renderOutputs:(UInt32)numFrames;
-(void)engineDidRender;

@end

@interface COLComponentOutput : COLComponentIO

@property (nonatomic, weak) COLComponentInput *connectedTo;

-(AudioSignalType*)getBuffer:(UInt32)numFrames;
-(AudioSignalType*)prepareBufferOfSize:(UInt32)numFrames;

-(void)renderComponents:(UInt32)numFrames;
-(void)engineDidRender;

-(BOOL)connectTo:(COLComponentInput*)input;



@end
