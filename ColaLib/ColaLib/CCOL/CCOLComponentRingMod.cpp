//
//  CCOLComponentRingMod.cpp
//  ColaLib
//
//  Created by Ed Rutter on 14/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#include "CCOLComponentRingMod.hpp"

void CCOLComponentRingMod::initializeIO() {
    
    input1 = new CCOLComponentInput(this, kIOTypeAudio, (char*)"In 1");
    input2 = new CCOLComponentInput(this, kIOTypeAudio, (char*)"In 2");
    setInputs(vector<CCOLComponentInput*> {input1, input2});
    
    output = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"Out");
    setOutputs(vector<CCOLComponentOutput *> {output});
    
    mix = new CCOLComponentParameter(this, (char*)"Mix");
    setParameters(vector<CCOLComponentParameter *> {mix});
    
    mix->setNormalizedValue(0.5);
    
}

void CCOLComponentRingMod::renderOutputs(unsigned int numFrames) {
    
    CCOLComponent::renderOutputs(numFrames);
    
    SignalType *input1Buffer = input1->getBuffer(numFrames);
    SignalType *input2Buffer = input2->getBuffer(numFrames);
    
    SignalType *outputBuffer = output->prepareBufferOfSize(numFrames);
    
    for (int i = 0; i < numFrames; i++) {
        float delta = i / (float)numFrames;
        
        float mixValue = mix->getOutputAtDelta(delta);
        
        outputBuffer[i] = (input1Buffer[i] * (input2Buffer[i] * mixValue)) + (input1Buffer[i] * (1-mixValue));
    }
}