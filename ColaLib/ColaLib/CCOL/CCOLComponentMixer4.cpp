//
//  CCOLComponentMixer4.hpp
//  ColaLib
//
//  Created by Ed on 13/1/2016.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponentMixer4.hpp"
#include <math.h>

void CCOLComponentMixer4::initializeIO() {
    
    input1 = new CCOLComponentInput(this, kIOTypeAudio, (char*)"In 1");
    input2 = new CCOLComponentInput(this, kIOTypeAudio, (char*)"In 2");
    input3 = new CCOLComponentInput(this, kIOTypeAudio, (char*)"In 3");
    input4 = new CCOLComponentInput(this, kIOTypeAudio, (char*)"In 4");
    setInputs(vector<CCOLComponentInput*> { input1, input2, input3, input4 });
    
    output = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"Out");
    setOutputs(vector<CCOLComponentOutput*> { output });
    
    level1 = new CCOLComponentParameter(this, (char*)"Level 1");
    level2 = new CCOLComponentParameter(this, (char*)"Level 2");
    level3 = new CCOLComponentParameter(this, (char*)"Level 3");
    level4 = new CCOLComponentParameter(this, (char*)"Level 4");
    setParameters(vector<CCOLComponentParameter*> { level1, level2, level3, level4 });

    level1->setNormalizedValue(0.25);
    level2->setNormalizedValue(0.25);
    level3->setNormalizedValue(0.25);
    level4->setNormalizedValue(0.25);
    
}

void CCOLComponentMixer4::renderOutputs(unsigned int numframes) {
    
    CCOLComponent::renderOutputs(numframes);
    
    SignalType *inputBuffer1 = input1->getBuffer(numframes);
    SignalType *inputBuffer2 = input2->getBuffer(numframes);
    SignalType *inputBuffer3 = input3->getBuffer(numframes);
    SignalType *inputBuffer4 = input4->getBuffer(numframes);
    
    SignalType *outputBuffer = output->prepareBufferOfSize(numframes);
    
    for (int i = 0; i < numframes; i++) {
        float delta = i / (float)numframes;
        float level1Output = level1->getOutputAtDelta(delta);
        float level2Output = level2->getOutputAtDelta(delta);
        float level3Output = level3->getOutputAtDelta(delta);
        float level4Output = level4->getOutputAtDelta(delta);
        
        outputBuffer[i] = tanhf((inputBuffer1[i] * level1Output)
                                + (inputBuffer2[i] * level2Output)
                                + (inputBuffer3[i] * level3Output)
                                + (inputBuffer4[i] * level4Output));
    }
    
}