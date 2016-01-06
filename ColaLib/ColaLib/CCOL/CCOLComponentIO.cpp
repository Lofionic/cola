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

CCOLComponentConnector::CCOLComponentConnector(CCOLComponent *componentIn, kIOType ioTypeIn, const char *nameIn) {
    component = componentIn;
    ioType = ioTypeIn;
    strcpy(name, nameIn);

    connectedTo = nullptr;
}

// Called when the engine has finished rendering the buffer
void CCOLComponentConnector::engineDidRender(unsigned int numFrames) {
    if (connectedTo != nullptr) {
        connectedTo->engineDidRender(numFrames);
    }
}

bool CCOLComponentConnector::isConnected() {
    return connectedTo != nullptr;
}

bool CCOLComponentConnector::disconnect() {
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

bool CCOLComponentConnector::isDynamic() {
    return (ioType & kIOTypeDynamic) > 0;
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
        emptyBuffer = (SignalType*)malloc(emptyBufferSize * sizeof(SignalType));
        memset(emptyBuffer, 0, emptyBufferSize * sizeof(SignalType));
    }
    
    return emptyBuffer;
}

// Notify the connected output that the engine has rendered
void CCOLComponentInput::engineDidRender(unsigned int numFrames) {
    if (isConnected()) {
        getConnected()->engineDidRender(numFrames);
    }
}

// Disconnect from the output
bool CCOLComponentInput::disconnect() {
    if (isConnected()) {
        getConnected()->disconnect();
        setConnected(nullptr);
        printf("%s|%s disconnected.\n", getComponent()->getIdentifier(), getName());
        return true;
    } else {
        printf("%s|%s cannot disconnect.\n", getComponent()->getIdentifier(), getName());
        return false;
    }
}

// Make a dynamic connection from dynamic input to output
bool CCOLComponentInput::makeDynamicConnection(CCOLComponentOutput *outputIn) {
    if (isDynamic()) {
        kIOType dynamicType = (kIOType)(outputIn->getIOType() & ~(1 << 1));
        
        // Check the linked outputs are of the direct type
        unsigned long int numOutputs = component->getNumberOfOutputs();
        CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
        for (int i = 0; i < numOutputs; ++i) {
            CCOLComponentOutput *thisOutput = component->getOutputForIndex(i);
            if (thisOutput->isDynamic() &&
                thisOutput->isConnected() &&
                thisOutput->getLinkedInput() == this &&
                !(dynamicType & thisOutput->getIOType())) {
                
                // Force dynamic disconnect and post a notification
                thisOutput->getConnected()->disconnect();
                CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL};
                CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
                CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1,
                                                                              &keyCallbacks, &valueCallbacks);
                //CFDictionaryAddValue(dictionary, CFSTR("output"), (CCOLOutputAddress)thisOutput);
                CFDictionarySetValue(dictionary, CFSTR("output"), thisOutput);
                
                CFNotificationCenterPostNotification(center, kCCOLEngineDidForceDisconnectNotification, NULL, dictionary, true);
                
                CFRelease(dictionary);
            }
        }
    }
    return false;
}

// Return a bitmask of ioType
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
// Get the buffer of this output
SignalType* CCOLComponentOutput::getBuffer(unsigned int numFrames) {
    // If the component hasn't rendered, now's the time to do it.
    if (!component->hasRendered()) {
        component->renderOutputs(numFrames);
    }
    
    return buffer;
}

// Prepare the output's buffer for writing
SignalType* CCOLComponentOutput::prepareBufferOfSize(unsigned int numFrames) {
    // Create or resize the buffer
    if (numFrames != bufferSize) {
        if (bufferSize != 0) {
            free(buffer);
        }
        bufferSize = numFrames;
        buffer = (SignalType*)malloc(bufferSize * sizeof(SignalType));
        memset(buffer, 0, bufferSize * sizeof(SignalType));
    }
    
    return buffer;
}

// Called when the engine has finished rendering the buffer
void CCOLComponentOutput::engineDidRender(unsigned int numFrames){
    if (component->hasRendered()) {
        component->engineDidRender(numFrames);
    }
}

// Connect this output to an input
bool CCOLComponentOutput::connect(CCOLComponentInput *inputIn) {
//TODO: Validate connection context
    if (getComponent()->getContext() != inputIn->getComponent()->getContext()) {
        printf("Connection failed: Input and Output components must exist in the same context.\n");
    }
    
    if (inputIn->isDynamic()) {
        // Connect to dynamic input
        inputIn->makeDynamicConnection(this);
    } else {
       if (isDynamic()) {
            // This is a dynamic output
            if (linkedInput != nullptr) {
                kIOType linkedType = (kIOType)(linkedInput->getIOType() & ~(1 << 2)); // remove kIOTypeOutput from bitmask
                if (linkedType != inputIn->getIOType()) {
                    printf("Dynamic connection failed : dynamic output's linked input does not match input type.\n");
                    return false;
                }
            } else {
                printf("Dynamic connection failed : Attempted to connect dynamic output with no linked input.\n");
                return false;
            }
        } else {
            kIOType connectionType = (kIOType)(getIOType() & ~(1 << 1)); // remove kIOTypeOutput from bitmask
            if (!(inputIn->getIOType() & connectionType)) {
                printf("Connection failed : Output and input types must match.\n");
                return false;
            }
            
            if (inputIn->getComponent() == component) {
                printf("Connection failed : Component cannot connect to self.\n");
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
    
    printf("Connected : %s|%s -> %s|%s.\n", getComponent()->getIdentifier(), getName(), inputIn->getComponent()->getIdentifier(), inputIn->getName());
    return true;
}

bool CCOLComponentOutput::disconnect() {
    if (isConnected()) {
        setConnected(nullptr);
        memset(buffer, 0, bufferSize * sizeof(SignalType*)); // Empty the buffer
        printf("%s|%s disconnected.\n", getComponent()->getIdentifier(), getName());
        return true;
    } else {
        printf("%s|%s cannot disconnect.\n", getComponent()->getIdentifier(), getName());
        return false;
    }
}

kIOType CCOLComponentOutput::getIOType() {
    return (kIOType)(ioType | kIOTypeOutput);
}

