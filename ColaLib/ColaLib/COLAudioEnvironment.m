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

@interface COLAudioEnvironment() {
    CCOLAudioEngine *ccAudioEngine;
}

@property (nonatomic, strong) COLAudioEngine*   audioEngine;
@property (nonatomic, strong) NSMutableArray    *components;
@property (nonatomic) Float64                   sampleRate;

@property (nonatomic, strong) COLKeyboardComponent      *keyboardComponent;
@property (nonatomic, strong) COLTransportController    *transportController;

@end

@implementation COLAudioEnvironment

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
        
//        self.audioEngine = [[COLAudioEngine alloc] init];
//        [self.audioEngine setDelegate:self];
        
        self.components = [[NSMutableArray alloc] initWithCapacity:10];
        
//        self.keyboardComponent = [[COLKeyboardComponent alloc] initWithContext:[COLAudioContext globalContext]];
//        self.transportController = [[COLTransportController alloc] init];
        
        // Cherry Cola
        ccAudioEngine = new CCOLAudioEngine();
    }
    return self;
}

-(void)start {
//    [self.audioEngine initializeAUGraph];
    
    ccAudioEngine->initializeAUGraph();
}

-(void)mute {
    //[self.audioEngine mute];
}
-(void)unmute {
    //[self.audioEngine unmute];
}

// Component Management
-(CCOLComponentAddress)createComponentOfType:(char*)componentType {
    return ccAudioEngine->createComponent(componentType);
}

-(void)removeComponent:(CCOLComponentAddress)componentAddress {
    ccAudioEngine->removeComponent(componentAddress);
}

// IO
-(CCOLOutputAddress)getOutputNamed:(NSString*)outputName onComponent:(CCOLComponentAddress)componentAddress {
    return ccAudioEngine->getOutput(componentAddress, (char*)[outputName UTF8String]);
}

-(CCOLInputAddress)getInputNamed:(NSString*)inputName onComponent:(CCOLComponentAddress)componentAddress {
    return ccAudioEngine->getInput(componentAddress, (char*)[inputName UTF8String]);
}

-(NSString*)getConnectorName:(CCOLConnectorAddress)connectorAddress {
    CCOLComponentConnector* connector = (CCOLComponentConnector*)connectorAddress;
    return [NSString stringWithUTF8String:connector->getName()];
}

-(CCOLParameterAddress)getParameterNamed:(NSString*)parameterName onComponent:(CCOLComponentAddress)componentAddress {
    return ccAudioEngine->getParameter(componentAddress, (char*)[parameterName UTF8String]);
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
    return ccAudioEngine->connect(outputAddress, inputAddress);
}

-(BOOL)disconnectInput:(CCOLInputAddress)inputAddress {
    return ccAudioEngine->disconnect(inputAddress);
}

-(CCOLInputAddress)getMasterInputAtIndex:(UInt32)index {
    return ccAudioEngine->getMasterInput(index);
}

-(kIOType)getConnectorType:(CCOLConnectorAddress)connectorAddress {
    return ccAudioEngine->getIOType(connectorAddress);
}

#pragma mark AudioEngine delegates

-(NSDictionary *)interAppInfoDictionaryForAudioEngine:(COLAudioEngine *)audioEngine {
    // Fetch the inter-app audio info from the app delegate
    if ([self.infoDelegate respondsToSelector:@selector(interAppInfoDictionary)]) {
        return [self.infoDelegate interAppInfoDictionary];
    }
    else {
        return nil;
    }
}

-(void)audioEngineInterAppAudioConnected:(COLAudioEngine *)audioEngine {
    NSLog(@"Inter-app audio connected");
}

-(void)audioEngineInterAppAudioDisconnected:(COLAudioEngine *)audioEngine {
    NSLog(@"Inter-app audio disconnected");
}

-(BOOL)isInterAppAudioConnected {
    // return [self.audioEngine iaaConnected];
    return NO;
}

-(void)exportEnvironment {
    // [COLExporter getJSONObjectForEnvironment:self];
}

@end
