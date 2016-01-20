//
//  CCOLComponentLogic.cpp
//  ColaLib
//
//  Created by Ed Rutter on 20/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#include "CCOLComponentLogic.hpp"
#include <math.h>

void CCOLComponentLogic::initializeIO() {
    
    input1 = new CCOLComponentInput(this, kIOTypeAudio, (char*)"Carrier In");
    input2 = new CCOLComponentInput(this, kIOTypeAudio, (char*)"Modulator In");
    setInputs(vector<CCOLComponentInput*> { input1, input2 });
    
    outputGreatThanMod = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"GreatThanMod Out");
    outputModIsPos    = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"IfModIsPos Out");
    outputModBufferDelay = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"ModBufferDelay Out");
    outputModBufferDelay2 = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"ModBufferDelay2 Out");
    outputModBufferDelay3 = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"ModBufferDelay3 Out");

    setOutputs(vector<CCOLComponentOutput *> { outputGreatThanMod, outputModIsPos, outputModBufferDelay, outputModBufferDelay2, outputModBufferDelay3 });
}

void CCOLComponentLogic::renderOutputs(unsigned int numFrames) {
    CCOLComponent::renderOutputs(numFrames);
    
    SignalType *inputBuffer1 = input1->getBuffer(numFrames);
    SignalType *inputBuffer2 = input2->getBuffer(numFrames);
    
    SignalType *outputBuffer1 = outputGreatThanMod->prepareBufferOfSize(numFrames);
    SignalType *outputBuffer2 = outputModIsPos->prepareBufferOfSize(numFrames);
    SignalType *outputBuffer3 = outputModBufferDelay->prepareBufferOfSize(numFrames);
    SignalType *outputBuffer3a = outputModBufferDelay2->prepareBufferOfSize(numFrames);
    SignalType *outputBuffer3b = outputModBufferDelay3->prepareBufferOfSize(numFrames);
    
    
    
    for (int i = 0; i < numFrames; i++) {
        
        // If the absolute carrier level is greater than the absolute modulator level, output the carrier signal.
        if (fabsf(inputBuffer1[i]) > fabsf(inputBuffer2[i])) {
            outputBuffer1[i] = inputBuffer1[i];
        } else {
            outputBuffer1[i] = 0;
        }
        
        // If the modulator level is positive, output the carrier signal.
        if (inputBuffer2[i] > 0) {
            outputBuffer2[i] = inputBuffer1[i];
        } else {
            outputBuffer2[i] = 0;
        }
        
        
        // Offset the input buffer read by a multiple of the modulator
        // May produce weird behaviour if offset pushes the buffer read position outside of buffer range
        
        // Offset with no bounds
        int bufferOffset = int(inputBuffer2[i] * numFrames);
        outputBuffer3[i] = inputBuffer1[i+bufferOffset];
        
        // Offset and constrained within buffer
        if (bufferOffset+i < numFrames && bufferOffset+i > 0) {
            outputBuffer3a[i] = inputBuffer1[bufferOffset+i];
        } else if (bufferOffset+i > numFrames) {
            outputBuffer3a[i] = inputBuffer1[numFrames];
        } else if (bufferOffset+i < 0) {
            outputBuffer3a[i] = inputBuffer1[0];
        }
        
        // Offset by 0-1 * numframes with no bounds
        int bufferOffset2 = int((inputBuffer2[i]+1) * 0.5  * numFrames);
        outputBuffer3b[i] = inputBuffer1[i+bufferOffset2];
        
    }
    
    
}