//
//  CCOLAudioEngine.cpp
//  ColaLib
//
//  Created by Chris on 30/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLAudioEngine.hpp"
#include "CCOLAudioContext.hpp"
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
    CCOLComponentInput *masterL = audioEngine->getMasterL();
    CCOLComponentInput *masterR = audioEngine->getMasterR();
    
    leftBuffer      = masterL->getBuffer(inNumberFrames);
    rightBuffer     = masterR->getBuffer(inNumberFrames);

    // Split left channel into across both channels, if right is not connected
    if (!masterR->isConnected()) {
        rightBuffer = leftBuffer;
    }
    
    outA = (SignalType*)ioData->mBuffers[0].mData;
    outB = (SignalType*)ioData->mBuffers[1].mData;
    //
    //        // Cherry Cola stuff
    //        leftBuffer =    audioEngine->masterInL->getBuffer(inNumberFrames);
    //        rightBuffer =   audioEngine->masterInR->getBuffer(inNumberFrames);
    //
    // Fill up the output buffer
    float attenuation = audioEngine->getAttentuation();
    for (int i = 0; i < inNumberFrames; i ++) {
        
        outA[i] = leftBuffer[i] * attenuation;
        outB[i] = rightBuffer[i] * attenuation;
        
        //TODO: handle ramped muting
//        if (audioEngine.isMuting && .attenuation > 0.0) {
//            Float32 attenuationDelta = 2.0 / [[COLAudioEnvironment sharedEnvironment] sampleRate];
//            Float32 newAttenuation = MAX(audioEngine.attenuation -= attenuationDelta, 0.0);
//            [audioEngine setAttenuation:newAttenuation];
//        } else if (!audioEngine.isMuting && audioEngine.attenuation < 1.0) {
//            Float32 attenuationDelta = 2.0 / [[COLAudioEnvironment sharedEnvironment] sampleRate];
//            Float32 newAttenuation = MIN(audioEngine.attenuation += attenuationDelta, 1.0);
//            [audioEngine setAttenuation:newAttenuation];
//        }
    }

    masterL->engineDidRender();
    masterR->engineDidRender();
    
    return noErr;
}

static void checkError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    char errorString[20];
    
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString); exit(1);
}

void CCOLAudioEngine::init() {
    
    masterL = CCOLAudioContext::globalContext()->getMasterInput(0);
    masterR = CCOLAudioContext::globalContext()->getMasterInput(1);
 
    buildWaveTables();
}

void CCOLAudioEngine::initializeAUGraph() {
    printf("Creating AUGraph\n");
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
    printf("Opening AUGraph");
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

    // Testing
//    CCOLComponentVCO *vco = new CCOLComponentVCO();
//    vco->initializeIO();
//    
//    CCOLComponentOutput *vcoOut = vco->getOutputForIndex(0);
//    vcoOut->connect(masterL);
//    
//    masterL->disconnect();
//    
//    vcoOut->connect(masterL);
}

#pragma mark Component Management
CCOLComponentAddress CCOLAudioEngine::createComponent(char* componentType) {
    
    CCOLComponent *newComponent = nullptr;
    CCOLAudioContext *context = CCOLAudioContext::globalContext();
    
    if (std::string(componentType) == kCCOLComponentTypeVCO) {
        newComponent = new CCOLComponentVCO(context);
    }
    
    if (newComponent != nullptr) {
        newComponent->initializeIO();
        return (CCOLComponentAddress)newComponent;
    } else {
        return 0;
    }
}

CCOLOutputAddress CCOLAudioEngine::getOutput(CCOLComponentAddress componentAddress, char* outputName) {
    CCOLComponent *component = (CCOLComponent*)componentAddress;
    return (CCOLOutputAddress)component->getOutputNamed(outputName);
}

CCOLInputAddress CCOLAudioEngine::getInput(CCOLComponentAddress componentAddress, char* inputName) {
    CCOLComponent *component = (CCOLComponent*)componentAddress;
    return (CCOLInputAddress)component->getInputNamed(inputName);
}

CCOLOutputAddress CCOLAudioEngine::getParameter(CCOLComponentAddress componentAddress, char* parameterName) {
    CCOLComponent *component = (CCOLComponent*)componentAddress;
    return (CCOLOutputAddress)component->getParameterNamed(parameterName);
}

bool CCOLAudioEngine::connect(CCOLOutputAddress outputAddress, CCOLInputAddress inputAddress) {
    CCOLComponentOutput* theOutput = (CCOLComponentOutput*)outputAddress;
    CCOLComponentInput* theInput = (CCOLComponentInput*)inputAddress;
    
    return (theOutput->connect(theInput));
}

bool CCOLAudioEngine::disconnect(CCOLInputAddress inputAddress) {
    CCOLComponentInput* theInput = (CCOLComponentInput*)inputAddress;
    return (theInput->disconnect());
}

CCOLInputAddress CCOLAudioEngine::getMasterInput(unsigned int index) {
    CCOLAudioContext* context = CCOLAudioContext::globalContext();
    return (CCOLInputAddress)context->getMasterInput(0);
}

kIOType CCOLAudioEngine::getIOType(CCOLComponentAddress connectorAddress) {
    CCOLComponentConnector *connector = (CCOLComponentConnector*)connectorAddress;
    return connector->getIOType();
}

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
