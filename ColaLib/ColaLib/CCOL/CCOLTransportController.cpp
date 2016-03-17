//
//  CCOLTransportController.cpp
//  ColaLib
//
//  Created by Chris Rivers on 01/12/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//


#include <AudioToolbox/AudioToolbox.h>

#include "CCOLTransportController.hpp"
#include "CCOLIAAController.hpp"

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
}

void CCOLTransportController::syncWithIAA() {
    // TODO: Inter-app audio sync
    if (iaaController->isHostConnected()) {
        Float64 iaaTempo = iaaController->getHostTempo();
        if (iaaTempo > 0) {
            tempo = iaaTempo;
            currentBeat = iaaController->getHostBeat();
        }
    }
}

void CCOLTransportController::interappAudioTransportStateDidChange(CCOLIAAController *iaaController) {
    // TODO: Respond to inter-app audio instructions
    BOOL hostPlaying = iaaController->isHostPlaying();
    if (hostPlaying && !isPlaying()) {
        syncWithIAA();
        playing = true;
        postUpdateNotification();
    } else if (!hostPlaying && isPlaying()) {
        playing = false;
        postUpdateNotification();
    }
}