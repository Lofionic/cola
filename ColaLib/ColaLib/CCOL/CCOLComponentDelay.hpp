//
//  CCOLComponentDelay.hpp
//  ColaLib
//
//  Created by Ed Rutter on 27/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentDelay_hpp
#define CCOLComponentDelay_hpp

#include <stdio.h>
#include "CCOLComponents.h"

class CCOLComponentDelay : public CCOLComponent {
    
    CCOLComponentInput *input;
    
    CCOLComponentOutput *output;
    
    CCOLComponentParameter *delayTime;
    CCOLComponentParameter *feedback;
    CCOLComponentParameter *mix;
    
    SignalType *delayBuffer;
    UInt32 bufferSize;
    UInt32 bufferLocation;

public:
    CCOLComponentDelay(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
        
    }

    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
};

#endif /* CCOLComponentDelay_hpp */
