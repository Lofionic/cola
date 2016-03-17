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

#import "CCOLIAAController.h"

using namespace std;

class CCOLComponent;
class CCOLAudioContext;
class CCOLKeyboardComponent;
class CCOLTransportController;
class CCOLMIDIComponent;

class CCOLAudioEngine {

private:
    AUGraph                 mGraph;
    AudioUnit               mRemoteIO;
    
    CCOLAudioContext*       audioContext;
    double                  sampleRate;
    
    float                   attenuation;
    bool                    mute;
    
    bool                    isForeground;
    
    vector<CCOLComponent*>  components;
    
    // Vectors of deferred changes to render chain
    vector<CCOLComponentConnector*> pendingDisconnects;
    
    CCOLTransportController*    transportController;
    CCOLMIDIComponent*          midiComponent;
    
    void buildWaveTables();
    void startGraph();
    void stopGraph();
    
    void getHostCalbackInfo();
    
    // IAA Sync
    bool iaaConnected;
    
    HostCallbackInfo *callbackInfo;
    float hostBeat;
    float hostTempo;
        
public:
    CCOLAudioEngine();

    void initializeAUGraph(bool isForegroundIn);
    void startStop();
    
    void appDidEnterBackground();
    void appWillEnterForeground();
    void appWillTerminate();
    void mediaServicesWereReset();
    
    void doPending();
    
    AudioUnit *getRemoteIO() {
        return &mRemoteIO;
    }

    void iaaDidConnect() {
        iaaConnected = true;
        startStop();
    }
    
    void iaaDidDisconnect() {
        iaaConnected = false;
        startStop();
    }
    
    void updateHostBeatAndTempo();
    
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
    
    CCOLMIDIComponent* getMIDIComponent() {
        return midiComponent;
    }

};

#endif /* CCOLAudioEngine_hpp */
