//
//  COLAudioEnvironment.m
//  ColaLib
//
//  Created by Chris on 11/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "COLAudioEnvironment.h"
#import "COLAudioEngine.h"
#import "COLAudioContext.h"
#import "COLComponent.h"
#import "COLComponents.h"
#import "COLTransportController.h"
#import "NSString+Random.h"
#import "COLExporter.h"

@interface COLAudioEnvironment()

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
        
        self.audioEngine = [[COLAudioEngine alloc] init];
        [self.audioEngine setDelegate:self];
        
        self.components = [[NSMutableArray alloc] initWithCapacity:10];
        
        self.keyboardComponent = [[COLKeyboardComponent alloc] initWithContext:[COLAudioContext globalContext]];
        self.transportController = [[COLTransportController alloc] init];
    }
    return self;
}

-(void)start {
    [self.audioEngine initializeAUGraph];
}

-(void)mute {
    [self.audioEngine mute];
}
-(void)unmute {
    [self.audioEngine unmute];
}

-(BOOL)connectComponent:(COLComponent*)component outputIndex:(NSInteger)outputIndex toMasterIndex:(NSInteger)masterIndex {
    
    COLComponentOutput *theOutput = [component outputForIndex:outputIndex];
    if (!theOutput) {
        NSLog(@"Connection failed : Invalid output");
        return FALSE;
    }
    
    COLComponentInput *theInput;
    if (masterIndex == 0) {
        theInput = [[self audioEngine] masterInputL];
    } else if (masterIndex == 1) {
        theInput = [[self audioEngine] masterInputR];
    }
    if (!theInput) {
        NSLog(@"Connection failed : Invalid input");
        return FALSE;
    }
    
    return [theOutput connectTo:theInput];
}

#pragma mark Component Factory
-(COLComponent*)createComponentOfType:(NSString *)componentType {
    
    COLAudioContext *context = [COLAudioContext globalContext];
    COLComponent *newComponent;
    
    if ([componentType isEqualToString:kCOLComponentVCO]) {
        newComponent = [[COLComponentVCO alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentLFO]) {
        newComponent = [[COLComponentLFO alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentWavePlayer]) {
        newComponent = [[COLComponentWavePlayer alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentEnvelope]) {
        newComponent = [[COLComponentEnvelope alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentVCA]) {
        newComponent = [[COLComponentVCA alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentMultiples]) {
        newComponent = [[COLComponentMultiples alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentMultiplesKB]) {
        newComponent = [[COLComponentMultiplesKB alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentMixer2]) {
        newComponent = [[COLComponentMixer2 alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentVCF]) {
        newComponent = [[COLComponentVCF alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentPan]) {
        newComponent = [[COLComponentPan alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentRingModulator]){
        newComponent = [[COLComponentRingModulator alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentSequencer]) {
        newComponent = [[COLComponentSequencer alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentNoiseGenerator]) {
        newComponent = [[COLComponentNoiseGenerator alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentDelay]) {
        newComponent = [[COLComponentDelay alloc] initWithContext:context];
    } else {
        NSLog(@"Unknown component type : %@", componentType);
    }
    
    if (newComponent) {
        [self.components addObject:newComponent];
        [newComponent assignUniqueName];
    }

    return newComponent;
}

-(BOOL)removeComponent:(COLComponent*)component {
    if ([self.components containsObject:component]) {
        [component disconnectAll];
        [self.components removeObject:component];
        return TRUE;
    } else {
        return FALSE;
    }
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
    return [self.audioEngine iaaConnected];
}

-(void)exportEnvironment {
    [COLExporter getJSONObjectForEnvironment:self];
}

@end
