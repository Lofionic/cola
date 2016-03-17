//
//  CCOLKeyboardComponent.cpp
//  ColaLib
//
//  Created by Chris on 03/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLMIDIComponent.hpp"
#include "CCOLComponentIO.hpp"
#include <math.h>

using namespace std;

void CCOLMIDIComponent::initializeIO() {
    keyboardOut     = new CCOLComponentOutput(this, kIOType1VOct, (char*)"Keyboard Out");
    gateOut         = new CCOLComponentOutput(this, kIOTypeGate, (char*)"Gate Out");
    
    vector<CCOLComponentOutput*> theOutputs = {
        keyboardOut, gateOut
    };
    
    setOutputs(theOutputs);
}

void CCOLMIDIComponent::noteOn(NoteIndex note) {
    if (std::find(noteOns.begin(), noteOns.end(), note) == noteOns.end()) {
        // Add this note to noteOns
        if (gliss) {
            // Glissando - only open gate on first note
            if (noteOns.size() == 0) {
                openGate();
            }
        } else {
            // Not glissando
            openGate();
        }
        noteOns.push_back(note);
        setFrequency();
    }
}

void CCOLMIDIComponent::noteOff(NoteIndex note) {
    
    auto it = std::find(noteOns.begin(), noteOns.end(), note);
    if (it != noteOns.end()) {
        
        // Make note of last key pressed
        NoteIndex lastNote = noteOns.back();
        
        // Remove this note from noteOns
        noteOns.erase(it);
        
        if (noteOns.size() == 0) {
            closeGate();
        } else {
            setFrequency();
            if (!gliss && note == lastNote) {
                openGate();
            }
        }
    }
}

void CCOLMIDIComponent::allNotesOff() {
    noteOns.empty();
    closeGate();
    setFrequency();
}

void CCOLMIDIComponent::setFrequency() {
    if (noteOns.size() > 0) {
        // Set frequency to match last note
        NoteIndex note = noteOns.back();
        float frequency = powf(2, ((int)note - 69) / 12.0) * 110;
        
        // Return as value 0-1, relative to range
        outputValue = frequency / CV_FREQUENCY_RANGE;
    } else {
        outputValue = 0;
    }
}

void CCOLMIDIComponent::openGate() {
    gateOpen        = true;
    gateTrigger     = true;
}

void CCOLMIDIComponent::closeGate() {
    gateOpen        = false;
}

void CCOLMIDIComponent::renderOutputs(unsigned int numFrames) {
    
    CCOLComponent::renderOutputs(numFrames);
    
    // Output Buffers
    SignalType *keyboardOutBuffer = keyboardOut->prepareBufferOfSize(numFrames);
    SignalType *gateOutBuffer = gateOut->prepareBufferOfSize(numFrames);
    
    float pitchbendDelta = (pitchbend - prevPitchbend) / numFrames;
    
    for (int i = 0; i < numFrames; i++) {
        
        float pitchbendNormalized = prevPitchbend + (i * pitchbendDelta);
        
        float adjustValue = (pitchbendNormalized * 2.0) - 1.0;
        adjustValue = (powf(powf(2, (1.0 / 12.0)), adjustValue * pitchbendRange));
        
        keyboardOutBuffer[i] = outputValue * adjustValue;
        
        if (gateOpen) {
            gateOutBuffer[i] = 1;
        } else {
            gateOutBuffer[i] = 0;
        }
    }
    
    if (gateTrigger && gateOpen) {
        gateOutBuffer[0] = 0;
        gateTrigger = false;
    }
    prevPitchbend = pitchbend;
}

