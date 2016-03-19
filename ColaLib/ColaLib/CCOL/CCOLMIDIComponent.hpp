//
//  CCOLKeyboardComponent.hpp
//  ColaLib
//
//  Created by Chris on 03/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLMIDIComponent_hpp
#define CCOLMIDIComponent_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"
#include "CCOLTypes.h"

class CCOLMIDIComponent : public CCOLComponent {

public:

    CCOLMIDIComponent(CCOLAudioContext* context):CCOLComponent(context) {
        gateOpen        = false;
        gateTrigger     = false;
        gliss           = false;
        pitchbend = prevPitchbend = 0.5;
        pitchbendRange = 12;
        outputValue = 0;
    }
    void initializeIO() override;
    void renderOutputs(unsigned int numFrames) override;
    
    void noteOn(NoteIndex note);
    void noteOff(NoteIndex note);
    void allNotesOff();
    
    void setPitchbend(float value);
    void setModulation(float value);
    
private:
    vector<NoteIndex>   noteOns;
    
    CCOLComponentOutput     *keyboardOut;
    CCOLComponentOutput     *gateOut;
    CCOLComponentOutput     *modOut;

    SignalType      outputValue;
    bool            gateOpen;
    bool            gateTrigger;
    bool            gliss;
    float           pitchbend;
    float           prevPitchbend;
    float           modulation;
    float           prevModulation;
    unsigned int    pitchbendRange;
  
    void openGate();
    void closeGate();
    void setFrequency();
};

#endif /* CCOLMIDIComponent_hpp */
