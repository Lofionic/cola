//
//  LFOComponent.m
//  ColaLib
//
//  Created by Chris on 13/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "LFOComponent.h"
#import "COLAudioEnvironment.h"

@interface LFOComponent () {
    float phase;
}

@property (nonatomic, strong) COLComponentOutput *mainOut;

@end

@implementation LFOComponent

-(void)initializeIO {
    self.frequency = 1;
    self.mainOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"Out"];
    
    [self setOutputs:@[self.mainOut]];
}

-(void)renderOutputs:(UInt32)numFrames {
    
    [super renderOutputs:numFrames];
    
    // Output buffer
    AudioSignalType *mainBuffer = [self.mainOut prepareBufferOfSize:numFrames];

    Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    
    for (int i = 0; i < numFrames; i++) {
        phase += (2.0 * M_PI * self.frequency) / sampleRate;
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        mainBuffer[i] = 0.5 + (sin(phase) / 2);
    }
}


@end
