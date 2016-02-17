//
//  CCOLAudioEngine.hpp
//  ColaLib
//
//  Created by Chris on 30/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLAudioEngine_hpp
#define CCOLAudioEngine_hpp

#include "CCOLDefines.h"
#include "CCOLAudioContext.hpp"

#include <vector>
#include <AudioToolbox/AudioToolbox.h>

using namespace std;

class CCOLComponent;
class CCOLAudioContext;
class CCOLKeyboardComponent;
class CCOLTransportController;

class CCOLAudioEngine {

private:
    AUGraph                 mGraph;
    AudioUnit               mRemoteIO;
    
    CCOLAudioContext*       audioContext;
    double                  sampleRate;
    
    float                   attenuation;
    bool                    mute;
    
    bool                    isForeground;
    
    bool        iaaHostConnected;
    bool        iaaHostPlaying;
    bool        iaaHostRecording;
    Float64     iaaHostPlayTime;
    Float64     iaaHostTempo;
    Float64     iaaHostBeat;
    UIImage     *iaaHostImage;
    
    HostCallbackInfo *callbackInfo;
    
    vector<CCOLComponent*>  components;
    
    // Vectors of deferred changes to render chain
    vector<CCOLComponentConnector*> pendingDisconnects;
    
    CCOLTransportController*    transportController;
    
    void buildWaveTables();
    void startGraph();
    void stopGraph();
    void updateTransportStateFromHostCallback();

    void getHostCalbackInfo();
    
public:
    CCOLAudioEngine();

    void initializeAUGraph(bool isForegroundIn);
    void initializeIAA(CFStringRef componentName, OSType componentManufacturer);
    void updateHostBeatAndTempo();
    void startStop();
    
    bool isIAAHostConnected() { return iaaHostConnected; }
    Float64 getIAATempo() { return iaaHostTempo; }
    Float64 getIAABeat() { return iaaHostBeat; }
    
    void interAppAudioConnectedDidChange();
    void interAppAudioHostTransportStateDidChange();
    
    void appDidEnterBackground();
    void appWillEnterForeground();
    void appWillTerminate();
    void mediaServicesWereReset();
    
    void doPending();
    
    AudioUnit *getRemoteIO() {
        return &mRemoteIO;
    }
    
    // Component Management
    CCOLComponentAddress createComponent(char* componentType);
    void removeComponent(CCOLComponentAddress component);
    
    // Connections
    CCOLOutputAddress getOutput(CCOLComponentAddress componentAddress, char* outputName);
    CCOLInputAddress getInput(CCOLComponentAddress componentAddress, char* inputName);
    bool connect(CCOLOutputAddress outputAddress, CCOLInputAddress inputAddress);
    bool disconnect(CCOLInputAddress inputAddress);
    kIOType getIOType(CCOLConnectorAddress connector);
    
    // Parameters
    CCOLParameterAddress getParameter(CCOLComponentAddress componentAddress, char* parameterName);
    CCOLInputAddress getMasterInput(unsigned int index);
    
    // Transpot
    float getTransportLocation();
    
    size_t getComponentCount() {
        return components.size();
    }
    
    CCOLComponent* getComponent(size_t index) {
        return components.at(index);
    }
    
    double getSampleRate() {
        return sampleRate;
    }
    
    float getAttenuation() {
        return attenuation;
    }
    
    void setAttenuation(float value) {
        attenuation = value;
    }
    
    bool isMute() {
        return mute;
    }
    
    void setMute(bool value) {
        mute = value;
    }
    
    // Transport
    CCOLTransportController* getTransportController() {
        return transportController;
    }
};

#endif /* CCOLAudioEngine_hpp */
