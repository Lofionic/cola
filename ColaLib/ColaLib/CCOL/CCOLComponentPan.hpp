//
//  CCOLComponentPan.hpp
//  ColaLib
//
//  Created by Chris on 30/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentPan_hpp
#define CCOLComponentPan_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"

class CCOLComponentPan : public CCOLComponent {
    
    CCOLComponentInput *input;
    CCOLComponentInput *cvInput;
    
    CCOLComponentOutput *output1;
    CCOLComponentOutput *output2;
    
    CCOLComponentParameter *pan;
    
public:
    CCOLComponentPan(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
        
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
};

#endif /* CCOLComponentPan_hpp */
