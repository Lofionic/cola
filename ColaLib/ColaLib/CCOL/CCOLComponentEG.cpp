//
//  CCOLComponentEG.cpp
//  ColaLib
//
//  Created by Chris on 11/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponentEG.hpp"
#include "CCOLAudioContext.hpp"
#include "CCOLAudioEngine.hpp"

void CCOLComponentEG::initializeIO() {
    
    gateIn = new CCOLComponentInput(this, kIOTypeGate, (char*)"Gate In");
    setInputs(std::vector<CCOLComponentInput*> { gateIn });
    
    output = new CCOLComponentOutput(this, kIOTypeControl, (char*)"Output");
    setOutputs(std::vector<CCOLComponentOutput*> { output });
    
    attackParameter = new CCOLComponentParameter(this, (char*)"Attack");
    decayParameter = new CCOLComponentParameter(this, (char*)"Decay");
    sustainParameter = new CCOLComponentParameter(this, (char*)"Sustain");
    releaseParameter = new CCOLComponentParameter(this, (char*)"Release");
    setParameters(std::vector<CCOLComponentParameter*> {attackParameter, decayParameter, sustainParameter, releaseParameter});

    attackParameter->setNormalizedValue(0);
    decayParameter->setNormalizedValue(0);
    sustainParameter->setNormalizedValue(1);
    releaseParameter->setNormalizedValue(0);
}

void CCOLComponentEG::renderOutputs(unsigned int numFrames) {

    CCOLComponent::renderOutputs(numFrames);
    
    SignalType *outputBuffer = output->prepareBufferOfSize(numFrames);
    SignalType *gateBuffer = gateIn->getBuffer(numFrames);
    
    double sampleRate = getContext()->getEngine()->getSampleRate();
    
    for (int i = 0; i < numFrames; i++) {
        
        float delta = i / (float)numFrames;
        
        float attackTime = attackParameter->getOutputAtDelta(delta);
        unsigned int attackSamples = attackTime * sampleRate;
        
        float decayTime = decayParameter->getOutputAtDelta(delta);
        unsigned int decaySamples = decayTime * sampleRate;
        
        float sustainLevel = sustainParameter->getOutputAtDelta(delta);
        float releaseTime = releaseParameter->getOutputAtDelta(delta);
        unsigned int releaseSamples = releaseTime * sampleRate;
        
        // Iterate the gate position
        envelopeState = EnvelopeClosed;
        
        float gate = gateBuffer[i];
        
        if (gateOpen && gate == 0) {
            closeGate();
        } else if (!gateOpen && gate == 1) {
            openGate();
        }

        if (gateOpen) {
            
            gateOpenInterval ++;
            
            // Determine the envelope state
            if (gateOpenInterval > 0) {
                envelopeState = EnvelopeAttack;
            }
            
            if (gateOpenInterval > attackSamples) {
                envelopeState = EnvelopeDecay;
            }
            
            if (gateOpenInterval > attackSamples + decaySamples) {
                envelopeState = EnvelopeSustain;
            }
            
        } else if (gateOpenInterval > 0) {
            
            gateClosedInterval ++;
            
            envelopeState = EnvelopeRelease;
            
            if (gateClosedInterval > releaseSamples) {
                envelopeState = EnvelopeClosed;
                resetGate();
            }
        }

        // Return the envelope output level
        SignalType outputValue = 0;
        
        switch (envelopeState) {
            case EnvelopeAttack:
                outputValue = (SignalType)((float)gateOpenInterval / attackSamples);
                gatePeak = outputValue;
                break;
            case EnvelopeDecay: {
                float delta = (gateOpenInterval - attackSamples) / (float)decaySamples;
                outputValue = 1.0 + (sustainLevel - 1.0) * delta;
                gatePeak = outputValue;
            }
                break;
            case EnvelopeSustain:
                outputValue = (SignalType)sustainLevel;
                gatePeak = outputValue;
                break;
            case EnvelopeRelease: {
                float delta = (gateClosedInterval) / (float)releaseSamples;
                outputValue = gatePeak * (1 - delta);
            }
                break;
            default:
                break;
        }

        // Smooth out the signal
        medianWindowSigma -= medianWindow[medianWindowPosition];
        medianWindow[medianWindowPosition] = outputValue;
        medianWindowSigma += outputValue;
        
        medianWindowPosition++;
        if (medianWindowPosition >= MEDIAN_WINDOW_SIZE) {
            medianWindowPosition = 0;
        }
        
        outputValue = medianWindowSigma / MEDIAN_WINDOW_SIZE;
        outputBuffer[i] = outputValue;
    }
}

void CCOLComponentEG::openGate() {
    if (retriggers) {
        resetGate();
    }
    
    gateOpen = true;
    gatePeak = 0;
}

void CCOLComponentEG::closeGate() {
    if (gateOpen) {
        gateOpen = false;
        gateClosedInterval = 0;
    }
}

void CCOLComponentEG::resetGate() {
    gateOpen = false;
    gateOpenInterval = 0;
}