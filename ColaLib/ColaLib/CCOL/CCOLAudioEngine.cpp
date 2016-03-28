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
#include "CCOLTransportController.hpp"
#include "CCOLMIDIComponent.hpp"
#include "CCOLIAAController.hpp"
#include "CCOLUtility.hpp"

#include <math.h>
#include <string>
#include <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>

// Extern wavetables used by components
SignalType ccSinWaveTable[WAVETABLE_SIZE];
SignalType ccTriWaveTable[WAVETABLE_SIZE];
SignalType ccSawWaveTable[WAVETABLE_SIZE];
SignalType ccRampWaveTable[WAVETABLE_SIZE];
SignalType ccSquareWaveTable[WAVETABLE_SIZE];

const float CCOL_AUDIO_ENGINE_MUTE_RATE = 0.02;

using namespace std;

#pragma mark App State
void appDidEnterBackgroundNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)  {
    CCOLAudioEngine *engine = (CCOLAudioEngine*)observer;
    engine->appDidEnterBackground();
}

void appWillEnterForegroundNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)  {
    CCOLAudioEngine *engine = (CCOLAudioEngine*)observer;
    engine->appWillEnterForeground();
}

void appWillTerminateNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)  {
    CCOLAudioEngine *engine = (CCOLAudioEngine*)observer;
    engine->appWillTerminate();
}

void mediaServicesWereResetNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)  {
    CCOLAudioEngine *engine = (CCOLAudioEngine*)observer;
    engine->mediaServicesWereReset();
}

void iaaConnectedStateDidChangeNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)  {
    // When IAA connects or disconnects, we amy need to start or stop the AUGraph.
    CCOLAudioEngine *engine = (CCOLAudioEngine*)observer;
    engine->startStop();
}

void iaaTransportStateDidChangeNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)  {
    // When IAA transport state changed, we need to update the engine's transport controller.
    CCOLAudioEngine *engine = (CCOLAudioEngine*)observer;
    engine->getTransportController()->interappAudioTransportStateDidChange((CCOLIAAController *)object);
}

#pragma mark render
static OSStatus renderCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    CCOLAudioEngine *audioEngine = (CCOLAudioEngine*)inRefCon;
    
    SignalType *leftBuffer;
    SignalType *rightBuffer;
    SignalType *outA;
    SignalType *outB;
    
    // Sync with iaa
    audioEngine->getIAAController()->updateHostBeatAndTempo();
    
    // Fill the beat buffer
    audioEngine->getTransportController()->renderOutputs(inNumberFrames, audioEngine->getSampleRate());

    // Pull the buffer chain
    CCOLComponentInput *masterL = (CCOLComponentInput*)audioEngine->getMasterInput(0);
    CCOLComponentInput *masterR = (CCOLComponentInput*)audioEngine->getMasterInput(1);
    
    leftBuffer      = masterL->getBuffer(inNumberFrames);
                                         
    // Split left channel into across both channels, if right is not connected
    if (masterR->isConnected()) {
        rightBuffer = masterR->getBuffer(inNumberFrames);
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
        }
    }
    
    for (int i = 0; i < componentCount; i++) {
        CCOLComponent *thisComponent = audioEngine->getComponent(i);
        if (!thisComponent->hasRendered()) {
            thisComponent->engineDidRender(inNumberFrames);
        }
    }
    
    masterL->engineDidRender(inNumberFrames);
    masterR->engineDidRender(inNumberFrames);
    
    audioEngine->doPending();
    
    return noErr;
}

void CCOLAudioEngine::doPending() {
    while (pendingDisconnects.size() > 0) {
        CCOLComponentConnector *disconnectConnector = pendingDisconnects.back();
        disconnectConnector->disconnect();
        pendingDisconnects.pop_back();
        
    }
}

CCOLAudioEngine::CCOLAudioEngine() {
    sampleRate = 0; // Will be set when graph is initialized.
    attenuation = 1.0;
    mute = false;
   
    // The generic audio context with two master outputs.
    audioContext = new CCOLAudioContext(this, 2);

    buildWaveTables();

    transportController = new CCOLTransportController(&iaaController);
    
    // Manage all MIDI In & Out
    midiComponent = new CCOLMIDIComponent(audioContext);
    midiComponent->initializeIO();
}

void CCOLAudioEngine::initializeAUGraph(bool isForegroundIn) {
    
    isForeground = isForegroundIn;
    
    sampleRate = AVAudioSession.sharedInstance.sampleRate;
    printf("CCOLAudioEngine: Sample rate %.fHz.\n", sampleRate);
    
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
    printf("CCOLAudioEngine: Opening AUGraph\n");
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
    
    // Register observers
    CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
    
    CFNotificationCenterAddObserver(center,
                                    this,
                                    &appDidEnterBackgroundNotification,
                                    (__bridge CFStringRef)UIApplicationDidEnterBackgroundNotification,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    CFNotificationCenterAddObserver(center,
                                    this,
                                    &appWillEnterForegroundNotification,
                                    (__bridge CFStringRef)UIApplicationWillEnterForegroundNotification,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    CFNotificationCenterAddObserver(center,
                                    this,
                                    &appWillTerminateNotification,
                                    (__bridge CFStringRef)UIApplicationWillTerminateNotification,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    CFNotificationCenterAddObserver(center,
                                    this,
                                    &mediaServicesWereResetNotification,
                                    (__bridge CFStringRef)AVAudioSessionMediaServicesWereResetNotification,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    CFNotificationCenterAddObserver(center,
                                    this,
                                    &iaaTransportStateDidChangeNotification,
                                    kCCOLIAAControllerTransportStateDidChange,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    CFNotificationCenterAddObserver(center,
                                    this,
                                    &iaaConnectedStateDidChangeNotification,
                                    kCCOLIAAControllerConnectedStateDidChange,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

CCOLAudioEngine::~CCOLAudioEngine() {
    CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetLocalCenter(), this);
}

void CCOLAudioEngine::initializeIAA(CFStringRef componentNameIn, OSType manufacturerCodeIn) {
    iaaController.publishIAA(&mRemoteIO, componentNameIn, manufacturerCodeIn);
    setupMIDICallbacks();
}

void CCOLAudioEngine::startStop() {
    // Start or stop the engine depending on state
    printf("CCOLAudioEngine: Start/stop.\n");

    if (isForeground || iaaController.isHostConnected()) {
        printf("CCOLAudioEngine: App is foreground or IAA connected.\n");
        startGraph();
    } else {
        printf("CCOLAudioEngine: App is background, IAA disconnected.\n");
        stopGraph();
    }
}

void CCOLAudioEngine::startGraph() {
    
    if (mGraph != nullptr) {
        Boolean initialized = true;
        checkError(AUGraphIsInitialized(mGraph, &initialized), "Error checking initializing of AUGraph");
        if (!initialized) {
            printf("CCOLAudioEngine: Initializing AUGraph.\n");
            checkError(AUGraphInitialize (mGraph), "Error initializing AUGraph");
        }
        
        Boolean isRunning = false;
        AUGraphIsRunning(mGraph, &isRunning);
        
        if (!isRunning) {
            printf("CCOLAudioEngine: Starting AUGraph.\n");
            CFNotificationCenterPostNotification(CFNotificationCenterGetLocalCenter(), kCCOLSetAudioSessionActiveNotification, NULL, NULL, true);
            checkError(AUGraphStart(mGraph), "Error starting AUGraph");
        }
    }
}

void CCOLAudioEngine::stopGraph() {
    Boolean isRunning = false;
    AUGraphIsRunning(mGraph, &isRunning);
    
    if (isRunning) {
        printf("CCOLAudioEngine: Stopping AUGraph.\n");
        checkError(AUGraphStop(mGraph),"Cannot stop AUGraph");
        CFNotificationCenterPostNotification(CFNotificationCenterGetLocalCenter(), kCCOLSetAudioSessionInactiveNotification, NULL, NULL, true);
    }
}

#pragma mark App State Management
void CCOLAudioEngine::appDidEnterBackground() {
    printf("CCOLAudioEngine: App did enter background.\n");
    isForeground = false;
    startStop();
}

void CCOLAudioEngine::appWillEnterForeground() {
    printf("CCOLAudioEngine: App will enter foreground.\n");
    isForeground = true;
    startStop();
}

void CCOLAudioEngine::appWillTerminate() {
    printf("CCOLAudioEngine: App will terminate.\n");
    // cleanup
    
    stopGraph();
}

void CCOLAudioEngine::mediaServicesWereReset() {
    printf("CCOLAudioEngine: Media services were reset.\n");
    // clean up
    // re-initialize AUGraph
    stopGraph();
    
    initializeAUGraph(isForeground);
}

#pragma mark Component Management
// Add a component to the engine
CCOLComponentAddress CCOLAudioEngine::createComponent(char* componentType) {
    
    CCOLComponent *newComponent = nullptr;
    
    string componentTypeString = string(componentType);
    
    if (componentTypeString == kCCOLComponentTypeVCO) {
        newComponent = new CCOLComponentVCO(audioContext);
    } else if (componentTypeString == kCCOLComponentTypeEG) {
        newComponent = new CCOLComponentEG(audioContext);
    } else if (componentTypeString == kCCOLComponentTypeLFO) {
        newComponent = new CCOLComponentLFO(audioContext);
    } else if (componentTypeString == kCCOLComponentTypeVCA) {
        newComponent = new CCOLComponentVCA(audioContext);
    } else if (componentTypeString == kCCOLComponentTypeMultiples) {
        newComponent = new CCOLComponentMultiples(audioContext);
    } else if (componentTypeString == kCCOLComponentTypeMixer) {
        newComponent = new CCOLComponentMixer(audioContext);
    } else if (componentTypeString == kCCOLComponentTypeMixer4) {
        newComponent = new CCOLComponentMixer4(audioContext);
    } else if (componentTypeString == kCCOLComponentTypeLogic) {
        newComponent = new CCOLComponentLogic(audioContext);
    } else if (componentTypeString == kCCOLComponentTypeDelay) {
        newComponent = new CCOLComponentDelay(audioContext);
    } else if (componentTypeString == kCCOLComponentTypeReverb) {
        newComponent = new CCOLComponentReverb(audioContext);
    } else if (componentTypeString == kCCOLComponentTypeRingMod) {
        newComponent = new CCOLComponentRingMod(audioContext);
    } else if (componentTypeString == kCCOLComponentTypePan) {
        newComponent = new CCOLComponentPan(audioContext);
    } else if (componentTypeString == kCCOLComponentTypeSequencer) {
        newComponent = new CCOLComponentSequencer(audioContext);
    } else if (componentTypeString == KCCOLComponentTypeMIDI) {
        newComponent = new CCOLMIDIComponent(audioContext);
    } else if (componentTypeString == kCCOLComponentTypeNoiseGenerator) {
        newComponent = new CCOLComponentNoiseGenerator(audioContext);
    } else if (componentTypeString == kCCOLComponentTypeVCF) {
        newComponent = new CCOLComponentVCF(audioContext);
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
    
    if (component != NULL) {
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
}

char* CCOLAudioEngine::getComponentIdentifier(CCOLComponentAddress componentAddress) {
    CCOLComponent *component = (CCOLComponent*)componentAddress;
    return component->getIdentifier();
}

CCOLComponentAddress CCOLAudioEngine::getComponentWithIdentifier(char* componentId) {
    CCOLComponent *result = NULL;
    for (CCOLComponent* &c : components) {
        if (std::string(c->getIdentifier()) == std::string(componentId)) {
            result = c;
        }
    }
    return (CCOLComponentAddress)result;
}

void CCOLAudioEngine::removeAllComponents() {
    for(auto const& thisComponent: components) {
        thisComponent->disconnectAll();
        thisComponent->dealloc();
        free(thisComponent);
    }
    
    components.clear();
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
        pendingDisconnects.push_back(connector);
//        connector->disconnect();
        return true;
    } else {
        if (connector->isConnected()) {
            pendingDisconnects.push_back(connector->getConnected());
//            connector->getConnected()->disconnect();
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


// Add the IAA MIDI callback to the remote io.
void MIDIEventProcCallBack(void *userData, UInt32 inStatus, UInt32 inData1, UInt32 inData2, UInt32 inOffsetSampleFrame){
    CCOLAudioEngine *engine = (CCOLAudioEngine*)userData;
    printf("%u",(unsigned int)inOffsetSampleFrame);
    Byte midiCommand = inStatus >> 4;
    Byte data1 = inData1 & 0x7F;
    Byte data2 = inData2 & 0x7F;
    
    if (midiCommand == 0x09) {
        engine->getMIDIComponent()->noteOn(inData1);
    } else if (midiCommand == 0x08) {
        engine->getMIDIComponent()->noteOff(data1);
    } else if (midiCommand == 0x0E) {
        // TODO: Handle IAA MIDI pitchbends.
//                int value = ((data2 << 7)) + data1;
//        
//                engine->getMIDIComponent()->setPitchbend(value / 16383.0);
    }
}

void CCOLAudioEngine::setupMIDICallbacks() {
    AudioOutputUnitMIDICallbacks callBackStruct;
    callBackStruct.userData = (void*)this;
    callBackStruct.MIDIEventProc = MIDIEventProcCallBack;
    callBackStruct.MIDISysExProc = NULL;
    checkError(AudioUnitSetProperty (mRemoteIO,
                                     kAudioOutputUnitProperty_MIDICallbacks,
                                     kAudioUnitScope_Global,
                                     0,
                                     &callBackStruct,
                                     sizeof(callBackStruct)), "Can't setup Inter App MIDI Callback");
}

CFDictionaryRef CCOLAudioEngine::getDictionary() {

    CFStringRef keys[3];
    CFTypeRef   values[3];

    // User component.
    keys[0] = kCCOLComponentsKey;
    uint componentCount = components.size();
    CFDictionaryRef componentArray[componentCount];

    int i = 0;
    for(auto const& value: components) {
        componentArray[i++] = value->getDictionary();
    }
    
    values[0] = CFArrayCreate(NULL, (const void **)componentArray, componentCount, &kCFTypeArrayCallBacks);
    
    // MIDI component.
    keys[1] = kCCOLMIDIComponentKey;
    values[1] = getMIDIComponent()->getDictionary();
    
    // Interface component.
    keys[2] = kCCOLInterfaceComponentKey;
    values[2] = audioContext->getInterfaceComponent()->getDictionary();
    
    return CFDictionaryCreate(NULL, (const void**)keys, (const void**)values, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
}

// Generate the wavetables
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
        ccRampWaveTable[i] = (SignalType)result  * 1.344; // Overdamping.
    }
    
    // Ramp wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double result = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        for (int j = 1; j <= ANALOG_HARMONICS; j++) {
            result += (sin(tablePhase * j) / j) / 2.0;
        }
        ccSawWaveTable[i] = (SignalType)result * 1.344; // Overdamping.
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
        
        ccTriWaveTable[i] = result * 1.23; // Overdamping
    }
    
    // Square wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double result = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        for (int j = 1; j < (ANALOG_HARMONICS * 2) + 1;j += 2) {
            result += sin(tablePhase * j) / j;
        }
        ccSquareWaveTable[i] = result * 1.28f; // Overdamping.
    }
    
    // NSLOG the waves
    int res = 40;
    
    printf("\n\n");
    for (int i = 0; i < res; i++) {
        NSInteger sampleIndex = (i / (float)res) * WAVETABLE_SIZE;
        SignalType sample = ccTriWaveTable[sampleIndex];
        
        int level = ((sample + 1) / 2.0) * res * 2;

        for (int i = 0; i < level; i++) {
            printf("_");
        }
        printf("*%.3f\n", sample);
    }
}
