//
//  CCOLComponentVCA.cpp
//  ColaLib
//
//  Created by Chris on 15/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponentVCA.hpp"
#include <AudioToolbox/AudioToolbox.h>

using namespace std;

void CCOLComponentVCA::initializeIO() {
    
    input = new CCOLComponentInput(this, kIOTypeDynamic, (char*)"In");
    CVin = new CCOLComponentInput(this, kIOTypeControl, (char*)"CV In");
    setInputs(vector<CCOLComponentInput*> { input, CVin });
    
    output = new CCOLComponentOutput(this, kIOTypeDynamic, (char*)"Out");
    setOutputs(vector<CCOLComponentOutput*> { output });
    
    output->setLinkedInput(input);
    
    level = new CCOLComponentParameter(this, (char*)"Level");
    CVAmt = new CCOLComponentParameter(this, (char*)"CV Amt");
    setParameters(vector<CCOLComponentParameter*> { level, CVAmt });

    level->setNormalizedValue(0.5);
    CVAmt->setNormalizedValue(0);
}

void CCOLComponentVCA::renderOutputs(unsigned int numFrames) {
    CCOLComponent::renderOutputs(numFrames);
    
    SignalType *inputBuffer = input->getBuffer(numFrames);
    SignalType *outputBuffer = output->prepareBufferOfSize(numFrames);
    
    SignalType *cvBuffer = CVin->getBuffer(numFrames);
    
    for (int i = 0; i < numFrames; i++) {
        float delta = i / (float)numFrames;
        float amp = level->getOutputAtDelta(delta);
        if (CVin->isConnected()) {
            float cvAmount = CVAmt->getOutputAtDelta(delta);
            // Interpolate between level and CV
            SignalType cv = cvBuffer[i];
            amp = amp + ((cv - amp) * cvAmount);
        }

        if (output->getIOType() & kIOTypeControl) {
            // Normalize CV output ( 0 > 0.5 )
            if (input->isConnected()) {
                outputBuffer[i] = ((((inputBuffer[i] * 2.) - 1) * amp) + 1) / 2.0;
            } else {
                outputBuffer[i] = 0.5;
            }
        } else {
            outputBuffer[i] = inputBuffer[i] * amp;
        }
    }
}
