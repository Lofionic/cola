//
//  CCOLComponentMixer.hpp
//  ColaLib
//
//  Created by Chris on 24/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentMixer_hpp
#define CCOLComponentMixer_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"

class CCOLComponentMixer : public CCOLComponent {
    
    CCOLComponentInput *input1;
    CCOLComponentInput *input2;
    
    CCOLComponentOutput *output;
    
    CCOLComponentParameter *level1;
    CCOLComponentParameter *level2;
    
    const char* getComponentType() override { return kCCOLComponentTypeMixer; }
    
public:
    CCOLComponentMixer(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
        
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
};

#endif /* CCOLComponentMixer_hpp */
