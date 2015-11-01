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
    
    double                  phase = 0;
    
    CCOLComponentInput*     keyboardIn;
    CCOLComponentInput*     fmodIn;
    
    CCOLComponentOutput*    mainOutput;
    
    CCOLDiscreteParameter*      range;
    CCOLDiscreteParameter*      waveform;
    CCOLContinuousParameter*    tune;
    CCOLContinuousParameter*    fmAmt;
    
    CCOLDiscreteParameterIndex  waveformIndex;
    
    SignalType              previousResult = 0;
    
public:
    CCOLComponentVCO(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {

    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
    const char*     getDefaultName() override;
};

#endif /* CCOLComponentVCO_hpp */
