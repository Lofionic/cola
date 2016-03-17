//
//  COLIAAController.m
//  ColaLib
//
//  Created by Chris Rivers on 16/03/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//
#include <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>

#import "COLDefines.h"
#import "CCOLIAAController.h"
#import "CCOLMidiComponent.hpp"
#import "CCOLTransportController.hpp"

@interface CCOLIAAController()

@property (nonatomic) BOOL              isHostConnected;
@property (nonatomic) BOOL              isHostPlaying;
@property (nonatomic) BOOL              isHostRecording;

@property (nonatomic) float             hostPlayTime;
@property (nonatomic) float             hostBeat;
@property (nonatomic) float             hostTempo;

@property (nonatomic, strong) UIImage   *hostImage;
@property (nonatomic) HostCallbackInfo  *callbackInfo;

@property (nonatomic) CCOLAudioEngine *engine;

@end

@implementation CCOLIAAController


-(void)initializeIAAwithComponentName:(CFStringRef)componentName manufactureCode:(OSType)componentManufacturer engine:(CCOLAudioEngine*)engine {
    
    self.engine = engine;
    
    printf("CCOLAudioEngine: Registering IAA...\n");
    self.isHostConnected = false;
    
    // Add property listener for inter-app audio
    checkError(AudioUnitAddPropertyListener(*engine->getRemoteIO(), kAudioUnitProperty_IsInterAppConnected, audioUnitPropertyListenerDispatcher, (__bridge void*)self), "Error setting IAA connected property listener");
    checkError(AudioUnitAddPropertyListener(*engine->getRemoteIO(), kAudioOutputUnitProperty_HostTransportState, audioUnitPropertyListenerDispatcher, (__bridge void*)self), "Error setting IAA host transport state listener");
    
    // Publish the inter-app audio component
    AudioComponentDescription audioComponentDescription = {
        kAudioUnitType_RemoteInstrument,
        'iasp',
        componentManufacturer,
        0,
        1
    };
    
    checkError(AudioOutputUnitPublish(&audioComponentDescription, componentName, 0, *engine->getRemoteIO()), "Cannot publish IAA component");
    
    [self setupMidiCallbacks];
}


void audioUnitPropertyListenerDispatcher(void *inRefCon, AudioUnit inUnit, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement) {
    printf("CCOLAudioEngine: AudioUnitPropertyListenerDispatcher");
    CCOLIAAController *SELF = (__bridge CCOLIAAController*)inRefCon;
    //[SELF audioUnitPropertyChanged:inRefCon unit:inUnit propID:inID scope:inScope element:inElement];
    
    if (inID == kAudioUnitProperty_IsInterAppConnected) {
        [SELF interAppAudioConnectedDidChange];
    } else if (inID == kAudioOutputUnitProperty_HostTransportState) {
        [SELF interAppAudioHostTransportStateDidChange];
    }
}

-(void)interAppAudioConnectedDidChange {
    UInt32 connected;
    UInt32 dataSize = sizeof(UInt32);
    checkError(AudioUnitGetProperty(*self.engine->getRemoteIO(), kAudioUnitProperty_IsInterAppConnected, kAudioUnitScope_Global, 0, &connected, &dataSize), "Error getting IsInterAppConnected property");
    if (connected != self.isHostConnected) {
        self.isHostConnected = connected;
        if (self.isHostConnected) {
            printf("CCOLAudioEngine: IAA has connected.\n");
            self.hostImage = AudioOutputUnitGetHostIcon(*self.engine->getRemoteIO(), 114);
            self.engine->iaaDidConnect();
        } else {
            printf("CCOLAudioEngine: IAA has disconnected.\n");
            self.engine->iaaDidDisconnect();
        }
    }
}

-(void)interAppAudioHostTransportStateDidChange {
    [self updateTransportStateFromHostCallback];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCOLEventIAATransportStateDidChange object:nil];
}

-(void)updateTransportStateFromHostCallback {
    if (self.isHostConnected) {
        if (!self.callbackInfo) {
            [self getHostCalbackInfo];
        }
        if (self.callbackInfo != nil) {
            Boolean isPlaying =     self.isHostPlaying;
            Boolean isRecording =   self.isHostRecording;
            Float64 outCurrentSampleInTimeline = 0;
            void * hostUserData = self.callbackInfo->hostUserData;
            
            // Get transport state
            OSStatus result =  self.callbackInfo->transportStateProc2(hostUserData,
                                                                      &isPlaying,
                                                                      &isRecording, NULL,
                                                                      &outCurrentSampleInTimeline,
                                                                      NULL, NULL, NULL);
            if (result == noErr) {
                self.isHostPlaying = isPlaying;
                self.isHostRecording = isRecording;
                self.hostPlayTime = outCurrentSampleInTimeline;
            } else {
                printf("CCOLAudioEngine: Error occured fetching callBackInfo->transportStateProc2 : %d", (int)result);
            }
            
            self.engine->getTransportController()->interappAudioTransportStateDidChange(self.isHostPlaying);
        }
    }
}


-(void)getHostCalbackInfo {
    if (self.isHostConnected) {
        if (self.callbackInfo) {
            free(self.callbackInfo);
        }
        UInt32 dataSize = sizeof(HostCallbackInfo);
        self.callbackInfo = (HostCallbackInfo*) malloc(dataSize);
        OSStatus result = AudioUnitGetProperty(*self.engine->getRemoteIO(), kAudioUnitProperty_HostCallbacks, kAudioUnitScope_Global, 0, self.callbackInfo, &dataSize);
        if (result != noErr) {
            printf("CCOLAudioEngine: Error occured fetching kAudioUnitProperty_HostCallbacks : %d", (int)result);
            free(self.callbackInfo);
            self.callbackInfo = nil;
        }
    }
}

-(void)setupMidiCallbacks {
    AudioOutputUnitMIDICallbacks callBackStruct;
    callBackStruct.userData = (void*)self.engine;
    callBackStruct.MIDIEventProc = MIDIEventProcCallBack;
    callBackStruct.MIDISysExProc = NULL;
    checkError(AudioUnitSetProperty (*self.engine->getRemoteIO(),
                                     kAudioOutputUnitProperty_MIDICallbacks,
                                     kAudioUnitScope_Global,
                                     0,
                                     &callBackStruct,
                                     sizeof(callBackStruct)), "Can't setup Inter App MIDI Callback");
}


// IAA MIDI Event Callback
void MIDIEventProcCallBack(void *userData, UInt32 inStatus, UInt32 inData1, UInt32 inData2, UInt32 inOffsetSampleFrame){
    CCOLAudioEngine *engine = (CCOLAudioEngine*)userData;
    printf("%u",(unsigned int)inOffsetSampleFrame);
    Byte midiCommand = inStatus >> 4;
    Byte data1 = inData1 & 0x7F;
    Byte data2 = inData2 & 0x7F;
    
    if (midiCommand == 0x09) {
        engine->getMIDIComponent()->noteOn(inData1);
    } else if (midiCommand == 0x08) {
        engine->getMIDIComponent()->noteOff(data1);
    } else if (midiCommand == 0x0E) {
        // TODO: Handle IAA MIDI pitchbends.
        //        int value = ((data2 << 7)) + data1;
        
        //        engine->getMIDIComponent()->setPitchbend(value / 16383.0);
        
    }
}

#pragma mark IAA Controls
-(void)gotoHost {
    if (self.engine->getRemoteIO()) {
        CFURLRef instrumentUrl;
        UInt32 dataSize = sizeof(instrumentUrl);
        OSStatus result = AudioUnitGetProperty(*self.engine->getRemoteIO(), kAudioUnitProperty_PeerURL, kAudioUnitScope_Global, 0, &instrumentUrl, &dataSize);
        if (result == noErr) {
            [[UIApplication sharedApplication] openURL:(__bridge NSURL*)instrumentUrl];
        }
    }
}

-(void)playStop {
    [self sendStateToRemoteHost:kAudioUnitRemoteControlEvent_TogglePlayPause];
}

-(void)sendStateToRemoteHost:(AudioUnitRemoteControlEvent)state {
    // Send a remote control message back to host
    if (self.engine->getRemoteIO()) {
        UInt32 controlEvent = state;
        UInt32 dataSize = sizeof(controlEvent);
        checkError(AudioUnitSetProperty(*self.engine->getRemoteIO(), kAudioOutputUnitProperty_RemoteControlToHost, kAudioUnitScope_Global, 0, &controlEvent, dataSize), "Failed sendStateToRemoteHost");
    }
}

-(void)togglePlay {
    [self sendStateToRemoteHost:kAudioUnitRemoteControlEvent_TogglePlayPause];
}

-(void)toggleRecord {
    [self sendStateToRemoteHost:kAudioUnitRemoteControlEvent_ToggleRecord];
}

-(void)rewind {
    [self sendStateToRemoteHost:kAudioUnitRemoteControlEvent_Rewind];
}

// Utility
void checkError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    
    char errorString[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(errorString, "%d", (int)error);
    
    fprintf(stderr, "CCOLAudioEngine: Error: %s (%s)\n", operation, errorString);
    
    exit(1);
}

@end
