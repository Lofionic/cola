//
//  CCOLComponentLogic.hpp
//  ColaLib
//
//  Created by Ed Rutter on 20/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentLogic_hpp
#define CCOLComponentLogic_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"
#include "CCOLTypes.h"

class CCOLComponentLogic : public CCOLComponent {

    CCOLComponentInput  *carrier;
    CCOLComponentInput  *modulator;
    
    CCOLComponentOutput *outputGreatThanMod;
    CCOLComponentOutput *outputModIsPos;
    CCOLComponentOutput *outputSamePolarity;
    
    CCOLComponentOutput *outputRectified;
    CCOLComponentOutput *outputRectifiedAbsoluteMod;
    CCOLComponentOutput *outputRectifiedMod;
    
    CCOLComponentOutput *outputModOffset;
    CCOLComponentOutput *outputModOffset2;
    CCOLComponentOutput *outputModOffset3;

    CCOLComponentParameter *modOffsetAmount;
    
    SignalType *offsetBuffer;
    UInt32 bufferSize;
    UInt32 bufferLocation;
    
public:
    CCOLComponentLogic(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
    
};

#endif /* CCOLComponentLogic_hpp */
