//
//  COLAudioEnvironment.h
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CCOLTypes.h"

@protocol COLAudioEnvironmentInfoDelegate <NSObject>
-(NSDictionary*)interAppInfoDictionary;
@end

@class COLAudioEngine;
@protocol COLAudioEngineDelegate <NSObject>
@optional
-(NSDictionary*)interAppInfoDictionaryForAudioEngine:(COLAudioEngine*)audioEngine;
-(void)audioEngineInterAppAudioConnected:(COLAudioEngine*)audioEngine;
-(void)audioEngineInterAppAudioDisconnected:(COLAudioEngine*)audioEngine;
-(void)audioEngineHostStateDidChange:(COLAudioEngine*)audioEngine;
@end

@class COLKeyboardComponent;
@class COLTransportController;
@interface COLAudioEnvironment : NSObject <COLAudioEngineDelegate>

@property (nonatomic, weak) id      infoDelegate;
@property (readonly) COLAudioEngine *audioEngine;
@property (readonly) Float64        sampleRate;

@property (readonly, strong) COLKeyboardComponent       *keyboardComponent;
@property (readonly, strong) COLTransportController     *transportController;

+(instancetype)sharedEnvironment;
-(void)start;
-(BOOL)isInterAppAudioConnected;

-(void)mute;
-(void)unmute;

-(void)exportEnvironment;

// Component Management
-(CCOLComponentAddress)createCComponentOfType:(char*)componentType;
-(BOOL)connectOutput:(CCOLOutputAddress)outputAddress toInput:(CCOLInputAddress)inputAddress;

-(CCOLInputAddress)getMasterInputAtIndex:(UInt32)index;
-(CCOLOutputAddress)getOutputNamed:(char*)outputName onComponent:(CCOLComponentAddress)componentAddress;

@property (readonly) NSMutableArray *components;

@end