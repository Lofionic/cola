//
//  COLComponentNoiseGenerator.m
//  ColaLib
//
//  Created by Chris on 05/05/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponentNoiseGenerator.h"
#define ARC4RANDOM_MAX      0x100000000

@interface COLComponentNoiseGenerator ()

@property (nonatomic, strong) COLComponentOutput *output;

@end

@implementation COLComponentNoiseGenerator

-(void)initializeIO {
    self.output = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Output"];
    [self setOutputs:@[self.output]];
}

-(void)renderOutputs:(UInt32)numFrames {
    [super renderOutputs:numFrames];
    
    AudioSignalType *outputBuffer = [self.output prepareBufferOfSize:numFrames];
    
    for (int i = 0; i < numFrames; i++) {
        AudioSignalType output = ((double)arc4random() / ARC4RANDOM_MAX) * 2.0 - 1.0;
        
        
        outputBuffer[i] = output;
    }
}

@end
