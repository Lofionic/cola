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
#include <stdlib.h>
#include <string>

void gen_random(char *s, const int len) {
    static const char alphanum[] =
    "0123456789"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "abcdefghijklmnopqrstuvwxyz";
    
    int j = 0;
    for (int i = 0; i < len; ++i) {
        if (i > 0 && i % 5 == 0) {
            s[j++] = '-';
        }
        s[j++] = alphanum[rand() % (sizeof(alphanum) - 1)];
    }
    
    s[j] = 0;
}

CCOLComponent::CCOLComponent(CCOLAudioContext* contextIn) {
    context = contextIn;
    componentIdentifier = new char[12];
    gen_random(componentIdentifier, 10);
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

CCOLComponentInput *CCOLComponent::getInputNamed(char *name) {
    CCOLComponentInput *result = NULL;
    
    for (auto &i : inputs) {
        if (std::string(((CCOLComponentInput*)i)->getName()) == std::string(name)) {
            result = i;
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

// Dealloc all members ready for release
void CCOLComponent::dealloc() {
    
    // Free inputs
    for (auto &i : inputs) {
        free (i);
    }
    
    // Free outputs
    for (auto &o : outputs) {
        free (o);
    }
    
    // Free parameters
    for (auto &p : parameters) {
        free (p);
    }
    
    free (componentIdentifier);
}

// Returns the default name for this component
const char* CCOLComponent::getDefaultName() {
    return "Component";
}


