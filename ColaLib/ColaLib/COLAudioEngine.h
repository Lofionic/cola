//
//  COLAudioEngine.h
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#ifndef COLAudioEngine_h
#define COLAudioEngine_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "COLAudioEnvironment.h"

@class ABAudiobusController;
@class COLAudioEngine;
@class COLComponentInput;

@interface COLAudioEngine : NSObject {
    AUGraph     mGraph;
    AudioUnit   mRemoteIO;
}

@property (nonatomic, weak) id<COLAudioEngineDelegate>  delegate;

@property (readonly) BOOL isForeground;
@property (readonly) BOOL iaaConnected;
@property (readonly) BOOL isHostPlaying;
@property (readonly) BOOL isHostRecording;
@property (readonly) Float64 playTime;
@property (readonly) Float64 iaaTempo;
@property (readonly) Float64 iaaCurrentBeat;

@property (readonly, weak) COLComponentInput *masterInputL;
@property (readonly, weak) COLComponentInput *masterInputR;

@property (readonly) BOOL isMuting;
@property (readonly) Float32 attenuation;

@property (readonly, strong) UIImage *iaaHostImage;

-(void)initializeAUGraph;
-(void)startStopEngine;

-(void)mute;
-(void)unmute;

-(void)iaaGotoHost;
-(void)iaaToggleRecord;
-(void)iaaTogglePlay;
-(void)iaaRewind;

@end

#endif