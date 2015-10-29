//
//  CCOLComponentVCO.cpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//
#include <math.h>
#include "CCOLComponentVCO.hpp"

void CCOLComponentVCO::renderOutputs(unsigned int numFrames) {
    
    SignalType *mainOutBuffer = mainOutput.prepareBufferOfSize(numFrames);
    
    double sampleRate = 44000.00;

    for (int i = 0; i < numFrames; i++) {
        float sampleIndexFloat = (phase / (M_PI * 2)) * (WAVETABLE_SIZE - 1);
        
        short unsigned int waveformIndex = 1;
        
        SignalType sampleLower = 0;
        SignalType sampleUpper = 0;
        if (waveformIndex == 0) {
            // Sinwave
            sampleLower = sinWaveTable[(int)floor(sampleIndexFloat)];
            sampleUpper = sinWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveformIndex == 1) {
            // Triwave
            sampleLower = triWaveTable[(int)floor(sampleIndexFloat)];
            sampleUpper = triWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveformIndex == 2) {
            // Sawtooth
            sampleLower = sawWaveTable[(int)floor(sampleIndexFloat)];
            sampleUpper = sawWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveformIndex == 3) {
            // Square (pulse)
            sampleLower = squareWaveTable[(int)floor(sampleIndexFloat)];
            sampleUpper = squareWaveTable[(int)ceil(sampleIndexFloat)];
        }
        
        float remainder = fmodf(sampleIndexFloat, 1);
        SignalType result = sampleLower + (sampleUpper - sampleLower) * remainder;
        
        // Increment phase
        float freq = 0.5;
        unsigned int range = 2;
        float tune = 0.05;
        
        phase += (M_PI * freq * CV_FREQUENCY_RANGE * pow(2, range) * tune) / sampleRate;
        
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        
        if (result > 0 != (previousResult < 0) || result == 0) {
            //TODO: Change waveform on zero crossover
        }
        
        mainOutBuffer[i] = previousResult = result;
        
    }

    CCOLComponent::renderOutputs(numFrames);
}

void CCOLComponentVCO::initializeIO() {
    
    std::vector<CCOLComponentInput*> theInputs = { };
    setInputs(theInputs);
    
    mainOutput.init(this, kIOTypeAudio, (char*)"Output");
    
    vector<CCOLComponentOutput*> theOutputs = {
        &mainOutput
    };
    
    setOutputs(theOutputs);
}

const char* CCOLComponentVCO::getDefaultName() {
    return "VCO";
}