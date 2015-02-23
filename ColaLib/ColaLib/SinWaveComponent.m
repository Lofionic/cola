//
//  SinWaveComponent.m
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "SinWaveComponent.h"
#import "COLAudioEnvironment.h"
#import "COLComponentInput.h"

@interface SinWaveComponent () {
    Float64 phase;
}

@property (nonatomic, strong) COLComponentOutput *mainOut;
@property (nonatomic, strong) COLComponentInput *frequencyIn;
@property (nonatomic, strong) COLComponentInput *amplIn;

@property (nonatomic, strong) COLComponentParameter *frequency;

@end

@implementation SinWaveComponent

-(void)initializeIO {
    self.mainOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Out"];
    
    [self setOutputs:@[self.mainOut]];
    
    self.frequencyIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"FreqIn"];
    self.amplIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"AmpIn"];

    [self setInputs:@[self.frequencyIn, self.amplIn]];
}

-(void)renderOutputs:(UInt32)numFrames {

    [super renderOutputs:numFrames];
    
    // Input Buffers
    AudioSignalType *frequencyBuffer = [self.frequencyIn getBuffer:numFrames];
    AudioSignalType *ampBuffer = [self.amplIn getBuffer:numFrames];

    // Output Buffers
    AudioSignalType *mainOutBuffer = [self.mainOut prepareBufferOfSize:numFrames];
    
    Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    
    for (int i = 0; i < numFrames; i++) {
        AudioSignalType freq;
        AudioSignalType amp;
        
        if ([self.frequencyIn isConnected]) {
            freq = (frequencyBuffer[i] + 1);
        } else {
            freq = [self.frequency valueAtDelta:(i / (float)numFrames)];
        }
        
        phase += (M_PI * freq) / sampleRate;
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        
        if ([self.amplIn isConnected]) {
            amp = ampBuffer[i];
        } else {
            amp = 0.5f;
        }
        
        mainOutBuffer[i] = sin(phase) * amp;
    }
}

@end
