//
//  COLTransportController.m
//  ColaLib
//
//  Created by Chris on 25/05/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLTransportController.h"
#import "COLAudioEnvironment.h"

@interface COLTransportController () {
    Float64 timeInMS;
    NSUInteger step;
    Float64 bpm;
    
    UInt32 bufferSize;
}

@property (nonatomic) BOOL playing;
@property (nonatomic) UInt16  *stepBuffer;
@property (nonatomic) Float32 *stepDeltaBuffer;

@end

@implementation COLTransportController 

-(instancetype)init {
    if (self = [super init]) {
        timeInMS = 0;
        step = 0;
        bpm = 120;
    }
    return self;
}

-(void)start {
    self.playing = YES;
}

-(void)stop {
    self.playing = NO;
}

-(void)reset {
    timeInMS = 0;
    step = 0;
}

-(void)renderOutputs:(UInt32)numFrames {

    // Prepare the step buffer
    if (numFrames != bufferSize) {
        NSLog(@"Transport controller creating step buffer of size : %i", (unsigned int)numFrames);
        free(self.stepBuffer);
        bufferSize = numFrames;
        self.stepBuffer = (UInt16*)malloc(bufferSize * sizeof(UInt16));
        memset(self.stepBuffer, 0, bufferSize * sizeof(UInt16));
        
        self.stepDeltaBuffer = (Float32*)malloc(bufferSize * sizeof(Float32));
        memset(self.stepDeltaBuffer, 0, bufferSize * sizeof(Float32));
    }
    
    Float64 msPerBeat = (60 / bpm) * 1000;
    Float64 msPerStep = msPerBeat / 4.0;
    Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    
    for (int i = 0; i < numFrames; i++) {
        
        if (self.playing) {
            timeInMS += 1000 / sampleRate;
            while (timeInMS > msPerStep) {
                step ++;
                if (step > 15) {
                    step = 0;
                }
                timeInMS -= msPerStep;
            }
        }
        self.stepBuffer[i] = step;
        self.stepDeltaBuffer[i] = timeInMS / msPerStep;
    }
}

@end
