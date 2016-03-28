//
//  CCOLComponentReverb.hpp
//  ColaLib
//
//  Created by Ed Rutter on 17/02/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentReverb_hpp
#define CCOLComponentReverb_hpp

#include <stdio.h>
#include "CCOLComponents.h"

class CCOLComponentReverb : public CCOLComponent {
    
    CCOLComponentInput *input;
    
    CCOLComponentOutput *output;
    
    CCOLComponentParameter *delayTime;
    CCOLComponentParameter *feedback;
    CCOLComponentParameter *mix;
    
    SignalType *delayBuffer;
    UInt32 bufferSize;
    UInt32 bufferLocation;
    UInt32 bufferLocation1;
    UInt32 bufferLocation2;
    UInt32 bufferLocation3;
    
    const char* getComponentType() override { return kCCOLComponentTypeReverb; }
    
public:
    CCOLComponentReverb(CCOLAudioContext * contextIn):CCOLComponent(contextIn) {
        
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
};

#endif /* CCOLComponentReverb_hpp */
