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
    
    for (int i = 0; i < len; ++i) {
        s[i] = alphanum[rand() % (sizeof(alphanum) - 1)];
    }
    
    s[len] = 0;
}

CCOLComponent::CCOLComponent(CCOLAudioContext* contextIn) {
    context = contextIn;
    componentIdentifier = new char[12];
    gen_random(componentIdentifier, 10);
    
    rendered = false;
    
    inputs =        vector<CCOLComponentInput*> { };
    outputs =       vector<CCOLComponentOutput*> { };
    parameters =    vector<CCOLComponentParameter*> { };
}


void CCOLComponent::renderOutputs(unsigned int numFrames) {
    rendered = true;
}

bool CCOLComponent::hasRendered() {
    return rendered;
}

// Called once the engine has rendered an entire buffer
void CCOLComponent::engineDidRender(unsigned int numFrames) {
    rendered = false;
    
    for (auto &i : inputs) {
        ((CCOLComponentInput*)i)->engineDidRender(numFrames);
    }
    
    for (auto &p : parameters) {
        ((CCOLComponentParameter*)p)->engineDidRender();
    }
}

void CCOLComponent::disconnectAll() {
    for (CCOLComponentOutput* &o : outputs) {
        if (o->isConnected()) {
            o->getConnected()->disconnect();
        }
    }
    
    for (CCOLComponentInput* &i : inputs) {
        if (i->isConnected()) {
            i->disconnect();
        }
    }
}

CCOLComponentOutput *CCOLComponent::getOutputNamed(char *name) {
    CCOLComponentOutput *result = NULL;
    for (CCOLComponentOutput* &o : outputs) {
        if (std::string(o->getName()) == std::string(name)) {
            result = o;
        }
    }
    return result;
}

CCOLComponentInput *CCOLComponent::getInputNamed(char *name) {
    CCOLComponentInput *result = NULL;
    for (CCOLComponentInput* &i : inputs) {
        if (std::string(i->getName()) == std::string(name)) {
            result = i;
        }
    }
    
    return result;
}

CCOLComponentParameter* CCOLComponent::getParameterNamed(char *name) {
    CCOLComponentParameter *result = NULL;
    for (CCOLComponentParameter* &p : parameters) {
        if (std::string(p->getName()) == std::string(name)) {
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