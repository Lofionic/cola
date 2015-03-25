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
#import "COLKeyboardComponent.h"

#define CV_FREQUENCY_RANGE 8372

@interface COLComponentOscillator () {
    Float64 phase;
}

@property (nonatomic, strong) COLComponentOutput *mainOut;

@property (nonatomic, strong) COLComponentInput *keyboardIn;
@property (nonatomic, strong) COLComponentInput *frequencyIn;
@property (nonatomic, strong) COLComponentInput *amplIn;

@property (nonatomic, strong) COLComponentParameter *frequency;

@property (nonatomic, weak) COLComponentOutput *keyboardOutput;

@end

@implementation COLComponentOscillator

-(instancetype)initWithContext:(COLAudioContext *)context {
    if (self = [super initWithContext:context]) {

    }
    return self;
}

-(void)initializeIO {
    self.frequencyIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"FreqIn"];
    self.amplIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"AmpIn"];
    [self setInputs:@[self.frequencyIn, self.amplIn]];
    
    self.mainOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Out"];
    [self setOutputs:@[self.mainOut]];
    
    self.frequency = [[COLComponentParameter alloc] initWithComponent:self withName:@"Freq"];
    [self.frequency setNormalizedValue:0];
    [self setParameters:@[self.frequency]];
    
    self.keyboardOutput = [[[COLAudioEnvironment sharedEnvironment] keyboardComponent] outputForIndex:0];
}

-(void)renderOutputs:(UInt32)numFrames {

    [super renderOutputs:numFrames];

    // Input Buffers
    AudioSignalType *frequencyBuffer = [self.frequencyIn getBuffer:numFrames];
    AudioSignalType *ampBuffer = [self.amplIn getBuffer:numFrames];
    
    // Keyboard Buffer
    AudioSignalType *keyboardBuffer = [self.keyboardOutput getBuffer:numFrames];

    // Output Buffers
    AudioSignalType *mainOutBuffer = [self.mainOut prepareBufferOfSize:numFrames];

    Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];

    for (int i = 0; i < numFrames; i++) {
        AudioSignalType freq;
        AudioSignalType amp;
        
        if ([self.frequencyIn isConnected]) {
            freq = (frequencyBuffer[i] + 1);
        } else {
            //freq = [self.frequency outputAtDelta:i / (float)numFrames];
            freq = keyboardBuffer[i];
        }
        
        phase += (M_PI * freq * CV_FREQUENCY_RANGE) / sampleRate;
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        
        if ([self.amplIn isConnected]) {
            amp = ampBuffer[i] * 0.9f;
        } else {
            amp = 1.0;
        }
        AudioSignalType outputValue = sin(phase) * amp;
        
        mainOutBuffer[i] = outputValue;
    }
}

@end
