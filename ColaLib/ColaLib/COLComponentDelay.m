//
//  COLComponentDelay.m
//  ColaLib
//
//  Created by Chris on 06/06/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponentDelay.h"
#import "COLContinuousParameter.h"
#import "COLAudioEnvironment.h"

const float maxDelayTimeMS = 2000;

@interface COLComponentDelay() {
    AudioSignalType* delayBuffer;
    UInt32 bufferLocation;
    UInt32 bufferSize;
}

@property (nonatomic, strong) COLComponentInput *input;
@property (nonatomic, strong) COLComponentOutput *output;

@property (nonatomic, strong) COLContinuousParameter *delayTime;
@property (nonatomic, strong) COLContinuousParameter *feedback;
@property (nonatomic, strong) COLContinuousParameter *mix;

@end

@implementation COLComponentDelay

-(void)initializeIO {
    self.input = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"input"];
    self.inputs = @[self.input];
    
    self.output = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"output"];
    self.outputs = @[self.output];
    
    self.delayTime = [[COLContinuousParameter alloc] initWithComponent:self withName:@"delayTime"];
    self.mix = [[COLContinuousParameter alloc] initWithComponent:self withName:@"mix"];
    self.feedback = [[COLContinuousParameter alloc] initWithComponent:self withName:@"feedback"];
    self.parameters = @[self.delayTime, self.mix, self.feedback];
    
    [self.mix setNormalizedValue:0.2];
    [self.feedback setNormalizedValue:0.8];
    [self.delayTime setNormalizedValue:0.5];
    
    // Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    
    // bufferSize = sampleRate * (maxDelayTimeMS / 1000);
    
    free(delayBuffer);
    delayBuffer = (AudioSignalType*)malloc(bufferSize * sizeof(AudioSignalType));
    memset(delayBuffer, 0, bufferSize * sizeof(AudioSignalType));
    
    bufferLocation = 0;

}

-(void)renderOutputs:(UInt32)numFrames {
    [super renderOutputs:numFrames];
    
    AudioSignalType* inputBuffer = [self.input getBuffer:numFrames];
    AudioSignalType* outputBuffer = [self.output prepareBufferOfSize:numFrames];
  
    for (int i = 0; i < numFrames; i++) {
        float delta = i / (float) numFrames;
        
        float feedback = [self.feedback outputAtDelta:delta];
        float mix = [self.mix outputAtDelta:delta];
        
        AudioSignalType inSignal = inputBuffer[i];
        AudioSignalType delaySignal = inSignal + delayBuffer[bufferLocation];
        
        if (delaySignal > 1.0) {
            delaySignal = 1.0;
        } else if (delaySignal < -1.0) {
            delaySignal = -1.0;
        }
    
        outputBuffer[i] = inSignal + (delaySignal - inSignal) * mix;
        
        AudioSignalType feedbackSignal = inSignal + (delaySignal * feedback);
        if (feedbackSignal > 1.0) {
            feedbackSignal = 1.0;
        } else if (feedbackSignal < -1.0) {
            feedbackSignal = -1.0;
        }

        float delayTime = [self.delayTime outputAtDelta:delta];

        // Skip ahead by n number of samples
        UInt32 n = 1 + (10.0 * delayTime);
        for (int j = 0; j <= n; j++) {
            delayBuffer[bufferLocation] = feedbackSignal;
            bufferLocation ++;
            if (bufferLocation >= bufferSize) {
                bufferLocation -= bufferSize;
            }
        }

        
    }
}

@end
