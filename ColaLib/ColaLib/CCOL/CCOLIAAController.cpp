//
//  CCOLIAAController.cpp
//  ColaLib
//
//  Created by Chris on 17/03/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#include "CCOLIAAController.hpp"
#include "CCOLUtility.hpp"

// Called by prpoerty & transport state listeners.
void audioUnitPropertyListenerDispatcher(void *inRefCon, AudioUnit inUnit, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement) {
    
    printf("CCOLAudioEngine: AudioUnitPropertyListenerDispatcher");
    CCOLIAAController *SELF = (CCOLIAAController*)inRefCon;

    if (inID == kAudioUnitProperty_IsInterAppConnected) {
        SELF->interAppAudioConnectedDidChange();
    } else if (inID == kAudioOutputUnitProperty_HostTransportState) {
        SELF->interAppAudioHostTransportStateDidChange();
    }
}

CCOLIAAController::CCOLIAAController() {
    
    hostConnected   = false;
    hostPlaying     = false;
    hostRecording   = false;
    
    hostPlaying     = 0;
    hostBeat        = 0;
    hostTempo       = 0;
    
    hostImage = nil;
    callbackInfo = NULL;
    
}

void CCOLIAAController::publishIAA(AudioUnit *remoteIOIn, CFStringRef componentNameIn, OSType manufacturerCodeIn) {
    
    remoteIO = remoteIOIn;

    printf("CCOLAudioEngine: Publishing IAA...\n");
    hostConnected = false;
    
    // Add property & transport state listeners to the remoteIO.
    checkError(AudioUnitAddPropertyListener(*remoteIO, kAudioUnitProperty_IsInterAppConnected, audioUnitPropertyListenerDispatcher, this), "Error setting IAA connected property listener");
    checkError(AudioUnitAddPropertyListener(*remoteIO, kAudioOutputUnitProperty_HostTransportState, audioUnitPropertyListenerDispatcher, this), "Error setting IAA host transport state listener");
    
    // Publish the inter-app audio component
    AudioComponentDescription audioComponentDescription = {
        kAudioUnitType_RemoteInstrument,
        'iasp',
        manufacturerCodeIn,
        0,
        1
    };
    
    checkError(AudioOutputUnitPublish(&audioComponentDescription, componentNameIn, 0, *remoteIO), "Cannot publish IAA component");
}

// Called by the property listener despatcher when connected state has changed.
void CCOLIAAController::interAppAudioConnectedDidChange() {
    UInt32 connected;
    UInt32 dataSize = sizeof(UInt32);
    checkError(AudioUnitGetProperty(*remoteIO, kAudioUnitProperty_IsInterAppConnected, kAudioUnitScope_Global, 0, &connected, &dataSize), "Error getting IsInterAppConnected property");
    if (connected != hostConnected) {
        hostConnected = connected;
        if (hostConnected) {
            printf("CCOLAudioEngine: IAA has connected.\n");
            // Request the host image.
            hostImage = AudioOutputUnitGetHostIcon(*remoteIO, 114);
        } else {
            printf("CCOLAudioEngine: IAA has disconnected.\n");
        }
        
        // Notify interested parties that IAA Connected state has changed.
        CFNotificationCenterPostNotification(CFNotificationCenterGetLocalCenter(), kCCOLIAAControllerConnectedStateDidChange, (void*)this, NULL, true);
    }
}

// Called by the property listener despatched when the IAA transport state has changed.
void CCOLIAAController::interAppAudioHostTransportStateDidChange() {
    // Update transport state flags
    if (hostConnected) {
        if (callbackInfo == NULL) {
            getHostCalbackInfo();
        }
        if (callbackInfo != NULL) {
            Boolean isPlaying =     hostPlaying;
            Boolean isRecording =   hostRecording;
            Float64 outCurrentSampleInTimeline = 0;
            void * hostUserData = callbackInfo->hostUserData;
            
            // Get transport state
            OSStatus result =  callbackInfo->transportStateProc2(hostUserData,
                                                                 &isPlaying,
                                                                 &isRecording,
                                                                 NULL,
                                                                 &outCurrentSampleInTimeline,
                                                                 NULL,
                                                                 NULL,
                                                                 NULL);
            if (result == noErr) {
                hostPlaying = isPlaying;
                hostRecording = isRecording;
                hostPlayTime = outCurrentSampleInTimeline;
                
                // Notify interested parties that transport state has changed.
                CFNotificationCenterPostNotification(CFNotificationCenterGetLocalCenter(), kCCOLIAAControllerTransportStateDidChange, (void*)this, NULL, true);
            } else {
                printf("CCOLAudioEngine: Error occured fetching callBackInfo->transportStateProc2 : %d", (int)result);
            }
        }
    }
}

// Get the current beat & tempo from iaa host.
void CCOLIAAController::updateHostBeatAndTempo() {
    if (hostConnected) {
        if (callbackInfo == NULL) {
            getHostCalbackInfo();
        }
        if (callbackInfo != NULL) {
            Float64 outCurrentBeat;
            Float64 outTempo;
            
            void * hostUserData = callbackInfo->hostUserData;
            OSStatus result = callbackInfo->beatAndTempoProc(hostUserData,
                                                             &outCurrentBeat,
                                                             &outTempo);
            
            if (result == noErr) {
                hostBeat = outCurrentBeat;
                hostTempo = outTempo;
            } else  {
                printf("Error occured fetching callbackInfo->beatAndTempProc : %d", (int)result);
            }
        }
    }
}

// Populate callbackInfo.
void CCOLIAAController::getHostCalbackInfo() {
    if (hostConnected) {
        if (callbackInfo != NULL) {
            free(callbackInfo);
        }
        UInt32 dataSize = sizeof(HostCallbackInfo);
        callbackInfo = (HostCallbackInfo*) malloc(dataSize);
        OSStatus result = AudioUnitGetProperty(*remoteIO, kAudioUnitProperty_HostCallbacks, kAudioUnitScope_Global, 0, callbackInfo, &dataSize);
        if (result != noErr) {
            printf("CCOLAudioEngine: Error occured fetching kAudioUnitProperty_HostCallbacks : %d", (int)result);
            free(callbackInfo);
            callbackInfo = NULL;
        }
    }
}

// IAA Interface
void CCOLIAAController::goToHost() {
    if (remoteIO != NULL) {
        CFURLRef instrumentUrl;
        UInt32 dataSize = sizeof(instrumentUrl);
        OSStatus result = AudioUnitGetProperty(*remoteIO, kAudioUnitProperty_PeerURL, kAudioUnitScope_Global, 0, &instrumentUrl, &dataSize);
        if (result == noErr) {
            [[UIApplication sharedApplication] openURL:(__bridge NSURL*)instrumentUrl];
        }
    }
}

void CCOLIAAController::hostTogglePlay() {
    sendStateToRemoteHost(kAudioUnitRemoteControlEvent_TogglePlayPause);
}

void CCOLIAAController::hostToggleRecord() {
    sendStateToRemoteHost(kAudioUnitRemoteControlEvent_ToggleRecord);
}

void CCOLIAAController::hostRewind() {
    sendStateToRemoteHost(kAudioUnitRemoteControlEvent_Rewind);
}

void CCOLIAAController::sendStateToRemoteHost(AudioUnitRemoteControlEvent state) {
    // Send a remote control message back to host
    if (remoteIO != NULL) {
        UInt32 controlEvent = state;
        UInt32 dataSize = sizeof(controlEvent);
        checkError(AudioUnitSetProperty(*remoteIO, kAudioOutputUnitProperty_RemoteControlToHost, kAudioUnitScope_Global, 0, &controlEvent, dataSize), "Failed sendStateToRemoteHost");
    }
}


