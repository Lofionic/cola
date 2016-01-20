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
    
    CCOLComponentOutput *outputGreatThanMod;
    CCOLComponentOutput *outputModIsPos;
    CCOLComponentOutput *outputModBufferDelay;
    CCOLComponentOutput *outputModBufferDelay2;
    CCOLComponentOutput *outputModBufferDelay3;
    
    CCOLComponentInput  *input1;
    CCOLComponentInput  *input2;
  
public:
    CCOLComponentLogic(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
    
};

#endif /* CCOLComponentLogic_hpp */
