//
//  LFOComponent.m
//  ColaLib
//
//  Created by Chris on 13/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLComponentLFO.h"
#import "COLAudioEnvironment.h"

@interface COLComponentLFO () {
    float phase;
}

@property (nonatomic, strong) COLComponentOutput *mainOut;
@property (nonatomic, strong) COLComponentInput *freqIn;

@end

@implementation COLComponentLFO

-(void)initializeIO {
    self.frequency = 1;
    self.mainOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"Out"];
    [self setOutputs:@[self.mainOut]];
    
    self.freqIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"FreqIn"];
    [self setInputs:@[self.freqIn]];
}

-(void)renderOutputs:(UInt32)numFrames {
    
    [super renderOutputs:numFrames];
    // Input buffers
    AudioSignalType *frequencyBuffer = [self.freqIn getBuffer:numFrames];
    
    // Output buffer
    AudioSignalType *mainBuffer = [self.mainOut prepareBufferOfSize:numFrames];

    Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    
    for (int i = 0; i < numFrames; i++) {
        AudioSignalType freq;
        if ([self.freqIn isConnected]) {
            freq = frequencyBuffer[i] + 1;
        } else {
            freq = 2;
        }
        
        phase += (2.0 * M_PI * (self.frequency * freq)) / sampleRate;
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        mainBuffer[i] = 0.5 + (sin(phase) / 2);
    }
}

@end
