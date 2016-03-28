//
//  CCOLComponentVCO.hpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentVCO_hpp
#define CCOLComponentVCO_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"
#include "CCOLTypes.h"

class CCOLComponentInput;
class CCOLComponentOutput;
class CCOLDiscreteParameter;
class CCOLContinuousParameter;
class CCOLComponentVCO : public CCOLComponent {
    
    double                  phase;
    
    CCOLComponentInput*     keyboardIn;
    CCOLComponentInput*     fmodIn;
    
    CCOLComponentOutput*    mainOutput;
    
    CCOLComponentParameter* range;
    CCOLComponentParameter* waveform;
    CCOLComponentParameter* tune;
    CCOLComponentParameter* fmAmt;
    
    CCOLDiscreteParameterIndex  waveformIndex;
    
    SignalType              previousResult;
    
    float remainder, delta, tuneIn, freqIn, lfoValue;
    const char* getComponentType() override { return kCCOLComponentTypeVCO; }
    
    
public:
    CCOLComponentVCO(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
        phase = 0;
        previousResult = 0;
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
};

#endif /* CCOLComponentVCO_hpp */
