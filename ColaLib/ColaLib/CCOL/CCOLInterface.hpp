//
//  CCOLMasterComponent.hpp
//  ColaLib
//
//  Created by Chris on 03/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLMasterComponent_hpp
#define CCOLMasterComponent_hpp

#include <stdio.h>
#include <string>
#include "CCOLDefines.h"
#include "CCOLComponent.hpp"
#include "CCOLComponentIO.hpp"

// A component used to connect to the audio engine
class CCOLInterfaceComponent : public CCOLComponent {

public:
    CCOLInterfaceComponent(CCOLAudioContext *contextIn) : CCOLComponent(contextIn)  { }
    
    void initializeIO(unsigned int inputCount);
    CCOLComponentInput* getInputForIndex(short unsigned int index) override;
    
private:
    CCOLComponentInput* inputs[16];
};

#endif /* CCOLMasterComponent_hpp */
