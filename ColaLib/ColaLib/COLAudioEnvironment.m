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

@interface COLAudioEnvironment()

@property (nonatomic) Float64                   sampleRate;
@property (nonatomic) BOOL                      isForeground;

@property (nonatomic, strong) COLTransportController    *transportController;

@end

@implementation COLAudioEnvironment {
    CCOLAudioEngine     ccAudioEngine;
    CCOLMIDIComponent   *midiComponent;
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
        
        [self registerApplicationStateNotifications];
        
        // Cherry Cola
        // ccAudioEngine = new CCOLAudioEngine();
        
        // Prepare keyboard component
        midiComponent = (CCOLMIDIComponent*)ccAudioEngine.createComponent((char*)[@"CCOLMIDIComponent" UTF8String]);
    }
    return self;
}

-(void)start {
    ccAudioEngine.initializeAUGraph(self.sampleRate);
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

#pragma mark App State Management
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
    NSLog(@"COLAudioEnvironment: App did enter background");
    self.isForeground = NO;
    // [self startStopEngine];
    
    ccAudioEngine.setMute(true);
}

-(void)appWillEnterForeground {
    NSLog(@"COLAudioEnvironment: App will enter foreground");
    self.isForeground = YES;
    // [self startStopEngine];
    // [self updateTransportStateFromHostCallback];
    
    ccAudioEngine.setMute(false);
}

-(void)mediaServicesWereReset {
    NSLog(@"COLAudioEnvironment: Media services were reset");
    // TODO: Clear up & rebuild audio engine
    // [self cleanup];
    // [self initializeAUGraph];
}

-(void)appWillTerminate {
    NSLog(@"COLAudioEnvironment: App will terminate");
    // [self cleanup];
    
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

-(BOOL)isInterAppAudioConnected {
    // return [self.audioEngine iaaConnected];
    return NO;
}

-(void)exportEnvironment {
    // [COLExporter getJSONObjectForEnvironment:self];
}

@end
