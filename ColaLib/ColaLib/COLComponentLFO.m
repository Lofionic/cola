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

@property (nonatomic, strong) COLComponentParameter *rate;
@property (nonatomic, strong) COLComponentParameter *waveform;

@end

@implementation COLComponentLFO

-(void)initializeIO {

    self.mainOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"Out"];
    [self setOutputs:@[self.mainOut]];
    
    self.freqIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"FreqIn"];
    [self setInputs:@[self.freqIn]];
    
    self.rate = [[COLComponentParameter alloc] initWithComponent:self withName:@"Rate"];
    [self.rate setNormalizedValue:0.5];
    
    self.waveform = [[COLComponentParameter alloc] initWithComponent:self withName:@"Wave"];
    [self setParameters:@[self.rate, self.waveform]];

}

-(void)renderOutputs:(UInt32)numFrames {
    
    [super renderOutputs:numFrames];
    // Input buffers
    AudioSignalType *frequencyBuffer = [self.freqIn getBuffer:numFrames];
    
    // Output buffer
    AudioSignalType *mainBuffer = [self.mainOut prepareBufferOfSize:numFrames];

    Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    
    for (int i = 0; i < numFrames; i++) {
        AudioSignalType freq = FLT_MIN;
        
        if ([self.freqIn isConnected]) {
            freq = frequencyBuffer[i] + 1;
        } else {
            freq = [self.rate outputAtDelta:i / (float)numFrames] * 10.0;
        }
        
        phase += (2.0 * M_PI * (freq)) / sampleRate;
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        mainBuffer[i] = sin(phase);
    }
}

@end
