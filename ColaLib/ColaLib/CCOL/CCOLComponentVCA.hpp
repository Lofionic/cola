//
//  CCOLComponentVCA.hpp
//  ColaLib
//
//  Created by Chris on 15/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentVCA_hpp
#define CCOLComponentVCA_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"
#include "CCOLTypes.h"

class CCOLComponentVCA : public CCOLComponent {

    CCOLComponentOutput *output;
    
    CCOLComponentInput  *input;
    CCOLComponentInput  *CVin;
    
    CCOLComponentParameter *level;
    CCOLComponentParameter *CVAmt;
    
    const char* getComponentType() override { return kCCOLComponentTypeVCA; }
    
public:
    CCOLComponentVCA(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
};

#endif /* CCOLComponentVCA_hpp */
