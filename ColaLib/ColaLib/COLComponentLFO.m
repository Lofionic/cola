//
//  LFOComponent.m
//  ColaLib
//
//  Created by Chris on 13/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLDefines.h"
#import "COLContinuousParameter.h"
#import "COLDiscreteParameter.h"
#import "COLComponentLFO.h"
#import "COLAudioEnvironment.h"

@interface COLComponentLFO () {
    Float64 phase;

}

@property (nonatomic, strong) COLComponentOutput *mainOut;
@property (nonatomic, strong) COLComponentInput *freqIn;

@property (nonatomic, strong) COLContinuousParameter *rate;
@property (nonatomic, strong) COLDiscreteParameter *waveform;

@end

@implementation COLComponentLFO

-(void)initializeIO {

    self.mainOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"Out"];
    [self setOutputs:@[self.mainOut]];
    
    self.freqIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"FreqIn"];
    [self setInputs:@[self.freqIn]];
    
    self.rate = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Rate"];
    [self.rate setNormalizedValue:0.5];
    
    self.waveform = [[COLDiscreteParameter alloc] initWithComponent:self withName:@"Wave" max:5];
    [self setParameters:@[self.rate, self.waveform]];
}


-(void)renderOutputs:(UInt32)numFrames {
    
    [super renderOutputs:numFrames];
    // Input buffers
    AudioSignalType *frequencyBuffer = [self.freqIn getBuffer:numFrames];
    
    // Output buffer
    AudioSignalType *outBuffer = [self.mainOut prepareBufferOfSize:numFrames];

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
        
        float sampleIndexFloat = (phase / (M_PI * 2)) * (WAVETABLE_SIZE - 1);
        
        NSInteger waveform = [self.waveform selectedIndex];
        AudioSignalType sampleIndexLower = 0;
        AudioSignalType sampleIndexUpper = 0;
        if (waveform == 0) {
            // Sinwave
            sampleIndexLower = sinWaveTable[(int)floor(sampleIndexFloat)];
            sampleIndexUpper = sinWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveform == 1) {
            // Triwave
            sampleIndexLower = triWaveTable[(int)floor(sampleIndexFloat)];
            sampleIndexUpper = triWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveform == 2) {
            // Sawtooth
            sampleIndexLower = sawWaveTable[(int)floor(sampleIndexFloat)];
            sampleIndexUpper = sawWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveform == 3) {
            // Ramp
            sampleIndexLower = rampWaveTable[(int)floor(sampleIndexFloat)];
            sampleIndexUpper = rampWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveform == 4) {
            // Square
            sampleIndexLower = squareWaveTable[(int)floor(sampleIndexFloat)];
            sampleIndexUpper = squareWaveTable[(int)ceil(sampleIndexFloat)];
        }
        
        float remainder = fmodf(sampleIndexFloat, 1);
        
        outBuffer[i] = sampleIndexLower + (sampleIndexUpper - sampleIndexLower) * remainder;
    }
}

@end
