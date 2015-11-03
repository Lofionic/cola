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
-(CCOLComponentAddress)createComponentOfType:(char*)componentType;
-(void)removeComponent:(CCOLComponentAddress)componentAddress;
-(BOOL)connectOutput:(CCOLOutputAddress)outputAddress toInput:(CCOLInputAddress)inputAddress;
-(BOOL)disconnectInput:(CCOLInputAddress)inputAddress;
-(NSString*)getConnectorName:(CCOLConnectorAddress)connectorAddress;

-(CCOLInputAddress)getMasterInputAtIndex:(UInt32)index;
-(CCOLOutputAddress)getOutputNamed:(NSString*)outputName onComponent:(CCOLComponentAddress)componentAddress;
-(CCOLInputAddress)getInputNamed:(NSString*)outputName onComponent:(CCOLComponentAddress)componentAddress;
-(CCOLParameterAddress)getParameterNamed:(NSString*)parameterName onComponent:(CCOLComponentAddress)componentAddress;
-(kIOType)getConnectorType:(CCOLConnectorAddress)connectorAddress;

// Get set parameters
-(NSString*)getParameterName:(CCOLParameterAddress)parameterAddress;
-(double)getParameterValue:(CCOLParameterAddress)parameterAddress;
-(void)setParameter:(CCOLParameterAddress)parameterAddress value:(double)value;

@property (readonly) NSMutableArray *components;

@end