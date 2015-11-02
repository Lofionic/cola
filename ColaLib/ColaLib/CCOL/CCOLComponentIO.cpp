//
//  CCOLComponentIO.cpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//
#include <CoreFoundation/CoreFoundation.h>
#include "CCOLComponentIO.hpp"
#include "CCOLComponent.hpp"

#include <stdlib.h>

static SignalType*     emptyBuffer;
static unsigned int    emptyBufferSize;

CCOLComponentConnector::CCOLComponentConnector(CCOLComponent *componentIn, kIOType ioTypeIn, char* nameIn) {
    component = componentIn;
    ioType = ioTypeIn;
    name = nameIn;

    connectedTo = nullptr;
}

void CCOLComponentConnector::engineDidRender() {
    if (connectedTo != nullptr) {
        connectedTo->engineDidRender();
    }
}

bool CCOLComponentConnector::isConnected() {
    return connectedTo != nullptr;
}

bool CCOLComponentConnector::disconnect() {
    return false;
}

bool CCOLComponentConnector::isDynamic() {
    return false;
}

kIOType CCOLComponentConnector::getIOType() {
    return ioType;
}

CCOLComponent* CCOLComponentConnector::getComponent() {
    return component;
}

void CCOLComponentConnector::setConnected(CCOLComponentConnector *connectedIn) {
    connectedTo = connectedIn;
}

CCOLComponentConnector* CCOLComponentConnector::getConnected() {
    return connectedTo;
}

#pragma mark CCOLComponentInput

// Request the buffer for this output
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

// Return an empty buffer, used when the input is not connected to an output
SignalType* CCOLComponentInput::getEmptyBuffer(unsigned int numFrames) {
    if (numFrames != emptyBufferSize) {
        free(emptyBuffer);
        emptyBufferSize = numFrames;
        emptyBuffer = (SignalType*)malloc(emptyBufferSize * sizeof(SignalType*));
        memset(emptyBuffer, 0, emptyBufferSize * sizeof(SignalType*));
    }
    
    return emptyBuffer;
}

// Notify the connected output that the engine has rendered
void CCOLComponentInput::engineDidRender() {
    if (isConnected()) {
        getConnected()->engineDidRender();
    }
}

// Disconnect from the output
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
        kIOType connectionIOType = (kIOType)(outputIn->getIOType() & ~(1 << 1));
        if (ioType & connectionIOType) {
            // Check the linked outputs are of the direct type
            unsigned long int numOutputs = component->getNumberOfOutputs();
            CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
            for (int i = 0; i < numOutputs; ++i) {
                CCOLComponentOutput *thisOutput = component->getOutputForIndex(i);
                if (thisOutput->isDynamic() &&
                    thisOutput->isConnected() &&
                    thisOutput->getLinkedInput() == this &&
                    !(ioType & thisOutput->getIOType()) &&
                    !thisOutput->getConnected()->isDynamic()) {
                    
                    // Force dynamic disconnect and post a notification
                    thisOutput->getConnected()->disconnect();
                    CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL};
                    CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
                    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 2,
                                                                                  &keyCallbacks, &valueCallbacks);
                    CFDictionaryAddValue(dictionary, CFSTR("input"), this);
                    CFDictionaryAddValue(dictionary, CFSTR("output"), thisOutput);

                    CFNotificationCenterPostNotification(center, CFSTR("DynamicDisconnectNotification"), NULL, dictionary, false);
                }
            }
        }
    }
    
    return false;
}

bool CCOLComponentInput::isDynamic() {
    return ioType == kIOTypeDynamic;
}

kIOType CCOLComponentInput::getIOType() {
    if ((ioType & kIOTypeDynamic) > 0 && isConnected()) {
        // Dynamic type
        kIOType linkedType = connectedTo->getIOType();
        int ra = linkedType & ~(1 << 1); // remove kIOTypeOutput from bitmask
        return (kIOType)(ra | kIOTypeInput);
    } else {
        return (kIOType)(ioType | kIOTypeInput);
    }
}


#pragma mark CCOLComponentOutput
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
        if (bufferSize != 0) {
            free(buffer);
        }
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
        kIOType connectionType = (kIOType)(getIOType() & ~(1 << 1)); // remove kIOTypeOutput from bitmask
        if (isDynamic()) {
            
            // This is a dynamic output
            if (linkedInput != nullptr) {
                if (!(linkedInput->getIOType() & connectionType) || !(inputIn->getIOType() & connectionType)) {
                    printf("Dynamic connection failed : dynamic output's linked input does not match input type\n");
                    return false;
                }
            } else {
                printf("Dynamic connection failed : Attempted to connect dynamic output with no linked input");
                return false;
            }
        } else {
            if (!(inputIn->getIOType() & connectionType)) {
                printf("Connection failed : Output and input types must match");
                return false;
            }
            
            if (inputIn->getComponent() == component) {
                printf("Connection failed : Component cannot connect to self");
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

kIOType CCOLComponentOutput::getIOType() {
    return (kIOType)(ioType | kIOTypeOutput);
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


