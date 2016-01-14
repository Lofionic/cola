//
//  45.cpp
//  ColaLib
//
//  Created by Ed Rutter on 02/12/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponentVCF.hpp"
#include "Math.h"

void CCOLComponentVCF::initializeIO() {
    audioInput  = new CCOLComponentInput(this, kIOTypeAudio, (char*)"Audio in");
    cvFreq      = new CCOLComponentInput(this, kIOTypeControl, (char*)"CV Freq In");
    cvRes       = new CCOLComponentInput(this, kIOTypeControl, (char*)"CV Res In");
    std::vector<CCOLComponentInput*> theInputs = {
        audioInput,
        cvFreq,
        cvRes
    };
    setInputs(theInputs);
    
    lpOut = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"LP Out");
    hpOut = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"HP Out");
    bpOut = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"BP Out");
    notchOut = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"Notch Out");
    std::vector<CCOLComponentOutput*> theOutputs = {
        lpOut,
        hpOut,
        bpOut,
        notchOut
    };
    setOutputs(theOutputs);
    
    paramCutoffFreq     = new CCOLComponentParameter(this, (char*)"Frequency");
    paramRes            = new CCOLComponentParameter(this, (char*)"Resonance");
    paramCvFreqAmount   = new CCOLComponentParameter(this, (char*)"CV Freq Amount");
    paramCvResAmount    = new CCOLComponentParameter(this, (char*)"CV Res Amount");
    
    paramCutoffFreq->setParameterFunction([] (double valueIn) -> double {
        return (valueIn * valueIn * valueIn);
    });
    std::vector<CCOLComponentParameter*> theParameters = {
        paramCutoffFreq,
        paramRes,
        paramCvFreqAmount,
        paramCvResAmount
    };
    setParameters(theParameters);
    
    // Set defaults
    paramCutoffFreq->setNormalizedValue(1.0);
    paramRes->setNormalizedValue(0.5);
    paramCvFreqAmount->setNormalizedValue(0.0);
    paramCvResAmount->setNormalizedValue(0.0);
    
    f = p = q = b0 = b1 = b2 = b3 = b4 = t1 = t2 = 0;
}

void CCOLComponentVCF::renderOutputs(unsigned int numFrames) {
    
    CCOLComponent::renderOutputs(numFrames);
    
    SignalType *lpOutBuffer = lpOut->prepareBufferOfSize(numFrames);
    SignalType *hpOutBuffer = hpOut->prepareBufferOfSize(numFrames);
    SignalType *bpOutBuffer = bpOut->prepareBufferOfSize(numFrames);
    SignalType *notchOutBuffer = notchOut->prepareBufferOfSize((numFrames));
    
    SignalType *audioInputBuffer = audioInput->getBuffer(numFrames);
    SignalType *cvFreqBuffer = cvFreq->getBuffer(numFrames);
    SignalType *cvResBuffer = cvRes->getBuffer(numFrames);
    
    for (int i =  0; i < numFrames; i++) {
        SignalType valueIn = audioInputBuffer[i];
        
        if (valueIn > 1) {
            valueIn = 1;
        } else if (valueIn < -1) {
            valueIn = -1;
        }
        
        float delta = (i / (float)numFrames);
        float cutoff = paramCutoffFreq->getOutputAtDelta(delta);
        
        cutoff = cutoff + (cvFreqBuffer[i] * paramCvFreqAmount->getOutputAtDelta(delta));
        cutoff = fmin(fmax(cutoff, 0.0f), 1.0f);
        
        
        q = 1.0f - cutoff;
        p = cutoff + 0.8f * cutoff * q;
        f = p + p - 1.0f;
        
        float res = paramRes->getOutputAtDelta(delta);
        res = res + (cvResBuffer[i] * paramCvResAmount->getOutputAtDelta(delta));
        res = fminf(fmaxf(res, 0.0f), 1.0f);
        
        q = res * (1.0f + 0.5f * q * (1.0f - q + 5.6f * q * q));
        
        valueIn -= q * b4; //feedback
        
        t1 = b1;  b1 = (valueIn + b0) * p - b1 * f;
        t2 = b2;  b2 = (b1 + t1) * p - b2 * f;
        t1 = b3;  b3 = (b2 + t2) * p - b3 * f;
        b4 = (b3 + t1) * p - b4 * f;
        hpOutBuffer[i] = (SignalType)b4;
        
        b4 = b4 - b4 * b4 * b4 * 0.166667f;    //clipping
        
        if (lpOut->isConnected()) {
            lpOutBuffer[i] = (SignalType)b4;
        }
        
        if (hpOut->isConnected()) {
            hpOutBuffer[i] = (SignalType)(valueIn - b4);
        }
        
        if (bpOut->isConnected()) {
            bpOutBuffer[i] = (SignalType)(3.0f * (b3 - b4));
        }
        
        if (notchOut->isConnected()) {
            notchOutBuffer[i] = (SignalType)(valueIn - (3.0f * (b3 - b4)));
        }
    
        b0 = valueIn;
    }
}