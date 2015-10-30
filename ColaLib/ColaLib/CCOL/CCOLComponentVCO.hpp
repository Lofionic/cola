//
//  CCOLComponentVCO.hpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentVCO_hpp
#define CCOLComponentVCO_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"
#include "CCOLComponentIO.hpp"

class CCOLComponentVCO : public CCOLComponent {
    
    double                  phase = 0;
    CCOLComponentOutput*    mainOutput;
    SignalType              previousResult = 0;
    
public:
    CCOLComponentVCO(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {

    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
    const char*     getDefaultName() override;
};

#endif /* CCOLComponentVCO_hpp */
