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
        pitchControls[i] = new CCOLComponentParameter(this, (char*)inputName->c_str());
        theParameters.push_back(pitchControls[i]);
        delete inputName;
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
            
            gateOutputBuffer[i] = 1;
            
            CCOLComponentParameter *pitchParameter = pitchControls[step];
            unsigned short note = pitchParameter->getOutputAtDelta((float)i / numFrames) * 12.0;
            
            freqOut = powf(2, (note - 9) / 12.0) * 440;
        }
        
        pitchOutputBuffer[i] = freqOut / CV_FREQUENCY_RANGE;
    }
    
}