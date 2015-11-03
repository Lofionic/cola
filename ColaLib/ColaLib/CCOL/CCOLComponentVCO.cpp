//
//  CCOLComponentVCO.cpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//
#include <math.h>

#include "CCOLComponentVCO.hpp"
#include "CCOLDefines.h"
#include "CCOLComponentIO.hpp"
#include "CCOLComponentParameter.hpp"

void CCOLComponentVCO::renderOutputs(unsigned int numFrames) {
    
    SignalType *mainOutBuffer = mainOutput->prepareBufferOfSize(numFrames);
    
    double sampleRate = 44100.00;

    for (int i = 0; i < numFrames; i++) {
        float sampleIndexFloat = (phase / (M_PI * 2)) * (WAVETABLE_SIZE - 1);

        SignalType sampleLower = 0;
        SignalType sampleUpper = 0;
        if (waveformIndex == 0) {
            // Sinwave
            sampleLower = ccSinWaveTable[(int)floor(sampleIndexFloat)];
            sampleUpper = ccSinWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveformIndex == 1) {
            // Triwave
            sampleLower = ccTriWaveTable[(int)floor(sampleIndexFloat)];
            sampleUpper = ccTriWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveformIndex == 2) {
            // Sawtooth
            sampleLower = ccSawWaveTable[(int)floor(sampleIndexFloat)];
            sampleUpper = ccSawWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveformIndex == 3) {
            // Square (pulse)
            sampleLower = ccSquareWaveTable[(int)floor(sampleIndexFloat)];
            sampleUpper = ccSquareWaveTable[(int)ceil(sampleIndexFloat)];
        }
        
        float remainder = fmodf(sampleIndexFloat, 1);
        SignalType result = sampleLower + (sampleUpper - sampleLower) * remainder;
       
        float delta = ((float)i / numFrames);
        float freqIn = 0.02;
        unsigned int rangeIn = 2;
        float tuneIn = tune->getOutputAtDelta(delta);
        
        phase += (M_PI * freqIn * CV_FREQUENCY_RANGE * pow(2, rangeIn) * tuneIn) / sampleRate;
        
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        
        if (result > 0 != (previousResult < 0) || result == 0) {
            //TODO: Change waveform on zero crossover
            if (waveformIndex != waveform->getSelectedIndex()) {
                waveformIndex = waveform->getSelectedIndex();
                phase = 0;
            }
        }
        
        mainOutBuffer[i] = previousResult = result;
        
    }

    CCOLComponent::renderOutputs(numFrames);
}

void CCOLComponentVCO::initializeIO() {
    
    keyboardIn = new CCOLComponentInput(this, kIOType1VOct, (char*)"Keyboard In");
    fmodIn = new CCOLComponentInput(this, kIOTypeControl, (char*)"FM In");
    std::vector<CCOLComponentInput*> theInputs = {
        keyboardIn,
        fmodIn
    };
    setInputs(theInputs);
    
    mainOutput = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"Out");
    vector<CCOLComponentOutput*> theOutputs = {
        mainOutput
    };
    setOutputs(theOutputs);
    
    range =     new CCOLDiscreteParameter(this, (char*)"Range", 4);
    waveform =  new CCOLDiscreteParameter(this, (char*)"Waveform", 4);
    tune =      new CCOLContinuousParameter(this, (char*)"Tune");
    tune->setParameterFunction([] (double valueIn) -> double {
        float output = (valueIn * 2.0) - 1.0;
        return (powf(powf(2, (1.0 / 12.0)), output * 7));
    });
    fmAmt =     new CCOLContinuousParameter(this, (char*)"FM Amt");
    vector<CCOLComponentParameter*> theParams = {
        range,
        waveform,
        tune,
        fmAmt
    };
    setParameters(theParams);
    
    // Set defaults
    range->setSelectedIndex(0);
    waveform->setSelectedIndex(0);
    tune->setNormalizedValue(0.5);
    fmAmt->setNormalizedValue(0.5);
}

const char* CCOLComponentVCO::getDefaultName() {
    return "VCO";
}