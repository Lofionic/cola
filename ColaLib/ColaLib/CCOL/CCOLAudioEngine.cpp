//
//  CCOLAudioEngine.cpp
//  ColaLib
//
//  Created by Chris on 30/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLAudioEngine.hpp"
#include "CCOLComponents.h"
#include "CCOLComponentIO.hpp"

#include <math.h>
#include <string>

// Extern wavetables used by components
SignalType ccSinWaveTable[WAVETABLE_SIZE];
SignalType ccTriWaveTable[WAVETABLE_SIZE];
SignalType ccSawWaveTable[WAVETABLE_SIZE];
SignalType ccRampWaveTable[WAVETABLE_SIZE];
SignalType ccSquareWaveTable[WAVETABLE_SIZE];

const float CCOL_AUDIO_ENGINE_MUTE_RATE = 0.02;

using namespace std;

#pragma mark render
static OSStatus renderCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    CCOLAudioEngine *audioEngine = (CCOLAudioEngine*)inRefCon;
    
    SignalType *leftBuffer;
    SignalType *rightBuffer;
    SignalType *outA;
    SignalType *outB;
    
    // Sync with iaa
    //[audioEngine updateHostBeatAndTempo];
    
    // Fill the beat buffer
    //COLTransportController *transportController = [[COLAudioEnvironment sharedEnvironment] transportController];
    //[transportController renderOutputs:inNumberFrames];
    
    // Pull the buffer chain
    CCOLComponentInput *masterL = (CCOLComponentInput*)audioEngine->getMasterInput(0);
    CCOLComponentInput *masterR = (CCOLComponentInput*)audioEngine->getMasterInput(1);
    
    leftBuffer      = masterL->getBuffer(inNumberFrames);
                                         
    // Split left channel into across both channels, if right is not connected
    if (masterR->isConnected()) {
        rightBuffer     = masterR->getBuffer(inNumberFrames);
    } else {
        rightBuffer = leftBuffer;
    }
    
    outA = (SignalType*)ioData->mBuffers[0].mData;
    outB = (SignalType*)ioData->mBuffers[1].mData;

    // Fill up the output buffer
    float attenuation = audioEngine->getAttenuation();
    for (int i = 0; i < inNumberFrames; i ++) {
        
        outA[i] = leftBuffer[i] * attenuation;
        outB[i] = rightBuffer[i] * attenuation;
        
        //TODO: handle ramped muting
        bool mute = audioEngine->isMute();
        if (mute && attenuation > 0.0) {
            float attenuationDelta = (1.0 / (audioEngine->getSampleRate() * CCOL_AUDIO_ENGINE_MUTE_RATE));
            attenuation = MAX(attenuation - attenuationDelta, 0.0);
            audioEngine->setAttenuation(attenuation);
        } else if (!mute && audioEngine->getAttenuation() < 1.0) {
            float attenuationDelta = (1.0 / (audioEngine->getSampleRate() * CCOL_AUDIO_ENGINE_MUTE_RATE));
            attenuation = MIN(attenuation + attenuationDelta, 1.0);
            audioEngine->setAttenuation(attenuation);
        }
    }
    // Render the orphans (disconnected components)
    size_t componentCount = audioEngine->getComponentCount();
    for (int i = 0; i < componentCount; i++) {
        CCOLComponent *thisComponent = audioEngine->getComponent(i);
        if (!thisComponent->hasRendered()) {
            thisComponent->renderOutputs(inNumberFrames);
            thisComponent->engineDidRender(inNumberFrames);
        }
    }
    
    masterL->engineDidRender(inNumberFrames);
    masterR->engineDidRender(inNumberFrames);
    
    return noErr;
}

static void checkError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    
    char errorString[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(errorString, "%d", (int)error);
    
    fprintf(stderr, "CCOLAudioEngine: Error: %s (%s)\n", operation, errorString);
    
    exit(1);
}

CCOLAudioEngine::CCOLAudioEngine() {

    sampleRate = 0;
    attenuation = 1.0;
    mute = false;
    
    audioContext = new CCOLAudioContext(this, 2);

    buildWaveTables();
}

void CCOLAudioEngine::initializeAUGraph(double sampleRateIn) {
    
    sampleRate = sampleRateIn;
    
    printf("CCOLAudioEngine: Creating AUGraph\n");
    checkError(NewAUGraph(&mGraph), "Cannot create new AUGraph");
    
    // Create remote IO node on graph
    AUNode remoteIONode;
    
    AudioComponentDescription outputNodeDescription;
    outputNodeDescription.componentType         = kAudioUnitType_Output;
    outputNodeDescription.componentSubType      = kAudioUnitSubType_RemoteIO;
    outputNodeDescription.componentFlags        = 0;
    outputNodeDescription.componentFlagsMask    = 0;
    outputNodeDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    checkError(AUGraphAddNode(mGraph, &outputNodeDescription, &remoteIONode), "Cannot create RemoteIO node");
    
    // Open the graph - AudioUnits are opened but not initialized
    printf("CCOLAudioEngine: Opening AUGraph");
    checkError(AUGraphOpen(mGraph), "Cannot open AUGraph");
    
    // Get a link to the RemoteIO AU
    checkError(AUGraphNodeInfo(mGraph, remoteIONode, NULL, &mRemoteIO), "Cannot get RemoteIO node info");
    
    // Set the render callback
    AURenderCallbackStruct renderCallbackStruct;
    renderCallbackStruct.inputProc = &renderCallback;
    renderCallbackStruct.inputProcRefCon = this; // Render callback context is a bridged reference to self
    
    checkError(AUGraphSetNodeInputCallback(mGraph, remoteIONode, 0, &renderCallbackStruct), "Cannot set render callback on RemoteIO node");
    
    // Set the RemoteIO stream format
    AudioStreamBasicDescription streamFormat = {0};
    
    streamFormat.mSampleRate =          sampleRate;
    streamFormat.mFormatID =            kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =         kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mFramesPerPacket =     1;
    streamFormat.mChannelsPerFrame =    2;
    streamFormat.mBitsPerChannel =      sizeof(SignalType) * 8;
    streamFormat.mBytesPerPacket =      sizeof(SignalType) * 1;
    streamFormat.mBytesPerFrame =       sizeof(SignalType) * 1;
    streamFormat.mReserved =            0;
    
    checkError(AudioUnitSetProperty(mRemoteIO, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, sizeof(streamFormat)), "Cannot set RemoteIO stream format");
    
    // Init & Start
    checkError(AUGraphInitialize (mGraph), "Error initializing AUGraph");
    checkError(AUGraphStart(mGraph), "Error starting AUGraph");
    
    // Initialize Inter-App Audio
    //TODO: Initialize inter-app audio
}

#pragma mark Component Management
// Add a component to the engine
CCOLComponentAddress CCOLAudioEngine::createComponent(char* componentType) {
    
    CCOLComponent *newComponent = nullptr;
    
    if (string(componentType) == kCCOLComponentTypeVCO) {
        newComponent = new CCOLComponentVCO(audioContext);
    } else if (string(componentType) == kCCOLComponentTypeEG) {
        newComponent = new CCOLComponentEG(audioContext);
    } else if (string(componentType) == KCCOLComponentTypeMIDI) {
        newComponent = new CCOLMIDIComponent(audioContext);
    }
    
    if (newComponent != nullptr) {
        newComponent->initializeIO();
       
        // Store this component in the components vector
        components.push_back(newComponent);

        printf("CCOLAudioEngine: Created new component : %s.\n", newComponent->getIdentifier());
        
        return (CCOLComponentAddress)newComponent;
    } else {
        return 0;
    }
}

// Remove a component from the engine
void CCOLAudioEngine::removeComponent(CCOLComponentAddress componentAddress) {
    CCOLComponent *component = (CCOLComponent*)componentAddress;
    
    // Remove from components vector
    auto it = std::find(components.begin(), components.end(), component);
    if (it != components.end()) {
        components.erase(it);
    }
    
    // Destroy the component
    component->disconnectAll();
    component->dealloc();
    free(component);
}

// Get a component's output
CCOLOutputAddress CCOLAudioEngine::getOutput(CCOLComponentAddress componentAddress, char* outputName) {
    CCOLComponent *component = (CCOLComponent*)componentAddress;
    return (CCOLOutputAddress)component->getOutputNamed(outputName);
}

// Get a component's input
CCOLInputAddress CCOLAudioEngine::getInput(CCOLComponentAddress componentAddress, char* inputName) {
    CCOLComponent *component = (CCOLComponent*)componentAddress;
    return (CCOLInputAddress)component->getInputNamed(inputName);
}

// Get a component's parameter
CCOLOutputAddress CCOLAudioEngine::getParameter(CCOLComponentAddress componentAddress, char* parameterName) {
    CCOLComponent *component = (CCOLComponent*)componentAddress;
    return (CCOLOutputAddress)component->getParameterNamed(parameterName);
}

// Connect an output to an input, return true if successful
bool CCOLAudioEngine::connect(CCOLOutputAddress outputAddress, CCOLInputAddress inputAddress) {
    CCOLComponentOutput* theOutput = (CCOLComponentOutput*)outputAddress;
    CCOLComponentInput* theInput = (CCOLComponentInput*)inputAddress;
    
    return (theOutput->connect(theInput));
}

// Disconnect an input from its output, return true if successful
bool CCOLAudioEngine::disconnect(CCOLConnectorAddress connectorAddress) {
    CCOLComponentConnector *connector = (CCOLComponentConnector*)connectorAddress;
    if (connector->getIOType() & kIOTypeInput) {
        // Connector is input
        connector->disconnect();
        return true;
    } else {
        if (connector->isConnected()) {
            connector->getConnected()->disconnect();
            return true;
        }
    }
    return false;
}

// Returns the global context master input at specified index
CCOLInputAddress CCOLAudioEngine::getMasterInput(unsigned int index) {
    return (CCOLInputAddress)audioContext->getInterfaceComponent()->getInputForIndex(index);
}

// Return ioType of a connecter
kIOType CCOLAudioEngine::getIOType(CCOLConnectorAddress connectorAddress) {
    CCOLComponentConnector *connector = (CCOLComponentConnector*)connectorAddress;
    return connector->getIOType();
}

// Geerate the wavetables
//TODO: Refactor wavetables into their own class
void CCOLAudioEngine::buildWaveTables() {
    // Sin wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        SignalType a = sin(tablePhase);
        ccSinWaveTable[i] = a;
    }
    
    // Saw wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double result = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        for (int j = 1; j <= ANALOG_HARMONICS; j++) {
            result -= (sin(tablePhase * j) / j) / 2.0;
        }
        ccSawWaveTable[i] = (SignalType)result;
    }
    
    // Ramp wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double result = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        for (int j = 1; j <= ANALOG_HARMONICS; j++) {
            result += (sin(tablePhase * j) / j) / 2.0;
        }
        ccRampWaveTable[i] = (SignalType)result;
    }
    
    // Tri wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double result = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        
        int harmonicNumber = 1;
        bool inverse = false;
        for (int j = 1; j < (ANALOG_HARMONICS * 2) + 1; j += 2) {
            
            harmonicNumber ++;
            if (inverse) {
                result -= sin(tablePhase * j) / powf(((j) + 1), 2) / 0.5f;
                inverse = false;
            } else {
                result += sin(tablePhase * j) / powf(((j) + 1), 2) / 0.5f;
                inverse = true;
            }
        }
        
        ccTriWaveTable[i] = result;
    }
    
    // Square wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double result = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        for (int j = 1; j < (ANALOG_HARMONICS * 2) + 1;j += 2) {
            result += sin(tablePhase * j) / j;
        }
        ccSquareWaveTable[i] = result;
    }
}
