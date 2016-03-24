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
    
    cvIn = new CCOLComponentInput(this, kIOTypeControl, (char*)"CVIn");
    setInputs(std::vector<CCOLComponentInput*> { cvIn } );
    
    rate = new CCOLComponentParameter(this, (char*)"Rate");
    rate->setParameterFunction([] (double valueIn) -> double {
        return (powf(MAX(valueIn, 0.15f),3.3f)*100.0f);
    });
    
    cvAmt = new CCOLComponentParameter(this, (char*)"CVAmt");
    waveform = new CCOLComponentParameter(this, (char*)"Wave");
    setParameters(std::vector<CCOLComponentParameter*> { rate, cvAmt, waveform });
    
    rate->setNormalizedValue(0.5);
    waveform->setNormalizedValue(0);
}

void CCOLComponentLFO::renderOutputs(unsigned int numFrames) {
    
    CCOLComponent::renderOutputs(numFrames);
    
    // Input buffers
    SignalType *frequencyBuffer = cvIn->getBuffer(numFrames);
    
    // Output buffer
    SignalType *outBuffer = mainOut->prepareBufferOfSize(numFrames);
    
    double sampleRate = getContext()->getEngine()->getSampleRate();
    
    for (int i = 0; i < numFrames; i++) {
        SignalType freq = FLT_MIN;
        
        float delta = (i / (float)numFrames);
        
        if (cvIn->isConnected()) {
            freq = frequencyBuffer[i] + 1;
        } else {
            freq = rate->getOutputAtDelta(delta);
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
        float out = sampleLower + (sampleUpper - sampleLower) * remainder;
        outBuffer[i] = (out / 2.0) + 0.5;
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

