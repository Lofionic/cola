//
//  CCOLComponentLFO.hpp
//  ColaLib
//
//  Created by Chris on 14/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentLFO_hpp
#define CCOLComponentLFO_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"
#include "CCOLTypes.h"

class CCOLComponentLFO : public CCOLComponent {

    double phase;
    
    CCOLComponentOutput *mainOut;
    CCOLComponentInput  *cvIn;
    
    CCOLComponentParameter *rate;
    CCOLComponentParameter *cvAmt;
    CCOLComponentParameter *waveform;
    
public:
    CCOLComponentLFO(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
        phase = 0;
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
};

#endif /* CCOLComponentLFO_hpp */
