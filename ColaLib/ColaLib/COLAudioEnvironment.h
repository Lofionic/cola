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

@class COLKeyboardComponent;
@class COLTransportController;
@interface COLAudioEnvironment : NSObject

@property (nonatomic, weak) id      infoDelegate;
@property (readonly) BOOL           iaaConnected;

@property (readonly, strong) COLTransportController     *transportController;

+(instancetype)sharedEnvironment;
-(void)start;
-(BOOL)isInterAppAudioConnected;

-(void)mute;
-(void)unmute;
-(BOOL)isMute;

-(void)exportEnvironment;

// Component Management
-(CCOLComponentAddress)createComponentOfType:(char*)componentType;
-(void)removeComponent:(CCOLComponentAddress)componentAddress;
-(BOOL)connectOutput:(CCOLOutputAddress)outputAddress toInput:(CCOLInputAddress)inputAddress;
-(BOOL)disconnect:(CCOLConnectorAddress)connectorAddress;
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

// MIDI
-(CCOLComponentAddress)getMIDIComponent;
-(void)noteOn:(NoteIndex)noteIndex;
-(void)noteOff:(NoteIndex)noteIndex;
-(void)allNotesOff;

// Transport
-(BOOL)isTransportPlaying;
-(void)transportPlay;
-(void)transportStop;

@property (readonly) NSMutableArray *components;

@end