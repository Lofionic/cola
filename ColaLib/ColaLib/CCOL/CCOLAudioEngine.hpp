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
class CCOLAudioEngine {

private:
    AUGraph                 mGraph;
    AudioUnit               mRemoteIO;
    
    CCOLAudioContext*       audioContext;
    double                  sampleRate;
    
    float                   attenuation;
    bool                    mute;
    
    vector<CCOLComponent*>  components;
    
    void buildWaveTables();

public:
    CCOLAudioEngine();

    void initializeAUGraph(double sampleRateIn);
    
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
};

#endif /* CCOLAudioEngine_hpp */