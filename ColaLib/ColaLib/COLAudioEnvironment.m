//
//  COLAudioEnvironment.m
//  ColaLib
//
//  Created by Chris on 11/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLAudioEnvironment.h"
#import "CCOLIAAController.h"
#import "CCOLAudioEngine.hpp"
#import "CCOLComponentParameter.hpp"
#import "CCOLComponentIO.hpp"
#import "CCOLMIDIComponent.hpp"
#import "CCOLTransportController.hpp"
#import "CCOLDefines.h"
#import "Endian.h"

@interface COLAudioEnvironment()

@property (nonatomic) Float64   sampleRate;
@property (nonatomic, strong) CCOLIAAController *iaaController;

@end

@implementation COLAudioEnvironment {
    CCOLAudioEngine         ccAudioEngine;
    CCOLMIDIComponent       *midiComponent;
}

+ (instancetype) sharedEnvironment {
    static COLAudioEnvironment *sharedEnvironment = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEnvironment = [[self alloc] init];
    });
    return sharedEnvironment;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Get the current audiosession sample rate
        self.sampleRate = [[AVAudioSession sharedInstance] sampleRate];
                
        id appDelegate = [[UIApplication sharedApplication] delegate];
        if ([appDelegate conformsToProtocol:@protocol(COLAudioEnvironmentInfoDelegate) ]) {
            self.infoDelegate = appDelegate;
        }

        // Cherry Cola
        // ccAudioEngine = new CCOLAudioEngine();
        
        // Prepare keyboard component
        midiComponent = ccAudioEngine.getMIDIComponent();
        
        // Observer for forced disconnects
        CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, engineNotificationCallback, kCCOLEngineDidForceDisconnectNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, setAudioSessionActiveCallback, kCCOLSetAudioSessionActiveNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, setAudioSessionInactiveCallback, kCCOLSetAudioSessionInactiveNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        
    }
    return self;
}

static void engineNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    // Bounce the notifications from CFNotificationCenter into NSNotificationCenter
    if (name == kCCOLEngineDidForceDisconnectNotification) {
        CCOLOutputAddress outputAddress = (CCOLOutputAddress)CFDictionaryGetValue(userInfo, CFSTR("output"));
     
        NSDictionary *nsUserInfo = @{@"output" : [NSNumber numberWithUnsignedLongLong:outputAddress]};
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCOLEventEngineDidForceDisconnect object:nil userInfo:nsUserInfo];
    }
}

static void setAudioSessionActiveCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    printf("COLAudioEnvironment: Set AVAudioSession active.\n");
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setPreferredSampleRate: [[AVAudioSession sharedInstance] sampleRate] error: nil];
    [session setCategory: AVAudioSessionCategoryPlayback withOptions: AVAudioSessionCategoryOptionMixWithOthers error: &error];
    if (error) {
        NSLog(@"COLAudioEnvironment: Error setting AVAudioSession category : %@", error.description);
    } else {
        [session setActive: YES error: &error];
        if (error) {
            NSLog(@"COLAudioEnvironment: Error setting AVAudioSession active : %@", error.description);
        }
    }
}

static void setAudioSessionInactiveCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    printf("COLAudioEnvironment: Set AVAudioSession inactive.\n");
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setActive: NO error: &error];
    if (error) {
        NSLog(@"COLAudioEnvironment: Error setting AVAudioSession inactive : %@", error.description);
    }
}

-(void)start {
    UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
    ccAudioEngine.initializeAUGraph(appState != UIApplicationStateBackground);
    
    [self initializeInterAppAudio];
    
    ccAudioEngine.startStop();
}

-(void)mute {
    ccAudioEngine.setMute(true);
}
-(void)unmute {
    ccAudioEngine.setMute(false);
}

-(BOOL)isMute {
    return ccAudioEngine.isMute();
}


-(BOOL)isTransportPlaying {
    return ccAudioEngine.getTransportController()->isPlaying();
}

-(void)transportPlay {
    ccAudioEngine.getTransportController()->start();
}

-(void)transportStop {
    ccAudioEngine.getTransportController()->stopAndReset();
}


#pragma mark Communication with Engine
-(CCOLComponentAddress)createComponentOfType:(char*)componentType {
    return ccAudioEngine.createComponent(componentType);
}

-(void)removeComponent:(CCOLComponentAddress)componentAddress {
    ccAudioEngine.removeComponent(componentAddress);
}

-(CCOLOutputAddress)getOutputNamed:(NSString*)outputName onComponent:(CCOLComponentAddress)componentAddress {
    return ccAudioEngine.getOutput(componentAddress, (char*)[outputName UTF8String]);
}

-(CCOLInputAddress)getInputNamed:(NSString*)inputName onComponent:(CCOLComponentAddress)componentAddress {
    return ccAudioEngine.getInput(componentAddress, (char*)[inputName UTF8String]);
}

-(NSString*)getConnectorName:(CCOLConnectorAddress)connectorAddress {
    CCOLComponentConnector* connector = (CCOLComponentConnector*)connectorAddress;
    return [NSString stringWithUTF8String:connector->getName()];
}

-(CCOLParameterAddress)getParameterNamed:(NSString*)parameterName onComponent:(CCOLComponentAddress)componentAddress {
    return ccAudioEngine.getParameter(componentAddress, (char*)[parameterName UTF8String]);
}

-(double)getParameterValue:(CCOLParameterAddress)parameterAddress {
    CCOLComponentParameter *parameter = (CCOLComponentParameter*)parameterAddress;
    return parameter->getNormalizedValue();
}

-(void)setParameter:(CCOLParameterAddress)parameterAddress value:(double)value {
    CCOLComponentParameter *parameter = (CCOLComponentParameter*)parameterAddress;
    parameter->setNormalizedValue(value);
}

-(NSString*)getParameterName:(CCOLParameterAddress)parameterAddress {
    CCOLComponentParameter *parameter = (CCOLComponentParameter*)parameterAddress;
    return [NSString stringWithUTF8String:parameter->getName()];
}

-(BOOL)connectOutput:(CCOLOutputAddress)outputAddress toInput:(CCOLInputAddress)inputAddress {
    return ccAudioEngine.connect(outputAddress, inputAddress);
}

-(BOOL)disconnect:(CCOLConnectorAddress)connectorAddress {
    return ccAudioEngine.disconnect(connectorAddress);
}

-(kIOType)getConnectorType:(CCOLConnectorAddress)connectorAddress {
    return ccAudioEngine.getIOType(connectorAddress);
}

-(CCOLInputAddress)getMasterInputAtIndex:(UInt32)index {
    return ccAudioEngine.getMasterInput(index);
}

//TODO: Make this MIDI
#pragma mark notes
-(CCOLComponentAddress)getMIDIComponent {
    return (CCOLComponentAddress)midiComponent;
}

-(void)noteOn:(NoteIndex)noteIndex {
    midiComponent->noteOn(noteIndex);
}


-(void)noteOff:(NoteIndex)noteIndex {
    midiComponent->noteOff(noteIndex);
}

-(void)allNotesOff {
    midiComponent->allNotesOff();
}

#pragma mark Inter-app-audio
-(void)initializeInterAppAudio {
    // Get the inter app info dictionary from the delegate
    NSDictionary *infoDictionary = nil;
    
    if ([self.infoDelegate respondsToSelector:@selector(interAppInfoDictionary)]) {
        infoDictionary = [self.infoDelegate interAppInfoDictionary];
    }
    
    if (infoDictionary) {
        NSString *componentName = infoDictionary[kDictionaryKeyComponentName];
        NSString *manufacturerCode = infoDictionary[kDictionaryKeyComponentMaufacturer];
        
        self.iaaController = [[CCOLIAAController alloc] init];
        [self.iaaController initializeIAAwithComponentName:(__bridge CFStringRef)componentName manufactureCode:fourCharCode(manufacturerCode) engine:&ccAudioEngine];
    }
}

#pragma mark AudioEngine delegates
//-(NSDictionary *)interAppInfoDictionaryForAudioEngine:(COLAudioEngine *)audioEngine {
//    // Fetch the inter-app audio info from the app delegate
//    if ([self.infoDelegate respondsToSelector:@selector(interAppInfoDictionary)]) {
//        return [self.infoDelegate interAppInfoDictionary];
//    }
//    else {
//        return nil;
//    }
//}
//
//-(void)audioEngineInterAppAudioConnected:(COLAudioEngine *)audioEngine {
//    NSLog(@"COLAudioEnvironment: Inter-app audio connected");
//}
//
//-(void)audioEngineInterAppAudioDisconnected:(COLAudioEngine *)audioEngine {
//    NSLog(@"COLAudioEnvironment: Inter-app audio disconnected");
//}

// IAA Callbacks
-(BOOL)isInterAppAudioConnected {
    return [self.iaaController isHostConnected];
}

-(BOOL)iaaIsPlaying {
    return [self.iaaController isHostPlaying];
}

-(BOOL)iaaIsRecording {
    return [self.iaaController isHostRecording];
}

-(UIImage*)getIAAHostImage {
    return [self.iaaController hostImage];
}

-(void)iaaGoToHost {
    [self.iaaController gotoHost];
}

-(void)iaaTogglePlay {
    [self.iaaController togglePlay];
}

-(void)iaaToggleRecord {
    [self.iaaController toggleRecord];
}


-(void)iaaRewind {
    [self.iaaController rewind];
}

-(void)exportEnvironment {
    // [COLExporter getJSONObjectForEnvironment:self];
}


static OSType fourCharCode(NSString *string) {
    unsigned int fourCharCode;
    
    const char *bytes = (char*)[[string dataUsingEncoding:NSUTF8StringEncoding] bytes];
    
    *((char *) &fourCharCode + 0) = *(bytes + 0);
    *((char *) &fourCharCode + 1) = *(bytes + 1);
    *((char *) &fourCharCode + 2) = *(bytes + 2);
    *((char *) &fourCharCode + 3) = *(bytes + 3);
    
    return EndianU32_NtoB(fourCharCode);
}

@end
