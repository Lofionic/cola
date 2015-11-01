//
//  CCOLComponent.cpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponent.hpp"

#include "CCOLAudioContext.hpp"
#include "CCOLComponentIO.hpp"
#include "CCOLComponentParameter.hpp"

#include <string>

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
    
    for (auto &p : parameters) {
        ((CCOLComponentParameter*)p)->engineDidRender();
    }
}

void CCOLComponent::disconnectAll() {
    for (auto &o : outputs) {
        ((CCOLComponentOutput*)o)->engineDidRender();
    }
    
    for (auto &i : inputs) {
        ((CCOLComponentInput*)i)->engineDidRender();
    }
}

CCOLComponentOutput *CCOLComponent::getOutputNamed(char *name) {
    CCOLComponentOutput *result = NULL;
    
    for (auto &o : outputs) {
        if (std::string(((CCOLComponentOutput*)o)->getName()) == std::string(name)) {
            result = o;
        }
    }
    
    return result;
}

CCOLComponentParameter* CCOLComponent::getParameterNamed(char *name) {
    CCOLComponentParameter *result = NULL;
    
    for (auto &p : parameters) {
        if (std::string(((CCOLComponentParameter*)p)->getName()) == std::string(name)) {
            result = p;
        }
    }
    
    return result;
}

const char* CCOLComponent::getDefaultName() {
    return "Component";
}


