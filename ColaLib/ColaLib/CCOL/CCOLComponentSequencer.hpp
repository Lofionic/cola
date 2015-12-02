//
//  CCOLComponentSequencer.hpp
//  ColaLib
//
//  Created by Chris Rivers on 01/12/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentSequencer_hpp
#define CCOLComponentSequencer_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"

class CCOLTransportController;
class CCOLComponentSequencer : public CCOLComponent {
    
    CCOLComponentOutput *pitchOut;
    CCOLComponentOutput *gateOut;
    
    CCOLComponentParameter* pitchControls[16];
    
    CCOLTransportController* transportController;
    
    double freqOut;
    
public:
    
    CCOLComponentSequencer(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {  }
    
    void initializeIO() override;
    void renderOutputs(unsigned int numFrames) override;
};

#endif /* CCOLComponentSequencer_hpp */
