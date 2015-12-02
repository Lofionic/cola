//
//  CCOLComponentPan.cpp
//  ColaLib
//
//  Created by Chris on 30/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponentPan.hpp"

void CCOLComponentPan :: initializeIO() {
    
    output1 = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"Output 1");
    output2 = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"Output 2");
    setOutputs(vector<CCOLComponentOutput*> { output1, output2 });
    
    input = new CCOLComponentInput(this, kIOTypeAudio, (char*)"Input");
    cvInput = new CCOLComponentInput(this, kIOTypeControl, (char*)"CV In");
    setInputs(vector<CCOLComponentInput*> { input, cvInput });
    
    pan = new CCOLComponentParameter(this, (char*)"Pan");
    setParameters(vector<CCOLComponentParameter*> { pan });
}

void CCOLComponentPan::renderOutputs(unsigned int numFrames) {
    
    CCOLComponent::renderOutputs(numFrames);
    
    SignalType *output1Buffer = output1->prepareBufferOfSize(numFrames);
    SignalType *output2Buffer = output2->prepareBufferOfSize(numFrames);
    
    SignalType *inputBuffer = input->getBuffer(numFrames);
    
    for (int i = 0; i < numFrames; i++) {
        
        float delta = i / numFrames;
        float panValue = pan->getOutputAtDelta(delta);
        
        output1Buffer[i] = (1.0 - panValue) * inputBuffer[i];
        output2Buffer[i] = panValue * inputBuffer[i];
        
    }
}