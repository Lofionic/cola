//
//  CCOLMultiples.hpp
//  ColaLib
//
//  Created by Chris Rivers on 23/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentMultiples_hpp
#define CCOLComponentMultiples_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"
#include "CCOLTypes.h"

class CCOLComponentMultiples : public CCOLComponent {
    
    CCOLComponentInput *inputA;
    vector<CCOLComponentOutput*> outAs;
    
    CCOLComponentInput *inputB;
    vector<CCOLComponentOutput*> outBs;
    
    const char* getComponentType() override { return kCCOLComponentTypeMultiples; }
    
public:
    CCOLComponentMultiples(CCOLAudioContext *contextIn):CCOLComponent(contextIn) {
        
    }
    
    void            initializeIO() override;
    void            renderOutputs(unsigned int numFrames) override;
};


#endif /* CCOLComopnentMultiples_hpp */
