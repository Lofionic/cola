//
//  CCOLComponentReverb.cpp
//  ColaLib
//
//  Created by Ed Rutter on 17/02/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#include "CCOLComponentReverb.hpp"
#include "CCOLAudioEngine.hpp"

const float maxDelayTimeMS = 500;

void CCOLComponentReverb::initializeIO() {
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
    bufferLocation1 = 0;
    bufferLocation2 = 0;
}

void CCOLComponentReverb::renderOutputs(unsigned int numFrames) {
    
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
        UInt32 n = 1 + (delayTimeValue);
        for (int j = 0; j <= n; j++) {
            delayBuffer[bufferLocation] = feedbackSignal * 0.3;
            bufferLocation ++;
            if (bufferLocation >= bufferSize) {
                bufferLocation -= bufferSize;
            }
        }
        
        // Skip ahead by n number of samples
        UInt32 n1 = 1 + (3 * delayTimeValue);
        for (int j = 0; j <= n1; j++) {
            delayBuffer[bufferLocation1] += feedbackSignal * 0.6;
            bufferLocation1 ++;
            if (bufferLocation1 >= bufferSize) {
                bufferLocation1 -= bufferSize;
            }
        }
        
        // Skip ahead by n number of samples
        UInt32 n2 = 1 + (7 * delayTimeValue);
        for (int j = 0; j <= n2; j++) {
            delayBuffer[bufferLocation2] += feedbackSignal * 0.9;
            bufferLocation2 ++;
            if (bufferLocation2 >= bufferSize) {
                bufferLocation2 -= bufferSize;
            }
        }
    }
}