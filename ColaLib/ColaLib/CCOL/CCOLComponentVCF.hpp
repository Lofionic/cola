//
//  CCOLComponentVCF.hpp
//  ColaLib
//
//  Created by Ed Rutter on 02/12/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentVCF_hpp
#define CCOLComponentVCF_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"
#include "CCOLTypes.h"

class CCOLComponentInput;
class CCOLComponentOutput;
class CCOLContinuousParameter;

class CCOLComponentVCF : public CCOLComponent {
    
    CCOLComponentInput*         audioInput;
    CCOLComponentInput*         cvFreq;
    CCOLComponentInput*         cvRes;
    
    CCOLComponentOutput*        audioOutput;
    
    CCOLComponentOutput*        lpOut;
    CCOLComponentOutput*        hpOut;
    CCOLComponentOutput*        bpOut;
    CCOLComponentOutput*        notchOut;
    
    CCOLComponentParameter*     paramCutoffFreq;
    CCOLComponentParameter*     paramRes;
    CCOLComponentParameter*     paramCvFreqAmount;
    CCOLComponentParameter*     paramCvResAmount;
    
    float f, p, q;             //filter coefficients
    float b0, b1, b2, b3, b4;  //filter buffers (beware denormals!)
    float t1, t2;
    
public:
    CCOLComponentVCF(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
        
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
};


#endif /* CCOLComponentVCF_hpp */
