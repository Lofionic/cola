//
//  CCOLComponentLFO.cpp
//  ColaLib
//
//  Created by Chris on 14/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponentLFO.hpp"
#include "CCOLAudioContext.hpp"
#include "CCOLAudioEngine.hpp"

void CCOLComponentLFO::initializeIO() {
    
    mainOut = new CCOLComponentOutput(this, kIOTypeControl, (char*)"Out");
    setOutputs(std::vector<CCOLComponentOutput*> { mainOut } );
    
    freqIn = new CCOLComponentInput(this, kIOTypeControl, (char*)"FreqIn");
    setInputs(std::vector<CCOLComponentInput*> { freqIn } );
    
    rate = new CCOLComponentParameter(this, (char*)"Rate");
    waveform = new CCOLComponentParameter(this, (char*)"Wave");
    setParameters(std::vector<CCOLComponentParameter*> { rate, waveform });
    
    rate->setNormalizedValue(0.5);
    waveform->setNormalizedValue(0);
}

void CCOLComponentLFO::renderOutputs(unsigned int numFrames) {
    
    CCOLComponent::renderOutputs(numFrames);
    
    // Input buffers
    SignalType *frequencyBuffer = freqIn->getBuffer(numFrames);
    
    // Output buffer
    SignalType *outBuffer = mainOut->prepareBufferOfSize(numFrames);
    
    double sampleRate = getContext()->getEngine()->getSampleRate();
    
    for (int i = 0; i < numFrames; i++) {
        SignalType freq = FLT_MIN;
        
        float delta = (i / (float)numFrames);
        
        if (freqIn->isConnected()) {
            freq = frequencyBuffer[i] + 1;
        } else {
            freq = rate->getOutputAtDelta(delta) * 10.0;
        }
        
        phase += (2.0 * M_PI * (freq)) / sampleRate;
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        
        float sampleIndexFloat = (phase / (M_PI * 2)) * (WAVETABLE_SIZE - 1);
        
        int waveformIndex = waveform->getNormalizedValue() * 5;
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
            // Ramp
            sampleLower = ccRampWaveTable[(int)floor(sampleIndexFloat)];
            sampleUpper = ccRampWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveformIndex == 4) {
            // Square
            sampleLower = ccSquareWaveTable[(int)floor(sampleIndexFloat)];
            sampleUpper = ccSquareWaveTable[(int)ceil(sampleIndexFloat)];
        }
        
        float remainder = fmodf(sampleIndexFloat, 1);
        
        outBuffer[i] = sampleLower + (sampleUpper - sampleLower) * remainder;
    }
}


//-(void)initializeIO {
//    
//    self.mainOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"Out"];
//    [self setOutputs:@[self.mainOut]];
//    
//    self.freqIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"FreqIn"];
//    [self setInputs:@[self.freqIn]];
//    
//    self.rate = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Rate"];
//    [self.rate setNormalizedValue:0.5];
//    
//    self.waveform = [[COLDiscreteParameter alloc] initWithComponent:self withName:@"Wave" max:5];
//    [self setParameters:@[self.rate, self.waveform]];
//}

