//
//  COLAudioEnvironment.m
//  ColaLib
//
//  Created by Chris on 11/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLAudioEnvironment.h"
#import "CCOLAudioEngine.hpp"
#import "CCOLComponentParameter.hpp"
#import "CCOLComponentIO.hpp"
#import "CCOLMIDIComponent.hpp"
#import "CCOLTransportController.hpp"
#import "CCOLDefines.h"
#import "Endian.h"

@interface COLAudioEnvironment()

@property (nonatomic) Float64   sampleRate;

@end

@implementation COLAudioEnvironment {
    CCOLAudioEngine         ccAudioEngine;
    CCOLMIDIComponent       *midiComponent;
    CCOLIAAController       *iaaController;
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

        midiComponent = ccAudioEngine.getMIDIComponent();
        iaaController = ccAudioEngine.getIAAController();
        
        // Engine observers
        CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
        CFNotificationCenterAddObserver(center, (void*)self, engineForcedDisconnectNotificationReceived, kCCOLEngineDidForceDisconnectNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(center, (void*)self, setAudioSessionActiveNotificationReceived, kCCOLSetAudioSessionActiveNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(center, (void*)self, setAudioSessionInactiveNotificationReceived, kCCOLSetAudioSessionInactiveNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(center, (void*)self, iaaTransportStateDidChangeNotificatoinReceived, kCCOLIAAControllerTransportStateDidChange, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
    return self;
}

-(void)dealloc {
    // Remove observers
    CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetLocalCenter(), (void*)self);
}

static void engineForcedDisconnectNotificationReceived(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    // Bounce forced disconnect notification from CFNotificationCenter into NSNotificationCenter
    if (name == kCCOLEngineDidForceDisconnectNotification) {
        CCOLOutputAddress outputAddress = (CCOLOutputAddress)CFDictionaryGetValue(userInfo, CFSTR("output"));
     
        NSDictionary *nsUserInfo = @{@"output" : [NSNumber numberWithUnsignedLongLong:outputAddress]};
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCOLEventEngineDidForceDisconnect object:nil userInfo:nsUserInfo];
    }
}

static void iaaTransportStateDidChangeNotificatoinReceived(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    // Bounce the iaa transport state notifications from CFNotificationCenter into NSNotificationCenter
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCOLEventIAATransportStateDidChange object:nil];
}

static void setAudioSessionActiveNotificationReceived(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
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

static void setAudioSessionInactiveNotificationReceived(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
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

-(NSString*)getComponentID:(CCOLComponentAddress)componentAddress {
    return [NSString stringWithUTF8String:ccAudioEngine.getComponentIdentifier(componentAddress)];
}

-(CCOLComponentAddress)getComponentWithID:(NSString*)componentID {
    return ccAudioEngine.getComponentWithIdentifier((char*)[componentID UTF8String]);
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

-(void)pitchBend:(float)value {
    midiComponent->setPitchbend(value);
}

-(void)modulate:(float)value {
    midiComponent->setModulation(value);
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
        
        // Initialize IAA 
        ccAudioEngine.initializeIAA((__bridge CFStringRef)componentName, fourCharCode(manufacturerCode));
    }
}

// IAA Callbacks
-(BOOL)isInterAppAudioConnected {
    return iaaController->isHostConnected();
}

-(BOOL)iaaIsPlaying {
    return iaaController->isHostPlaying();
}

-(BOOL)iaaIsRecording {
    return iaaController->isHostRecording();
}

-(UIImage*)getIAAHostImage {
    return iaaController->getHostImage();
}

-(void)iaaGoToHost {
    iaaController->goToHost();
}

-(void)iaaTogglePlay {
    iaaController->hostTogglePlay();
}

-(void)iaaToggleRecord {
    iaaController->hostToggleRecord();
}


-(void)iaaRewind {
    iaaController->hostRewind();
}

-(NSString*)getModelAsJSON {
    NSDictionary *dictionary = (__bridge NSDictionary*)ccAudioEngine.getDictionary();
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"getModelAsJSON: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

-(void)buildModelFromJSON:(NSString*)json {
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if (error) {
        NSLog(@"buildModelFromJSON: error: %@", error.localizedDescription);
    } else {
        ccAudioEngine.removeAllComponents();
        
        // Set the identifiers for the MIDI and Master Interface components.
        NSString *midiIdentifier = [[dictionary objectForKey:@"MIDI"] objectForKey:@"identifier"];
        NSString *interfaceIdentifier = [[dictionary objectForKey:@"interface"] objectForKey:@"identifier"];
        NSArray *components = [dictionary objectForKey:@"components"];
        
        midiComponent->setIdentifier((char*)[midiIdentifier UTF8String]);
        ccAudioEngine.getContext()->getInterfaceComponent()->setIdentifier((char*)[interfaceIdentifier UTF8String]);

        // Add the user components.
        NSMutableDictionary *componentDictionary = [[NSMutableDictionary alloc] initWithCapacity:components.count + 2]; // Stores component addresses against component identifier.
        
        for (NSDictionary *thisComponent in components) {
            CCOLComponentAddress newComponentAddress = ccAudioEngine.createComponent((char*)[[thisComponent objectForKey:@"type" ] UTF8String]);
            CCOLComponent* newComponent = (CCOLComponent*)newComponentAddress;
            if (newComponent) {
                NSString *identifier = [thisComponent objectForKey:@"identifier"];
                newComponent->setIdentifier((char*)[identifier UTF8String]);
                [componentDictionary setObject:[NSNumber numberWithUnsignedInteger:newComponentAddress] forKey:identifier];
                
                // Set component parameters.
                NSDictionary *parameters = [thisComponent objectForKey:@"parameters"];
                for (NSString *thisParameter in [parameters allKeys]) {
                    CCOLParameterAddress parameterAddress = [self getParameterNamed:thisParameter onComponent:newComponentAddress];
                    if (parameterAddress) {
                        float parameterValue = [[parameters objectForKey:thisParameter] floatValue];
                        [self setParameter:parameterAddress value:parameterValue];
                    }
                }
            }
        }
        
        // Connect the components.
        [componentDictionary setObject:[NSNumber numberWithUnsignedInteger:(CCOLComponentAddress)midiComponent] forKey:midiIdentifier];
        [componentDictionary setObject:[NSNumber numberWithUnsignedInteger:(CCOLComponentAddress)ccAudioEngine.getContext()->getInterfaceComponent()] forKey:interfaceIdentifier];
        
        // Add the MIDI and Interfaces components to the list of components.
        NSMutableArray *mutableComponents = [components mutableCopy];
        [mutableComponents addObject:[dictionary objectForKey:@"MIDI"]];
        [mutableComponents addObject:[dictionary objectForKey:@"interface"]];
        
        NSArray *allComponents = [NSArray arrayWithArray:mutableComponents];
        
        for (NSDictionary *thisComponent in allComponents) {
            if ([[thisComponent allKeys] containsObject:@"connections"]) {
                NSArray *connections = [thisComponent objectForKey:@"connections"];
                for (NSDictionary *thisConnection in connections) {
                    NSString *fromComponentIdentifier = [thisComponent objectForKey:@"identifier"];
                    NSString *outputName = [thisConnection objectForKey:@"output"];
                    NSString *toComponentIdentifier = [thisConnection objectForKey:@"component"];
                    NSString *inputName = [thisConnection objectForKey:@"input"];

                    if ([[componentDictionary allKeys] containsObject:fromComponentIdentifier] && [[componentDictionary allKeys] containsObject:toComponentIdentifier]) {
                        CCOLConnectorAddress outputAddress = [self getOutputNamed:outputName onComponent:[[componentDictionary objectForKey:fromComponentIdentifier] unsignedIntegerValue]];
                        CCOLConnectorAddress inputAddress = [self getInputNamed:inputName onComponent:[[componentDictionary objectForKey:toComponentIdentifier] unsignedIntegerValue]];
                        if (outputAddress && inputAddress) {
                            [self connectOutput:outputAddress toInput:inputAddress];
                        }
                    }
                }
            }
        }
        
        NSLog(@"MEHFOO");
    }
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
