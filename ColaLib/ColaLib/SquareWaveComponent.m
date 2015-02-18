//
//  SquareWaveComponent.m
//  ColaLib
//
//  Created by Chris on 14/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "SquareWaveComponent.h"
#import "COLAudioEnvironment.h"
#import "COLComponentInput.h"

@interface SquareWaveComponent () {
    Float64 phase;
}

@property (nonatomic, strong) COLComponentOutput *mainOut;
@property (nonatomic, strong) COLComponentInput *frequencyIn;
@property (nonatomic, strong) COLComponentInput *ampIn;

@end

@implementation SquareWaveComponent

-(void)initializeIO {
    self.frequency = 440.0;
    self.mainOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Out"];
    
    [self setOutputs:@[self.mainOut]];
    
    self.frequencyIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"FreqIn"];
    self.ampIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"AmpIn"];
    
    [self setInputs:@[self.frequencyIn, self.ampIn]];
    
}

-(void)renderOutputs:(UInt32)numFrames {
    
    [super renderOutputs:numFrames];
    
    // Input buffers
    AudioSignalType *frequencyBuffer = [self.frequencyIn getBuffer:numFrames];
    AudioSignalType *ampBuffer = [self.ampIn getBuffer:numFrames];
    
    // Output buffers
    AudioSignalType *outbuffer = [self.mainOut prepareBufferOfSize:numFrames];
    
    Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    
    for (int i = 0; i < numFrames; i++) {
        AudioSignalType amp;
        if ([self.ampIn connectedTo]) {
            amp = ampBuffer[i];
        } else {
            amp = 1.0;
        }
        
        AudioSignalType freq;
        if ([self.frequencyIn connectedTo]) {
            freq = (frequencyBuffer[i] + 1) * self.frequency;
        } else {
            freq = self.frequency;
        }
        
        phase += (2.0 * M_PI * freq) / sampleRate;
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        AudioSignalType wave = (phase < M_PI_2) ? 1.0 : -1.0;
        outbuffer[i] = wave * amp;
    }
}

@end
