//
//  CCOLComponentNoiseGenerator.hpp
//  ColaLib
//
//  Created by Ed Rutter on 30/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentNoiseGenerator_hpp
#define CCOLComponentNoiseGenerator_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"
#include "CCOLTypes.h"

class CCOLComponentOutput;
class CCOLComponentNoiseGenerator : public CCOLComponent {
    
    CCOLComponentParameter* outputLevel;
    CCOLComponentOutput*    mainOutput;
    
public:
    CCOLComponentNoiseGenerator(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
        
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
};

#endif /* CCOLComponentNoiseGenerator_hpp */
