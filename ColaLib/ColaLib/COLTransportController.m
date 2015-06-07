//
//  COLTransportController.m
//  ColaLib
//
//  Created by Chris on 25/05/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLTransportController.h"
#import "COLAudioEnvironment.h"
#import "COLAudioEngine.h"

@interface COLTransportController () {
    Float64 timeInMS;
    NSUInteger step;
    Float64 tempo;
    
    UInt32 bufferSize;
    Float64 currentBeat;
}

@property (nonatomic) BOOL isPlaying;
@property (nonatomic) Float64 *beatBuffer;

@end

@implementation COLTransportController 

-(instancetype)init {
    if (self = [super init]) {
        timeInMS = 0;
        step = 0;
        tempo = 120;
    }
    return self;
}

-(void)start {
    self.isPlaying = YES;
    [self postUpdateNotification];
}

-(void)stop {
    self.isPlaying = NO;
    [self postUpdateNotification];
}

-(void)stopAndReset {
    self.isPlaying = NO;
    timeInMS = 0;
    step = 0;
    [self postUpdateNotification];
}

-(void)postUpdateNotification {
    NSDictionary *notificationUserInfo = @{
                                           @"transportController" : self
                                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCOLEventTransportStateUpdated object:nil userInfo:notificationUserInfo];
}

-(void)renderOutputs:(UInt32)numFrames {
    // Prepare the step buffer
    if (numFrames != bufferSize) {
        NSLog(@"Transport controller creating step buffer of size : %i", (unsigned int)numFrames);
        free(self.beatBuffer);
        bufferSize = numFrames;
        self.beatBuffer = (Float64*)malloc(bufferSize * sizeof(Float64));
        memset(self.beatBuffer, 0, bufferSize * sizeof(Float64));
    }

    
    Float64 barLength = (60 / tempo) * 4;
    Float64 barSamples = barLength * [[COLAudioEnvironment sharedEnvironment] sampleRate];
    Float64 sampleDelta = 4.0 / barSamples;
    
    for (int i = 0; i < numFrames; i++) {
        
        if (self.isPlaying) {
            self.beatBuffer[i] = currentBeat;
            currentBeat += sampleDelta;
        }
    }
    
    [self syncWithIAA];
}

// Manage sync with IAA transport
-(void)interappAudioTransportStateDidChange {
    COLAudioEngine *engine = [[COLAudioEnvironment sharedEnvironment] audioEngine];
    if (engine.isHostPlaying && !self.isPlaying) {
        
        [self syncWithIAA];
        self.isPlaying = YES;
        [self postUpdateNotification];
    } else if (!engine.isHostPlaying && self.isPlaying) {
        self.isPlaying = NO;
        [self postUpdateNotification];
    }
}

-(void)syncWithIAA {
    COLAudioEngine *audioEngine = [[COLAudioEnvironment sharedEnvironment] audioEngine];
    if (audioEngine.iaaConnected) {
        Float64 iaaTempo = audioEngine.iaaTempo;
        if (iaaTempo > 0) {
            tempo = iaaTempo;
            currentBeat = audioEngine.iaaCurrentBeat;
        }
        
    }
}

@end
