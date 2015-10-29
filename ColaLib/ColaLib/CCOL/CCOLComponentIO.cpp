//
//  CCOLComponentIO.cpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponentIO.hpp"
#include <stdlib.h>
#include <string.h>
#include "CCOLComponent.hpp"

static SignalType*     emptyBuffer;
static unsigned int    emptyBufferSize;

void CCOLComponentIO::init(CCOLComponent *inComponent, kIOType inType, char* inName) {
    component   = inComponent;
    ioType      = inType;
    name        = inName;
    
    connectedTo = nullptr;
}

void CCOLComponentIO::engineDidRender() {
    if (connectedTo != nullptr) {
        connectedTo->engineDidRender();
    }
}

bool CCOLComponentIO::isConnected() {
    return connectedTo != nullptr;
}

bool CCOLComponentIO::disconnect() {
    return false;
}

bool CCOLComponentIO::isDynamic() {
    return false;
}

kIOType CCOLComponentIO::getIOType() {
    return ioType;
}

CCOLComponent* CCOLComponentIO::getComponent() {
    return component;
}

void CCOLComponentIO::setConnected(CCOLComponentIO *connectedIn) {
    connectedTo = connectedIn;
}

CCOLComponentIO* CCOLComponentIO::getConnected() {
    return connectedTo;
}

#pragma mark CCOLComponentInput
SignalType* CCOLComponentInput::getBuffer(unsigned int numFrames) {
    if (isConnected()) {
        SignalType *buffer = ((CCOLComponentOutput*)connectedTo)->getBuffer(numFrames);
        if (buffer != nullptr) {
            return buffer;
        } else {
            return getEmptyBuffer(numFrames);
        }
    } else {
        // No connection - no signal. Return an empty buffer.
        return getEmptyBuffer(numFrames);
    }
}

SignalType* CCOLComponentInput::getEmptyBuffer(unsigned int numFrames) {
    if (numFrames != emptyBufferSize) {
        free(emptyBuffer);
        emptyBufferSize = numFrames;
        emptyBuffer = (SignalType*)malloc(emptyBufferSize * sizeof(SignalType*));
        memset(emptyBuffer, 0, emptyBufferSize * sizeof(SignalType*));
    }
    
    return emptyBuffer;
}

void CCOLComponentInput::engineDidRender() {
    if (isConnected()) {
        getConnected()->engineDidRender();
    }
}

bool CCOLComponentInput::disconnect() {
    if (isConnected()) {
        setConnected(nullptr);
        return true;
    } else {
        return false;
    }
}

bool CCOLComponentInput::makeDynamicConnection(CCOLComponentOutput *outputIn) {
    if (isDynamic()) {
        if (ioType == outputIn->getIOType()) {
//TODO: Handle dynamic connections
        }
    }
    
    return false;
}

bool CCOLComponentInput::isDynamic() {
    return ioType == kIOTypeDynamic;
}

kIOType CCOLComponentInput::getIOType() {
    if (ioType != kIOTypeDynamic || !isConnected()) {
        return ioType;
    } else {
        return connectedTo->getIOType();
    }
}

#pragma mark CCOLComponentOutput
void CCOLComponentOutput::init(CCOLComponent *inComponent, kIOType inType, char* inName) {
    linkedInput = nullptr;
    CCOLComponentIO::init(inComponent, inType, inName);
}

SignalType* CCOLComponentOutput::getBuffer(unsigned int numFrames) {
    // If the component hasn't rendered, now's the time to do it.
    if (!component->hasRendered()) {
        component->renderOutputs(numFrames);
    }
    
    return buffer;
}

SignalType* CCOLComponentOutput::prepareBufferOfSize(unsigned int numFrames) {
    // Create or resize the buffer
    if (numFrames != bufferSize) {
        free(buffer);
        bufferSize = numFrames;
        buffer = (SignalType*)malloc(bufferSize * sizeof(SignalType*));
        memset(buffer, 0, bufferSize * sizeof(SignalType*));
    }
    
    return buffer;
}

void CCOLComponentOutput::engineDidRender() {
    if (component->hasRendered()) {
        component->engineDidRender();
    }
}

bool CCOLComponentOutput::connect(CCOLComponentInput *inputIn) {
//TODO: Validate connection context
    
    if (inputIn->isDynamic()) {
        // Connect to dynamic input
        inputIn->makeDynamicConnection(this);
    } else {
        if (isDynamic()) {
            // This is a dynamic output
            if (linkedInput != nullptr) {
                if (linkedInput->getIOType() != inputIn->getIOType()) {
                    printf("Dynamic connection failed : dynamic output's linked input does not match input type\n");
                    return false;
                }
            } else {
                printf("Dynamic connection failed : Attempted to connect dynamic output with no linked input");
                return false;
            }
        } else {
            if (inputIn->getIOType() != ioType) {
                printf("Dynamic connection failed : Output and input types must match");
                return false;
            }
            
            if (inputIn->getComponent() == component) {
                printf("Dynamic connection failed : Component cannot connect to self");
                return false;
            }
        }
    }
    
    if (isConnected()) {
        connectedTo->disconnect();
        disconnect();
    }
    
    if (inputIn->isConnected()) {
        inputIn->getConnected()->disconnect();
    }
    
    connectedTo = inputIn;
    inputIn->setConnected(this);
    
    return true;
}

bool CCOLComponentOutput::disconnect() {
    if (isConnected()) {
        getConnected()->disconnect();
        setConnected(nullptr);
        return true;
    } else {
        return false;
    }
}


