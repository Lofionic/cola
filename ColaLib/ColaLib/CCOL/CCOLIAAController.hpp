//
//  CCOLIAAController.hpp
//  ColaLib
//
//  Created by Chris on 17/03/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#ifndef CCOLIAAController_hpp
#define CCOLIAAController_hpp

#include <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>
#include <UIKit/UIKit.h>    // For UIImage (Host image)

// This class will publish a RemoteIO for Inter-App Audio, and post notifications for changes in IAA connected and IAA transport state. 

const CFStringRef kCCOLIAAControllerTransportStateDidChange = CFSTR("kCCOLIAAControllerTransportStateDidChange");
const CFStringRef kCCOLIAAControllerConnectedStateDidChange = CFSTR("kCCOLIAAControllerConnectedStateDidChange");

class CCOLAudioEngine;
class CCOLIAAController {

private:
    AudioUnit *remoteIO;
    
    BOOL hostConnected;
    BOOL hostPlaying;
    BOOL hostRecording;
    
    float   hostPlayTime;
    float   hostBeat;
    float   hostTempo;
    
    UIImage *hostImage;
    
    HostCallbackInfo *callbackInfo;
    void getHostCalbackInfo();

    void sendStateToRemoteHost(AudioUnitRemoteControlEvent state);
    
public:
    CCOLIAAController();
    
    void publishIAA(AudioUnit *remoteIO, CFStringRef componentNameIn, OSType manufacturerCodeIn);

    void updateHostBeatAndTempo(); // Called by engine to update beat & tempo information.
    
    void interAppAudioConnectedDidChange();
    void interAppAudioHostTransportStateDidChange(); // These need to be public, since they are called by the property listener despatcher.
    
    void goToHost();
    void hostTogglePlay();
    void hostToggleRecord();
    void hostRewind();
    
    BOOL isHostConnected() { return hostConnected; }
    BOOL isHostPlaying() { return hostPlaying; }
    BOOL isHostRecording() { return hostRecording; }
    
    float getHostPlayTime() { return hostPlayTime; }
    float getHostBeat() { return hostBeat; }
    float getHostTempo() { return hostTempo; }
    
    UIImage *getHostImage() { return hostImage; }
    
};

#endif /* CCOLIAAController_hpp */
