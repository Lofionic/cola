//
//  CCOLComponentMixer.cpp
//  ColaLib
//
//  Created by Chris on 24/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponentMixer.hpp"
#include <math.h>

void CCOLComponentMixer::initializeIO() {
    
    input1 = new CCOLComponentInput(this, kIOTypeAudio, (char*)"In 1");
    input2 = new CCOLComponentInput(this, kIOTypeAudio, (char*)"In 2");
    setInputs(vector<CCOLComponentInput*> { input1, input2 });
    
    output = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"Out");
    setOutputs(vector<CCOLComponentOutput*> { output });
    
    level1 = new CCOLComponentParameter(this, (char*)"Level 1");
    level2 = new CCOLComponentParameter(this, (char*)"Level 2");
    setParameters(vector<CCOLComponentParameter*> { level1, level2 });

    level1->setNormalizedValue(0.5);
    level2->setNormalizedValue(0.5);
    
}

void CCOLComponentMixer::renderOutputs(unsigned int numframes) {
    
    CCOLComponent::renderOutputs(numframes);
    
    SignalType *inputBuffer1 = input1->getBuffer(numframes);
    SignalType *inputBuffer2 = input2->getBuffer(numframes);
    
    SignalType *outputBuffer = output->prepareBufferOfSize(numframes);
    
    for (int i = 0; i < numframes; i++) {
        float delta = i / (float)numframes;
        float level1Output = level1->getOutputAtDelta(delta);
        float level2Output = level2->getOutputAtDelta(delta);
        
        outputBuffer[i] = tanhf((inputBuffer1[i] * level1Output) + (inputBuffer2[i] * level2Output));
    }
    
}