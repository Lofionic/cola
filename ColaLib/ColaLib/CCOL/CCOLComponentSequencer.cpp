//
//  CCOLComponentSequencer.cpp
//  ColaLib
//
//  Created by Chris Rivers on 01/12/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//
#include <string>
#include "CCOLComponentSequencer.hpp"
#include "CCOLTransportController.hpp"

void CCOLComponentSequencer::initializeIO() {
    
    vector<CCOLComponentParameter*> theParameters;
    for (int i = 0; i < 16; ++i) {
        string* inputName = new string("Pitch " + std::to_string(i + 1));
        stepPitch[i] = new CCOLComponentParameter(this, (char*)inputName->c_str());
        theParameters.push_back(stepPitch[i]);
        
        inputName = new string("Gate " + std::to_string(i + 1));
        stepGate[i] = new CCOLComponentParameter(this, (char*)inputName->c_str());
        theParameters.push_back(stepGate[i]);
    }
    setParameters(theParameters);
    
    pitchOut = new CCOLComponentOutput(this, kIOType1VOct, (char*)"Pitch Out");
    gateOut = new CCOLComponentOutput(this, kIOTypeGate, (char*)"Gate Out");
    setOutputs(vector<CCOLComponentOutput*> { pitchOut, gateOut });
    
    transportController = getContext()->getEngine()->getTransportController();
}

void CCOLComponentSequencer::renderOutputs(unsigned int numFrames) {
    
    SignalType *pitchOutputBuffer = pitchOut->prepareBufferOfSize(numFrames);
    SignalType *gateOutputBuffer = gateOut->prepareBufferOfSize(numFrames);
    
    for (int i = 0; i < numFrames; i++) {
        
        double currentBeat = transportController->getBeatBuffer()[i];
        
        if (currentBeat > 0) {
            currentBeat = fmodf(currentBeat, 4);
        }
        
        short step = floor(currentBeat * 4.0);
        
        gateOutputBuffer[i] = 0;
        
        if (transportController->isPlaying() && currentBeat >= 0) {
            
            float delta = (float)i / numFrames;
            
            float gateValue = stepGate[step]->getOutputAtDelta(delta);
            if (gateValue == 0) {
                // Note is off
                gateOutputBuffer[i] = 0;
            } else {
                // Note is on - update the pitch
                CCOLComponentParameter *pitchParameter = stepPitch[step];
                unsigned short note = pitchParameter->getOutputAtDelta(delta) * 12.0;
                freqOut = powf(2, (note - 9) / 12.0) * 440;
                
                // Open / close gate
                if (gateValue == 0.5) {
                    float whence = (currentBeat * 4.0) - step;
                    gateOutputBuffer[i] = (whence > 0.2) ? 0 : 1;
                } else if (gateValue > 0.5) {
                    gateOutputBuffer[i] = 1;
                }
            }
        }
        
        pitchOutputBuffer[i] = freqOut / CV_FREQUENCY_RANGE;
    }
    
}