//
//  CCOLTransportController.cpp
//  ColaLib
//
//  Created by Chris Rivers on 01/12/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLTransportController.hpp"
#include <AudioToolbox/AudioToolbox.h>

void CCOLTransportController::start() {
    playing = true;
    postUpdateNotification();
}

void CCOLTransportController::stop() {
    playing = false;
    postUpdateNotification();
}

// Stop and return to start
void CCOLTransportController::stopAndReset() {
    playing = false;
    currentBeat = 0;
    postUpdateNotification();
}

void CCOLTransportController::postUpdateNotification() {
    // post a notification that the transport status has changed
}

void CCOLTransportController::renderOutputs(unsigned int numFrames, double sampleRate) {
    
    if (numFrames != bufferSize) {
        if (beatBuffer != nullptr) {
            free(beatBuffer);
        }
        bufferSize = numFrames;
        beatBuffer = (double*)malloc(bufferSize * sizeof(double));
        memset(beatBuffer, 0, bufferSize * sizeof(double));
    }
    
    syncWithIAA();
    
    // Write a beatmap into the buffer
    float barLength = (60.0 / tempo) * 4.0;
    float samplesInBar = barLength * sampleRate;
    float sampleDelta = 4.0 / samplesInBar;
    
    for (int i =0; i < numFrames; i++) {
        if (playing) {
            beatBuffer[i] = currentBeat;
            currentBeat += sampleDelta;
        }
    }
    
    if (playing) {
        printf("CCOLTransporterControl : %.3f\n", beatBuffer[0]);
    }
}

void CCOLTransportController::syncWithIAA() {
    // TODO: Inter-app audio sync
}

void CCOLTransportController::interappAudioTransportStateDidChange() {
    // TODO: Respond to inter-app audio instructions
}