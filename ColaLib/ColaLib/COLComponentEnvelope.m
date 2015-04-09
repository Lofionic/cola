//
//  COLCompenentEnvelope.m
//  ColaLib
//
//  Created by Chris on 28/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLComponentEnvelope.h"
#import "COLAudioEnvironment.h"
#import "COLContinuousParameter.h"

#define MEDIAN_WINDOW_SIZE 50

@interface COLComponentEnvelope() {
    
    BOOL gateOpen;
    UInt32 gateOpenInterval;    // Number of samples gate has been open for
    UInt32 gateClosedInterval;      // Sample after opening at which gate was closed
    AudioSignalType gatePeak;
    kCOLEnvelopeState envelopeState;
    
    AudioSignalType medianWindow[MEDIAN_WINDOW_SIZE];
    AudioSignalType medianWindowSigma;
    UInt32 medianWindowPosition;
    
}

@property (nonatomic, strong) COLComponentInput *gate;
@property (nonatomic, strong) COLComponentOutput *output;

@property (nonatomic, strong) COLContinuousParameter *attackTime;
@property (nonatomic, strong) COLContinuousParameter *decayTime;
@property (nonatomic, strong) COLContinuousParameter *sustainLevel;
@property (nonatomic, strong) COLContinuousParameter *releaseTime;

@end

@implementation COLComponentEnvelope

-(instancetype)initWithContext:(COLAudioContext *)context {
    if (self = [super initWithContext:context]) {
        gateOpen = false;
        gateOpenInterval = 0;
        
        for (int i = 0; i < MEDIAN_WINDOW_SIZE; i++) {
            medianWindow[i] = 0;
        }
        medianWindowSigma = 0;
        medianWindowPosition = 0;
    }
    return self;
}

-(void)initializeIO {
    
    self.gate = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeGate withName:@"Gate"];
    [self setInputs:@[self.gate]];
    
    self.output = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"Out"];
    [self setOutputs:@[self.output]];
    
    self.attackTime = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Attack"];
    [self.attackTime setNormalizedValue:0];
    
    self.decayTime = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Decay"];
    [self.decayTime setNormalizedValue:1];
    
    self.sustainLevel = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Sustain"];
    [self.sustainLevel setNormalizedValue:1];
    
    self.releaseTime = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Release"];
    [self.releaseTime setNormalizedValue:0];
    
    [self setParameters:@[self.attackTime, self.decayTime, self.sustainLevel, self.releaseTime]];
}

-(void)renderOutputs:(UInt32)numFrames {
    
    [super renderOutputs:numFrames];
    
    AudioSignalType *outputBuffer = (AudioSignalType*)[self.output prepareBufferOfSize:numFrames];
    
    AudioSignalType *gateBuffer = [self.gate getBuffer:numFrames];
    
    Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    
    for (int i = 0; i < numFrames; i++) {
        
        float attackTime = [self.attackTime outputAtDelta:i / (float)numFrames];
        UInt32 attackSamples = attackTime * sampleRate;
        
        float decayTime = [self.decayTime outputAtDelta:i / (float)numFrames];
        UInt32 decaySamples = decayTime * sampleRate;
        
        float sustainLevel = [self.sustainLevel outputAtDelta:i / (float)numFrames];
        
        float releaseTime = [self.releaseTime outputAtDelta:i / (float)numFrames];
        UInt32 releaseSamples = releaseTime * sampleRate;
        
        
        // Iterate the gate position
        envelopeState = kCOLEnvelopeStateClosed;
        
        float gate = gateBuffer[i];
        
        if (gateOpen && gate == 0) {
            [self closeGate];
        } else if (!gateOpen && gate == 1) {
            [self openGate];
        }
        
        if (gateOpen) {
            
            gateOpenInterval ++;
            
            // Determine the envelope state
            if (gateOpenInterval > 0) {
                envelopeState = kCOLEnvelopeStateAttack;
            }
            
            if (gateOpenInterval > attackSamples) {
                envelopeState = kCOLEnvelopeStateDecay;
            }
            
            if (gateOpenInterval > attackSamples + decaySamples) {
                envelopeState = kCOLEnvelopeStateSustain;
            }
            
        } else if (gateOpenInterval > 0) {
            
            gateClosedInterval ++;
            
            envelopeState = kCOLEnvelopeStateRelease;
            
            if (gateClosedInterval > releaseSamples) {
                envelopeState =kCOLEnvelopeStateClosed;
                [self resetGate];
            }
        }
        
        // Return the envelope output level
        AudioSignalType outputValue = 0;
        
        switch (envelopeState) {
            case kCOLEnvelopeStateAttack:
                outputValue = (AudioSignalType)((float)gateOpenInterval / attackSamples);
                gatePeak = outputValue;
                break;
            case kCOLEnvelopeStateDecay: {
                float delta = (gateOpenInterval - attackSamples) / (float)decaySamples;
                outputValue = 1.0 + (sustainLevel - 1.0) * delta;
                gatePeak = outputValue;
            }
                break;
            case kCOLEnvelopeStateSustain:
                outputValue = (AudioSignalType)sustainLevel;
                gatePeak = outputValue;
                break;
            case kCOLEnvelopeStateRelease: {
                float delta = (gateClosedInterval) / (float)releaseSamples;
                outputValue = gatePeak * (1 - delta);
            }
                break;
            default:
                break;
        }
        
        // Smooth out the signal
        medianWindowSigma -= medianWindow[medianWindowPosition];
        medianWindow[medianWindowPosition] = outputValue;
        medianWindowSigma += outputValue;
        
        medianWindowPosition++;
        if (medianWindowPosition >= MEDIAN_WINDOW_SIZE) {
            medianWindowPosition = 0;
        }
        
        outputValue = medianWindowSigma / MEDIAN_WINDOW_SIZE;
        outputBuffer[i] = outputValue;
    }
}

-(void)openGate {
    if (self.retriggers) {
        [self resetGate];
    }
    gateOpen = true;
    gatePeak = 0;
}

-(void)closeGate {
    if (gateOpen) {
        gateOpen = false;
        gateClosedInterval = 0;
    }
}

-(void)resetGate {
    gateOpen = false;
    gateOpenInterval = 0;
}

+(NSString *)defaultName {
    return @"EG";
}

@end
