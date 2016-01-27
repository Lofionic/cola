//
//  CCOLComponentDelay.cpp
//  ColaLib
//
//  Created by Ed Rutter on 27/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#include "CCOLComponentDelay.hpp"
#include "CCOLAudioEngine.hpp"

const float maxDelayTimeMS = 2000;

void CCOLComponentDelay::initializeIO() {
    output = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"Output");
    setOutputs(vector<CCOLComponentOutput*> { output });
    
    input = new CCOLComponentInput(this, kIOTypeAudio, (char*)"Input");
    setInputs(vector<CCOLComponentInput*> { input });
    
    
    delayTime   = new CCOLComponentParameter(this, (char*)"Delay Time");
    feedback    = new CCOLComponentParameter(this, (char*)"Feedback");
    mix         = new CCOLComponentParameter(this, (char*)"Mix");
    
    setParameters(vector<CCOLComponentParameter*> { delayTime, feedback, mix });
    
    delayTime->setNormalizedValue(0.5);
    feedback->setNormalizedValue(0.5);
    mix->setNormalizedValue(0.5);
    
    
    // Setup delay buffer
    
    double sampleRate = getContext()->getEngine()->getSampleRate();
    
    bufferSize = sampleRate * (maxDelayTimeMS / 1000);
    
    delayBuffer = (SignalType*)malloc(bufferSize * sizeof(SignalType));
    memset(delayBuffer, 0, bufferSize * sizeof(SignalType));
    
    bufferLocation = 0;
}


void CCOLComponentDelay::renderOutputs(unsigned int numFrames) {
    
    CCOLComponent::renderOutputs(numFrames);
    
    SignalType *inputBuffer = input->getBuffer(numFrames);
    SignalType *outputBuffer = output->prepareBufferOfSize(numFrames);
    
    for (int i = 0; i < numFrames; i++) {
        float delta = i / (float) numFrames;
        
        float feedbackValue = feedback->getOutputAtDelta(delta);
        float delayTimeValue = delayTime->getOutputAtDelta(delta);
        float mixValue = mix->getOutputAtDelta(delta);
        
        SignalType inSignal = inputBuffer[i];
        
        SignalType delaySignal = inSignal + delayBuffer[bufferLocation];
        delaySignal = fmin(fmax(delaySignal, -1.0f), 1.0f);        

        
        outputBuffer[i] = inSignal + (delaySignal - inSignal) * mixValue;
        
        SignalType feedbackSignal = inSignal + (delaySignal * feedbackValue);
        feedbackSignal = fmin(fmax(feedbackSignal, -1.0f), 1.0f);
        
        // Skip ahead by n number of samples
        UInt32 n = 1 + (10.0 * delayTimeValue);
        for (int j = 0; j <= n; j++) {
            delayBuffer[bufferLocation] = feedbackSignal;
            bufferLocation ++;
            if (bufferLocation >= bufferSize) {
                bufferLocation -= bufferSize;
            }
        }
    }
}