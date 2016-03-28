//
//  CCOLComponentMixer4.hpp
//  ColaLib
//
//  Created by Ed on 13/1/2016.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentMixer4_hpp
#define CCOLComponentMixer4_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"

class CCOLComponentMixer4 : public CCOLComponent {
    
    CCOLComponentInput *input1;
    CCOLComponentInput *input2;
    CCOLComponentInput *input3;
    CCOLComponentInput *input4;
    
    CCOLComponentOutput *output;
    
    CCOLComponentParameter *level1;
    CCOLComponentParameter *level2;
    CCOLComponentParameter *level3;
    CCOLComponentParameter *level4;
    
    const char* getComponentType() override { return kCCOLComponentTypeMixer4; }
    
public:
    CCOLComponentMixer4(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
        
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
};

#endif /* CCOLComponentMixer_hpp */
