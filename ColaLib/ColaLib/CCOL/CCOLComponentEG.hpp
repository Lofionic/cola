//
//  CCOLComponentEG.hpp
//  ColaLib
//
//  Created by Chris on 11/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentEG_hpp
#define CCOLComponentEG_hpp

#include <stdio.h>
#include "CCOLDefines.h"
#include "CCOLComponent.hpp"

#define MEDIAN_WINDOW_SIZE 50

class CCOLComponentEG : public CCOLComponent {
    
public:    typedef enum kCCOLEnvelopeState {
        EnvelopeClosed,
        EnvelopeAttack,
        EnvelopeDecay,
        EnvelopeSustain,
        EnvelopeRelease
    } kCCOLEnvelopeState;
    
    bool gateOpen;
    bool retriggers;
    unsigned long int gateOpenInterval;    // Count of samples gate has been open for
    unsigned long int gateClosedInterval;  // Sample after opening at which gate was closed
    SignalType gatePeak;
    kCCOLEnvelopeState envelopeState;
    
    SignalType medianWindow[MEDIAN_WINDOW_SIZE];
    SignalType medianWindowSigma;
    unsigned long int medianWindowPosition;
    
    CCOLComponentInput *gateIn;
    CCOLComponentOutput *output;
    
    CCOLComponentParameter *attackParameter;
    CCOLComponentParameter *decayParameter;
    CCOLComponentParameter *sustainParameter;
    CCOLComponentParameter *releaseParameter;

    CCOLComponentEG(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
        gateOpen = false;
        gateOpenInterval = 0;
        gateClosedInterval = 0;
        gatePeak = 0;
        envelopeState = EnvelopeClosed;
        retriggers = true;
        
        memset(medianWindow, 0, sizeof(SignalType) * MEDIAN_WINDOW_SIZE);
        medianWindowSigma = 0;
        medianWindowPosition = 0;
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
    
    const char* getComponentType() override { return kCCOLComponentTypeEG; }
    
private:
    void openGate();
    void closeGate();
    void resetGate();
};

#endif /* CCOLComponentEG_hpp */
