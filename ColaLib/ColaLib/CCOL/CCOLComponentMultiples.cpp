//
//  CCOLMultiples.cpp
//  ColaLib
//
//  Created by Chris Rivers on 23/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponentMultiples.hpp"

void CCOLComponentMultiples::initializeIO() {
    
    inputA = new CCOLComponentInput(this, kIOTypeDynamic, (char*)"In A");
    inputB = new CCOLComponentInput(this, kIOTypeDynamic, (char*)"In B");
    setInputs(vector<CCOLComponentInput*> { inputA, inputB });
    
    vector<CCOLComponentOutput*> theOutputs;
    for (int i = 0; i < 4; i++) {
        char* outputNameA = new char[6];
        sprintf(outputNameA, "Out A%i", i + 1);
        CCOLComponentOutput *newOutputA = new CCOLComponentOutput(this, kIOTypeDynamic, outputNameA);
        newOutputA->setLinkedInput(inputA);
        
        theOutputs.push_back(newOutputA);
        free(outputNameA);
    }
    
    for (int i = 0; i < 4; i++) {
        
        char* outputNameB = new char[6];
        sprintf(outputNameB, "Out B%i", i + 1);
        CCOLComponentOutput *newOutputB = new CCOLComponentOutput(this, kIOTypeDynamic, outputNameB);
        newOutputB->setLinkedInput(inputB);
        
        theOutputs.push_back(newOutputB);
        free(outputNameB);
    }
    
    setOutputs(theOutputs);
}

void CCOLComponentMultiples::renderOutputs(unsigned int numFrames) {
    CCOLComponent::renderOutputs(numFrames);
    
    SignalType *inputABuffer = inputA->getBuffer(numFrames);
    SignalType *inputBBuffer = inputB->getBuffer(numFrames);
    
    SignalType *outputBuffers[8];
    
    for (int j = 0; j < 8; j++) {
        CCOLComponentOutput *thisOut = getOutputForIndex(j);
        outputBuffers[j] = thisOut->prepareBufferOfSize(numFrames);

    }
    
    for (int i = 0; i < numFrames; i++) {
        
        for (int j = 0; j < 4; j++) {
            CCOLComponentOutput *outA = getOutputForIndex(j);
            if (outA->isConnected()) {
                outputBuffers[j][i] = inputABuffer[i];
            }
            
            CCOLComponentOutput *outB = getOutputForIndex(j + 4);
            if (outB->isConnected()) {
                outputBuffers[j + 4][i] = inputBBuffer[i];
            }
        }
    }
}