//
//  CCOLComponent.cpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponent.hpp"
#include <string>

void CCOLComponent::init(CCOLAudioContext* contextIn) {
    context = contextIn;
    initializeIO();
}

void CCOLComponent::assignUniqueName() {
    unsigned int    componentCount = 0;
    const char*     name;
    
    bool uniqueName = false;
    while (!uniqueName) {
        componentCount++;
        string thisName = getDefaultName() + to_string(componentCount);
        name = thisName.c_str();
        uniqueName = true;
    }
}

void CCOLComponent::renderOutputs(unsigned int numFrames) {
    rendered = true;
}

bool CCOLComponent::hasRendered() {
    return rendered;
}

void CCOLComponent::engineDidRender() {
    rendered = false;
    
    for (auto &i : inputs) {
        ((CCOLComponentInput*)i)->engineDidRender();
    }
    
    //TODO: Send engine did render to parameters.
}

void CCOLComponent::disconnectAll() {
    for (auto &o : outputs) {
        ((CCOLComponentOutput*)o)->engineDidRender();
    }
    
    for (auto &i : inputs) {
        ((CCOLComponentInput*)i)->engineDidRender();
    }
}

const char* CCOLComponent::getDefaultName() {
    return "Component";
}


