//
//  CCOLComponentNoiseGenerator.cpp
//  ColaLib
//
//  Created by Ed Rutter on 30/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponentNoiseGenerator.hpp"
#include "stdlib.h"

#define ARC4RANDOM_MAX      0x100000000

void CCOLComponentNoiseGenerator::initializeIO() {
    mainOutput = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"Output");
    
    vector<CCOLComponentOutput*> theOutputs = {
        mainOutput
    };
    
    setOutputs(theOutputs);
}

void CCOLComponentNoiseGenerator::renderOutputs(unsigned int numFrames) {
    
    SignalType *mainBuffer = mainOutput->prepareBufferOfSize(numFrames);
    
    for (int i = 0; i < numFrames; i++) {
        mainBuffer[i] = ((double)arc4random() / ARC4RANDOM_MAX);
    }
}