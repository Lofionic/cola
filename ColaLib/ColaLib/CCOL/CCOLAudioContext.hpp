//
//  CCOLAudioContext.hpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLAudioContext_hpp
#define CCOLAudioContext_hpp

#include <stdio.h>
#include <vector>
#include "CCOLComponentIO.hpp"

using namespace std;

class CCOLAudioContext {
 
private:
    CCOLAudioContext();
    vector<CCOLComponentInput> masterInputs;
    
public:

    static CCOLAudioContext* globalContext() {

        static CCOLAudioContext INSTANCE;

        return &INSTANCE;
    }
    
    CCOLComponentInput *masterInput(unsigned int index) {
        return &masterInputs.at(index);
    }
};

#endif /* CCOLAudioContext_hpp */
