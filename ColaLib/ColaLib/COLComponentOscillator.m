//
//  SinWaveComponent.m
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLComponentOscillator.h"
#import "COLAudioEnvironment.h"
#import "COLComponentInput.h"

@interface COLComponentOscillator () {
    Float64 phase;
    
    AudioSignalType meterHoldSigma;
    UInt64 meterHoldPosition;
    AudioSignalType meterHold[50];
}

@property (nonatomic, strong) COLComponentOutput *mainOut;
@property (nonatomic, strong) COLComponentOutput *meterOut;
@property (nonatomic, strong) COLComponentInput *frequencyIn;
@property (nonatomic, strong) COLComponentInput *amplIn;

@property (nonatomic, strong) COLComponentParameter *frequency;

@end

@implementation COLComponentOscillator

-(void)initializeIO {
    self.mainOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Out"];
    self.meterOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"Meter Out"];
    
    [self setOutputs:@[self.mainOut, self.meterOut]];
    
    self.frequencyIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"FreqIn"];
    self.amplIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"AmpIn"];

    [self setInputs:@[self.frequencyIn, self.amplIn]];
    
    self.frequency = [[COLComponentParameter alloc] init];
    [self setParameters:@[self.frequency]];
}

-(void)renderOutputs:(UInt32)numFrames {

    [super renderOutputs:numFrames];
    
    // Input Buffers
    AudioSignalType *frequencyBuffer = [self.frequencyIn getBuffer:numFrames];
    AudioSignalType *ampBuffer = [self.amplIn getBuffer:numFrames];

    // Output Buffers
    AudioSignalType *mainOutBuffer = [self.mainOut prepareBufferOfSize:numFrames];
    AudioSignalType *meterOut = [self.meterOut prepareBufferOfSize:numFrames];
    
    int meterHoldSize = sizeof(meterHold) / sizeof(meterHold[0]);
    
    AudioSignalType meterHoldHold = 0;
    
    Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    
    for (int i = 0; i < numFrames; i++) {
        AudioSignalType freq;
        AudioSignalType amp;
        
        if ([self.frequencyIn isConnected]) {
            freq = (frequencyBuffer[i] + 1);
        } else {
            freq = [self.frequency outputAtDelta:(i / (float)numFrames)];
        }
        
        phase += (M_PI * freq * kOscillatorFrequencyRange) / sampleRate;
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        
        if ([self.amplIn isConnected]) {
            amp = ampBuffer[i];
        } else {
            amp = 0.5f;
        }
        
        mainOutBuffer[i] = sin(phase) * amp;
        
        AudioSignalType sample = mainOutBuffer[i];
        
        if (i % 50 == 0) {
            meterHoldSigma -= meterHold[meterHoldPosition];
            meterHold[meterHoldPosition] = fabsf(sample);
            meterHoldSigma += fabsf(sample);
            
            meterHoldPosition ++;
            if (meterHoldPosition >= meterHoldSize) {
                meterHoldPosition = 0;
            }
            
            meterHoldHold = meterHoldSigma / meterHoldSize;
        }
        
        meterOut[i] = meterHoldHold;
    }
}

@end
