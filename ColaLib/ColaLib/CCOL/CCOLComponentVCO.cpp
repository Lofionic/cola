//
//  CCOLComponentVCO.cpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//
#include <math.h>
#include "CCOLComponentVCO.hpp"

void CCOLComponentVCO::renderOutputs(unsigned int numFrames) {
    
    SignalType *mainOutBuffer = mainOutput.prepareBufferOfSize(numFrames);
    
    const double cycleLength = 44100.00 / 880;
    for (int i = 0; i < numFrames; i++) {
        mainOutBuffer[i] = sinf(phase * 2);
        phase += 1.0 / cycleLength;
        if (phase > M_PI) {
            phase =- M_PI;
        }
    }

    
    CCOLComponent::renderOutputs(numFrames);
}

void CCOLComponentVCO::initializeIO() {
    
    std::vector<CCOLComponentInput*> theInputs = { };
    setInputs(theInputs);
    
    mainOutput.init(this, kIOTypeAudio, (char*)"Output");
    
    vector<CCOLComponentOutput*> theOutputs = {
        &mainOutput
    };
    
    setOutputs(theOutputs);
}

const char* CCOLComponentVCO::getDefaultName() {
    return "VCO";
}