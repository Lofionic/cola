//
//  CCOLComponentRingMod.hpp
//  ColaLib
//
//  Created by Ed Rutter on 14/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentRingMod_hpp
#define CCOLComponentRingMod_hpp

#include <stdio.h>
#include "CCOLComponents.h"

class CCOLComponentRingMod : public CCOLComponent {

    CCOLComponentInput *input1;
    CCOLComponentInput *input2;
    
    CCOLComponentOutput *output;
    
    CCOLComponentParameter *mix;

public:
    CCOLComponentRingMod(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
    
    const char* getComponentType() override { return kCCOLComponentTypeRingMod; }
};
#endif /* CCOLComponentRingMod_hpp */
