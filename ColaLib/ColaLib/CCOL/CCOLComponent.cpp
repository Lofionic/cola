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
#include <sstream>

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

void CCOLComponent::setIdentifier(char* inIdentifier) {
    strcpy(componentIdentifier, inIdentifier);
}

// Returns a CFDictionary describing the state of this component for recall.
CFDictionaryRef CCOLComponent::getDictionary() {
    
    CFStringRef keys[4];
    CFTypeRef values[4];
    
    // Create the properties dict
    keys[0] = kCCOLComponentIdentifierKey;
    values[0] = CFStringCreateWithCString(NULL, getIdentifier(), kCFStringEncodingUTF8);

    keys[1] = kCCOLComponentTypeKey;
    values[1] = CFStringCreateWithCString(NULL, getComponentType(), kCFStringEncodingUTF8);

    // Create the parameters dict
    keys[2] = kCCOLComponentParametersKey;
    uint parameterCount = parameters.size();
    CFStringRef parameterNames[parameterCount];
    CFStringRef parameterValues[parameterCount];
    
    int i = 0;
    
    // Create a number formatter for parameter values.
    CFLocaleRef locale = CFLocaleCopyCurrent();
    CFNumberFormatterRef numberFormatter = CFNumberFormatterCreate(NULL, locale, kCFNumberFormatterDecimalStyle);
    int fractionDigits = 6;
    CFNumberRef maxFractionDigits = CFNumberCreate(NULL, kCFNumberIntType, &fractionDigits);
    CFNumberFormatterSetProperty(numberFormatter, kCFNumberFormatterMaxFractionDigits, maxFractionDigits);
    
    for(auto const& parameter: parameters) {
        parameterNames[i] = CFStringCreateWithCString(NULL, parameter->getName(), kCFStringEncodingUTF8);
        float floatValue = parameter->getNormalizedValue();
        CFNumberRef number = CFNumberCreate(NULL, kCFNumberFloatType, &floatValue);
        parameterValues[i++] =  CFNumberFormatterCreateStringWithNumber(NULL, numberFormatter, number);
        CFRelease(number);
    }
    CFRelease(locale);
    CFRelease(numberFormatter);
    CFRelease(maxFractionDigits);
  
    values[2] = CFDictionaryCreate(NULL, (const void **)parameterNames, (const void **)parameterValues, parameterCount, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    
    // Create the outputs dict
    keys[3] = kCCOLComponentConnectionsKey;
    
    uint outputCount = outputs.size();
    CFDictionaryRef connections[outputCount];
    
    i = 0;
    for(auto const& output: outputs) {
        if (output->isConnected()) {
            CFStringRef connectionKeys[] { kCCOLConnectionOutputKey, kCCOLConnectionComponentKey, kCCOLConnectionInputKey };
            CFStringRef connectionValues[] {
                CFStringCreateWithCString(NULL, output->getName(), kCFStringEncodingUTF8),
                CFStringCreateWithCString(NULL, output->getConnected()->getComponent()->getIdentifier(), kCFStringEncodingUTF8),
                CFStringCreateWithCString(NULL, output->getConnected()->getName(), kCFStringEncodingUTF8)
            };
            connections[i++] = CFDictionaryCreate(NULL, (const void**)connectionKeys, (const void**)connectionValues, 3, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        }
    }
    
    values[3] = CFArrayCreate(NULL, (const void**)connections, i, &kCFTypeArrayCallBacks);
   
    CFDictionaryRef result =  CFDictionaryCreate(NULL, (const void **)keys, (const void **)values, 4, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
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