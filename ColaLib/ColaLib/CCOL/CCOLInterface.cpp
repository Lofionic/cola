//
//  CCOLMasterComponent.cpp
//  ColaLib
//
//  Created by Chris on 03/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLInterface.hpp"

void CCOLInterfaceComponent::initializeIO(unsigned int inputCount) {
    
    vector<CCOLComponentInput*> theInputs;
    for (int i = 0; i < inputCount; ++i) {
        string* inputName = new string("In " + std::to_string(i));
        inputs[i] = new CCOLComponentInput(this, kIOTypeAudio, (const char*)inputName->c_str());
        theInputs.push_back(inputs[i]);
        delete inputName;
    }
    
    setInputs(theInputs);

    printf("Initialized interface with %i inputs\n", inputCount);
}

CCOLComponentInput* CCOLInterfaceComponent::getInputForIndex(unsigned short int index) {
    return inputs[index];
}