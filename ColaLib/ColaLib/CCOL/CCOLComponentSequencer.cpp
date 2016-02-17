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
        delete inputName;
        
        inputName = new string("Gate " + std::to_string(i + 1));
        stepGate[i] = new CCOLComponentParameter(this, (char*)inputName->c_str());
        theParameters.push_back(stepGate[i]);
        delete inputName;
        
        inputName = new string("Slide " + std::to_string(i + 1));
        stepSlide[i] = new CCOLComponentParameter(this, (char*)inputName->c_str());
        theParameters.push_back(stepSlide[i]);
        delete inputName;
    }
    setParameters(theParameters);
    
    pitchOut = new CCOLComponentOutput(this, kIOType1VOct, (char*)"Pitch Out");
    gateOut = new CCOLComponentOutput(this, kIOTypeGate, (char*)"Gate Out");
    
    mod1Out = new CCOLComponentOutput(this, kIOTypeControl, (char*)"Mod 1");
    mod2Out = new CCOLComponentOutput(this, kIOTypeControl, (char*)"Mod 2");
    
    
    setOutputs(vector<CCOLComponentOutput*> { pitchOut, gateOut, mod1Out, mod2Out });
    
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
                float whence = (currentBeat * 4.0) - step;
                float slide = stepSlide[step]->getOutputAtDelta(delta);
                if (slide > 0 && whence < 0.5) {
                    // Slide the note
                    
                    // Get the freq of the previous step
                    CCOLComponentParameter *prevPitchParameter = stepPitch[15];
                    if (step > 0) {
                        prevPitchParameter = stepPitch[step - 1];
                    }
                    SignalType prevFreqOut = prevPitchParameter->getOutputAtDelta(delta) * 12.0;
                    
                    // Get the freq of this step
                    CCOLComponentParameter *pitchParameter = stepPitch[step];
                    SignalType thisFreqOut = pitchParameter->getOutputAtDelta(delta) * 12.0;
                    
                    // Interpolate between the two
                    freqOut = prevFreqOut + ((thisFreqOut - prevFreqOut) * (whence * 2.0));
                    
                } else {
                    CCOLComponentParameter *pitchParameter = stepPitch[step];
                    freqOut = pitchParameter->getOutputAtDelta(delta) * 12.0;
                }
                // Open / close gate
                if (gateValue == 0.5) {
                    gateOutputBuffer[i] = (whence > 0.5) ? 0 : 1;
                } else if (gateValue > 0.5) {
                    gateOutputBuffer[i] = 1;
                }
            }
        }
        
        pitchOutputBuffer[i] = freqOut;
    }
}