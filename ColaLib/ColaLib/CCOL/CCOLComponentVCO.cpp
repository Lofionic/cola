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
#include "CCOLAudioContext.hpp"
#include "CCOLAudioEngine.hpp"

void CCOLComponentVCO::renderOutputs(unsigned int numFrames) {
    
    SignalType *mainOutBuffer = mainOutput->prepareBufferOfSize(numFrames);
    
    SignalType *keyboardInBuffer    = keyboardIn->getBuffer(numFrames);
    SignalType *fmInBuffer          = fmodIn->getBuffer(numFrames);
    
    double sampleRate = getContext()->getEngine()->getSampleRate();

    unsigned int rangeIn = floor(range->getNormalizedValue() * 4);
    
    bool keyboardConnected = keyboardIn->isConnected();
    bool fmInConnected = fmodIn->isConnected();
    
    remainder = delta = tuneIn = freqIn = lfoValue = 0;
    
    for (int i = 0; i < numFrames; i++) {
        float sampleIndexFloat = (phase / (M_PI * 2)) * (WAVETABLE_SIZE - 1);

        SignalType sampleLower = 0;
        SignalType sampleUpper = 0;
        
        if (keyboardConnected) {
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
        }
        
        remainder = fmodf(sampleIndexFloat, 1);
        SignalType result = sampleLower + (sampleUpper - sampleLower) * remainder;
       
        // Increment phase
        delta = ((float)i / numFrames);
        
        // Get the setting of the tune control
        tuneIn = tune->getOutputAtDelta(delta);
        
        // Get the frequency form the keyboard in
        if (keyboardConnected) {
            freqIn = keyboardInBuffer[i];
        } else {
            freqIn = 0;
        }
        // Modulate the frequency according to FM in
        if (fmInConnected) {
            delta = i / (float)numFrames;
            lfoValue = powf(0.5, (-fmInBuffer[i] * fmAmt->getOutputAtDelta(delta)));
            freqIn *= lfoValue;
        }
        
        phase += (M_PI * freqIn * CV_FREQUENCY_RANGE * pow(2, rangeIn) * tuneIn) / sampleRate;
        
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        
        if (result > 0 != (previousResult < 0) || result == 0) {
            //TODO: Change waveform on zero crossover
            if (waveformIndex != waveform->getNormalizedValue()*4) {
                waveformIndex = waveform->getNormalizedValue()*4;
                phase = 0;
            }
        }
        
        mainOutBuffer[i] = previousResult = result;
        
    }

    CCOLComponent::renderOutputs(numFrames);
}

void CCOLComponentVCO::initializeIO() {
    
    keyboardIn = new CCOLComponentInput(this, kIOType1VOct, (char*)"Key In");
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
    
    range =     new CCOLComponentParameter(this, (char*)"Range");
    waveform =  new CCOLComponentParameter(this, (char*)"Waveform");
    tune =      new CCOLComponentParameter(this, (char*)"Tune");
    fmAmt =     new CCOLComponentParameter(this, (char*)"FM");
    
    tune->setParameterFunction([] (double valueIn) -> double {
        // A function that adjusts tune control to ±7 semitone multiplier
        float output = (valueIn * 2.0) - 1.0;
        return (powf(powf(2, (1.0 / 12.0)), output * 7));
    });
    
    vector<CCOLComponentParameter*> theParams = {
        range,
        waveform,
        tune,
        fmAmt
    };
    setParameters(theParams);
    
    // Set defaults
    range->setNormalizedValue(1 / 4.0);
    waveform->setNormalizedValue(0);
    tune->setNormalizedValue(0.5);
    fmAmt->setNormalizedValue(0.5);
}