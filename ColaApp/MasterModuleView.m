//
//  MasterModuleView.m
//  ColaApp
//
//  Created by Chris on 11/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "ConnectorView.h"
#import "MasterModuleView.h"
#import "BuildViewController.h"
#import "BuildView.h"

#import <ColaLib/CCOLTypes.h>
#import <ColaLib/COLAudioEnvironment.h>

@implementation MasterModuleView

-(instancetype)initWithFrame:(CGRect)frame buildView:(BuildView*)buildView {
    if (self = [super initWithFrame:frame]) {
        self.identifier = @"Master";
        [self addGlobalIObuildView:buildView];
        
        UIImage *asset = [UIImage imageNamed:@"ImageAssets/components/master"];
        [self.layer setContents:(id)asset.CGImage];
    }
    return self;
}

-(void)addGlobalIObuildView:(BuildView*)buildView {
    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    
    CCOLInputAddress mainInL = [cae getMasterInputAtIndex:0];
    ConnectorView *mainInLConnectorView = [[ConnectorView alloc] initWithComponentIO:mainInL];
    [mainInLConnectorView setCenter:CGPointMake(630.0, 32.0)];
    [mainInLConnectorView setDelegate:buildView];
    [self addSubview:mainInLConnectorView];

    CCOLInputAddress mainInR = [cae getMasterInputAtIndex:1];
    ConnectorView *mainInRConnectorView = [[ConnectorView alloc] initWithComponentIO:mainInR];
    [mainInRConnectorView setCenter:CGPointMake(680.0, 32.0)];
    [mainInRConnectorView setDelegate:buildView];
    [self addSubview:mainInRConnectorView];

    CCOLComponentAddress midiComponent = [cae getMIDIComponent];
    CCOLOutputAddress keyboardOut = [cae getOutputNamed:@"Keyboard Out" onComponent:midiComponent];
    ConnectorView *keyboardOutView = [[ConnectorView alloc] initWithComponentIO:keyboardOut];
    [keyboardOutView setCenter:CGPointMake(40.0, 32.0)];
    [keyboardOutView setDelegate:buildView];
    [self addSubview:keyboardOutView];
    
    CCOLOutputAddress gateOut = [cae getOutputNamed:@"Gate Out" onComponent:midiComponent];
    ConnectorView *gateOutView = [[ConnectorView alloc] initWithComponentIO:gateOut];
    [gateOutView setCenter:CGPointMake(90.0, 32.0)];
    [gateOutView setDelegate:buildView];
    [self addSubview:gateOutView];
//
//    COLComponentIO *keyboardGate = [[[COLAudioEnvironment sharedEnvironment] keyboardComponent] outputForIndex:1];
//    ConnectorView *keyboardGateView = [[ConnectorView alloc] initWithComponentIO:keyboardGate];
//    [keyboardGateView setCenter:CGPointMake(80.0, 40.0)];
//    [keyboardGateView setDelegate:buildView];
//    [self addSubview:keyboardGateView];
//    
//    self.connectorViews = @[mainInLConnectorView, mainInRConnectorView, keyboardOutView, keyboardGateView];
    
    self.connectorViews = @[
                            mainInLConnectorView,
                            mainInRConnectorView,
                            keyboardOutView,
                            gateOutView
                            ];
}

@end
