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

#include <vector>
#include <AudioToolbox/AudioToolbox.h>

using namespace std;

class CCOLComponent;
class CCOLComponentInput;
class CCOLComponentOutput;
class CCOLAudioEngine {

private:
    AUGraph                 mGraph;
    AudioUnit               mRemoteIO;
    
    CCOLComponentInput      *masterL;
    CCOLComponentInput      *masterR;
    double                  sampleRate;
    float                   attenuation = 0.5;
    
    vector<CCOLComponent*>  components;
    
    void buildWaveTables();

public:
    void init();
    void initializeAUGraph();
    
    CCOLComponentInput *getMasterL() {
        return masterL;
    }
    
    CCOLComponentInput *getMasterR() {
        return masterR;
    }
    
    // Component Management
    CCOLComponentAddress createComponent(char* componentType);
    CCOLOutputAddress getOutput(CCOLComponentAddress componentAddress, char* outputName);
    CCOLParameterAddress getParameter(CCOLComponentAddress componentAddress, char* parameterName);
    bool connect(CCOLOutputAddress outputAddress, CCOLInputAddress inputAddress);
    bool disconnect(CCOLInputAddress inputAddress);
    
    CCOLInputAddress getMasterInput(unsigned int index);
    kIOType getIOType(CCOLConnectorAddress connector);
    
    float getAttentuation() {
        return attenuation;
    }
};

#endif /* CCOLAudioEngine_hpp */
