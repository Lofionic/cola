//
//  COLAudioEngine.h
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>

#import "COLComponentInput.h"

@class COLAudioEngine;
@protocol COLAudioEngineDelegate <NSObject>

-(NSDictionary*)interAppInfoDictionaryForAudioEngine:(COLAudioEngine*)audioEngine;

@optional
-(void)audioEngineInterAppAudioConnected:(COLAudioEngine*)audioEngine;
-(void)audioEngineInterAppAudioDisconnected:(COLAudioEngine*)audioEngine;
-(void)audioEngineHostStateDidChange:(COLAudioEngine*)audioEngine;
@end

@interface COLAudioEngine : NSObject {
    AUGraph     mGraph;
    AudioUnit   mRemoteIO;
}

@property (nonatomic, weak) id<COLAudioEngineDelegate> delegate;
@property (readonly) Float64 sampleRate;
@property (readonly) BOOL isForeground;
@property (readonly) BOOL isInterAppConnected;

@property (readonly) COLComponentInput *masterInputL;
@property (readonly) COLComponentInput *masterInputR;

-(void)initializeAUGraph;
-(void)startStopEngine;


@end