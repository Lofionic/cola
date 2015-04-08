//
//  COLAudioEngine.m
//  ColaLib
//
//  Created by Chris on 11/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLAudioEngine.h"
#import "COLAudioContext.h"
#import "COLDefines.h"
#import "COLComponentInput.h"
#import "Endian.h"
#import "COLDefines.h"

AudioSignalType sinWaveTable[WAVETABLE_SIZE];
AudioSignalType triWaveTable[WAVETABLE_SIZE];
AudioSignalType sawWaveTable[WAVETABLE_SIZE];
AudioSignalType rampWaveTable[WAVETABLE_SIZE];
AudioSignalType squareWaveTable[WAVETABLE_SIZE];

@interface COLAudioEngine() {
    Float64 sampleRate;
}

@property (nonatomic) BOOL isForeground;
@property (nonatomic) BOOL isInterAppConnected;

@property (nonatomic, weak) COLComponentInput *masterInputL;
@property (nonatomic, weak) COLComponentInput *masterInputR;

@end

@implementation COLAudioEngine

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self registerApplicationStateNotifications];
        
        // Build wavetables
        [self buildWavetables];
        
        // Init the master inputs
        self.masterInputL = [[COLAudioContext globalContext] masterInputAtIndex:0];
        self.masterInputR = [[COLAudioContext globalContext] masterInputAtIndex:1];
    }
    
    return self;
}

-(void)initializeAUGraph {
    // Create the AUGraph
    NSLog(@"Creating AUGraph");
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
    NSLog(@"Opening AUGraph");
    checkError(AUGraphOpen(mGraph), "Cannot open AUGraph");
    
    // Get a link to the RemoteIO AU
    checkError(AUGraphNodeInfo(mGraph, remoteIONode, NULL, &mRemoteIO), "Cannot get RemoteIO node info");
    
    // Set the render callback
    AURenderCallbackStruct renderCallbackStruct;
    renderCallbackStruct.inputProc = &renderCallback;
    renderCallbackStruct.inputProcRefCon = (__bridge void*)self; // Render callback context is a bridged reference to self
    checkError(AUGraphSetNodeInputCallback(mGraph, remoteIONode, 0, &renderCallbackStruct), "Cannot set render callback on RemoteIO node");
    
    // Set the RemoteIO stream format
    AudioStreamBasicDescription streamFormat = {0};
    
    streamFormat.mSampleRate =          sampleRate;
    streamFormat.mFormatID =            kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =         kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mFramesPerPacket =     1;
    streamFormat.mChannelsPerFrame =    2;
    streamFormat.mBitsPerChannel =      sizeof(AudioSignalType) * 8;
    streamFormat.mBytesPerPacket =      sizeof(AudioSignalType) * 1;
    streamFormat.mBytesPerFrame =       sizeof(AudioSignalType) * 1;
    streamFormat.mReserved =            0;

    checkError(AudioUnitSetProperty(mRemoteIO, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, sizeof(streamFormat)), "Cannot set RemoteIO stream format");

    // Initialize Inter-App Audio
    [self initializeInterAppAudio];
    
    [self startStopEngine];
}

#pragma mark Start and Stop
-(void)startStopEngine {
    // Starts and stops graph according to app state
    if (self.isForeground || self.isInterAppConnected) {
        NSLog(@"App is foreground or Inter-App connected");
        
        sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
        
        if (mGraph) {
            Boolean initialized = YES;
            checkError(AUGraphIsInitialized(mGraph, &initialized), "Error checking initializing of AUGraph");
            if (!initialized) {
                NSLog(@"Initializing AUGraph");
                checkError(AUGraphInitialize (mGraph), "Error initializing AUGraph");
            }
            [self startGraph];
        }
    } else {
        NSLog(@"App is background, Inter-App disconnected");
        [self stopGraph];
    }
}

-(void)startGraph {
    // Start the AUGraph
    Boolean isRunning = false;
    
    // Check that the graph is not running
    OSStatus result = AUGraphIsRunning(mGraph, &isRunning);
    
    if (!isRunning) {
        // Start audio session
        [self setAudioSessionActive];
        
        // Start the graph
        NSLog(@"Starting AUGraph");
        
        checkError(AUGraphStart(mGraph), "Error starting AUGraph");
        
        // Print the result
        if (result) { printf("AUGraphStart result %d %08X %4.4s\n", (int)result, (int)result, (char*)&result); return; }
    }
}

-(void)stopGraph {
    // Stop the AUGraph
    Boolean isRunning = false;
    
    // Check that the graph is running
    AUGraphIsRunning(mGraph, &isRunning);
    
    // If the graph is running, stop it
    if (isRunning) {
        NSLog(@"Stopping AUGraph");
        checkError(AUGraphStop(mGraph),"Cannot stop AUGraph");
        
        // Stop audio session
        [self setAudioSessionInActive];
    }
}


#pragma mark render
static OSStatus renderCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    @autoreleasepool {

    COLAudioEngine *audioEngine = (__bridge COLAudioEngine*)inRefCon;

    AudioSignalType *leftBuffer = [[audioEngine masterInputL] getBuffer:inNumberFrames];
    AudioSignalType *rightBuffer = [[audioEngine masterInputR] getBuffer:inNumberFrames];

    if (![audioEngine.masterInputR isConnected]) {
        rightBuffer = [audioEngine.masterInputL getBuffer:inNumberFrames];
    }

    AudioSignalType *outA = ioData->mBuffers[0].mData;
    AudioSignalType *outB = ioData->mBuffers[1].mData;
    
    for (int i = 0; i < inNumberFrames; i ++) {
        outA[i] = leftBuffer[i];
        outB[i] = rightBuffer[i];

    }

    [audioEngine.masterInputL engineDidRender];
    [audioEngine.masterInputR engineDidRender];
    }
    return noErr;
}


#pragma mark Audio Session Management
-(void) setAudioSessionActive {
    NSLog(@"Audio Session Active @ %.2fHz", sampleRate);
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setPreferredSampleRate: sampleRate error: nil];
    [session setCategory: AVAudioSessionCategoryPlayback withOptions: AVAudioSessionCategoryOptionMixWithOthers error: nil];
    [session setActive: YES error: nil];
}

-(void) setAudioSessionInActive {
    NSLog(@"Audio Session Inactive");
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive: NO error: nil];
}

#pragma mark App State Management
-(void)registerApplicationStateNotifications {
    
    UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
    self.isForeground = (appState != UIApplicationStateBackground);
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appDidEnterBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appWillEnterForeground)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(mediaServicesWereReset)
                                                 name: AVAudioSessionMediaServicesWereResetNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appWillTerminate)
                                                 name: UIApplicationWillTerminateNotification
                                               object: nil];
}

-(void)appDidEnterBackground {
    NSLog(@"App did enter background");
    self.isForeground = NO;
    [self startStopEngine];
}

-(void)appWillEnterForeground {
    NSLog(@"App will enter foreground");
    self.isForeground = YES;
    [self startStopEngine];
}

-(void)mediaServicesWereReset {
    NSLog(@"Media services were reset");
    // TODO: Clear up & rebuild audio engine
    [self cleanup];
    [self initializeAUGraph];
}

-(void)appWillTerminate {
    NSLog(@"App will terminate");
    [self cleanup];
}

#pragma mark Inter App Audio

-(void)initializeInterAppAudio {
    // Get the inter app info dictionary from the delegate
    NSDictionary *infoDictionary = nil;
    if ([self.delegate respondsToSelector:@selector(interAppInfoDictionaryForAudioEngine:)]) {
        infoDictionary = [self.delegate interAppInfoDictionaryForAudioEngine:self];
    }
    
    if (infoDictionary) {
        NSLog(@"Registering Inter-App Audio");
        self.isInterAppConnected = NO;
        
        // Add property listener for inter-app audio
        checkError(AudioUnitAddPropertyListener(mRemoteIO, kAudioUnitProperty_IsInterAppConnected, audioUnitPropertyListenerDispatcher, (__bridge void*)self), "Error setting IAA connected property listener");
        checkError(AudioUnitAddPropertyListener(mRemoteIO, kAudioOutputUnitProperty_HostTransportState, audioUnitPropertyListenerDispatcher, (__bridge void*)self), "Error setting IAA host transport state listener");

        NSString *componentName = infoDictionary[kDictionaryKeyComponentName];
        NSString *componentManufacturer = infoDictionary[kDictionaryKeyComponentMaufacturer];

        AudioComponentDescription audioComponentDescription = {
            kAudioUnitType_RemoteInstrument,
            'iasp',
            fourCharCode(componentManufacturer),
            0,
            1
        };
        
        checkError(AudioOutputUnitPublish(&audioComponentDescription, (__bridge CFStringRef)componentName, 1, mRemoteIO), "Cannot publish IAA component");
    } else {
        NSLog(@"No Inter-App Audio info available");
    }
}

-(void)audioUnitPropertyChanged:(void *) inObject unit:(AudioUnit)inUnit propID:(AudioUnitPropertyID) inID scope:(AudioUnitScope)inScope  element:(AudioUnitElement)inElement {
    if (inID == kAudioUnitProperty_IsInterAppConnected) {
        // IsInterAppConnected has changed
        [self interAppConnectedDidChange];
        
    } else if (inID == kAudioOutputUnitProperty_HostTransportState) {
        // HostTransportState has changed
    }
}

-(void)interAppConnectedDidChange {
    if (mRemoteIO) {
        UInt32 connected;
        UInt32 dataSize = sizeof(UInt32);
        checkError(AudioUnitGetProperty(mRemoteIO, kAudioUnitProperty_IsInterAppConnected, kAudioUnitScope_Global, 0, &connected, &dataSize), "Error getting IsInterAppConnected property");
        if (connected != self.isInterAppConnected) {
            self.isInterAppConnected = connected;
            if (self.isInterAppConnected) {
                [self interAppDidConnect];
            } else {
                [self interAppDidDisconnect];
            }
        }
    };
}

-(void)interAppDidConnect {
    NSLog(@"IAA connected");
    [self startStopEngine];
    
}

-(void)interAppDidDisconnect {
    NSLog(@"IAA disconnected");
    [self startStopEngine];
}

#pragma mark Utility
//Callback for audio units bouncing from c to objective c
void audioUnitPropertyListenerDispatcher(void *inRefCon, AudioUnit inUnit, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement) {
    COLAudioEngine *SELF = (__bridge COLAudioEngine *)inRefCon;
    [SELF audioUnitPropertyChanged:inRefCon unit:inUnit propID:inID scope:inScope element:inElement];
}

static OSType fourCharCode(NSString *string) {
    unsigned int fourCharCode;
    
    const char *bytes = [[string dataUsingEncoding:NSUTF8StringEncoding] bytes];
    
    *((char *) &fourCharCode + 0) = *(bytes + 0);
    *((char *) &fourCharCode + 1) = *(bytes + 1);
    *((char *) &fourCharCode + 2) = *(bytes + 2);
    *((char *) &fourCharCode + 3) = *(bytes + 3);
    
    return EndianU32_NtoB(fourCharCode);
}

static void checkError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    char errorString[20];
    
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString); exit(1);
}

#pragma mark Wavetables

-(void)buildWavetables {

    // Sin wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        AudioSignalType a = sin(tablePhase);
        sinWaveTable[i] = a;
    }
    
    // Saw wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double result = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        for (int j = 1; j <= ANALOG_HARMONICS; j++) {
            result -= (sin(tablePhase * j) / j) / 2.0;
        }
        sawWaveTable[i] = (AudioSignalType)result;
    }
    
    // Ramp wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double result = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        for (int j = 1; j <= ANALOG_HARMONICS; j++) {
            result += (sin(tablePhase * j) / j) / 2.0;
        }
        rampWaveTable[i] = (AudioSignalType)result;
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
        
        triWaveTable[i] = result;
    }
    
    // Square wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double result = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        for (int j = 1; j < (ANALOG_HARMONICS * 2) + 1;j += 2) {
            result += sin(tablePhase * j) / j;
        }
        squareWaveTable[i] = result;
    }
    
    // NSLOG the waves
    int res = 40;
    for (int i = 0; i < res; i++) {
        NSInteger sampleIndex = (i / (float)res) * WAVETABLE_SIZE;
        AudioSignalType sample = squareWaveTable[sampleIndex];
        
        NSInteger level = ((sample + 1) / 2.0) * res * 2;
        NSString *padding = [@"" stringByPaddingToLength:level withString:@"-" startingAtIndex:0];
        NSLog(@"%@", [padding stringByAppendingString:@"*"]);
    }
}

#pragma mark Cleanup

-(void)cleanup {
    [self stopGraph];
    [self setAudioSessionInActive];
    
    AUGraphClose(mGraph);
    DisposeAUGraph(mGraph);

    mGraph = nil;
}

-(void)dealloc {
    [self cleanup];
    
    [self removeObserver:self forKeyPath:UIApplicationDidEnterBackgroundNotification];
    [self removeObserver:self forKeyPath:UIApplicationWillEnterForegroundNotification];
    [self removeObserver:self forKeyPath:AVAudioSessionMediaServicesWereResetNotification];
    [self removeObserver:self forKeyPath:UIApplicationWillTerminateNotification];
}

@end
