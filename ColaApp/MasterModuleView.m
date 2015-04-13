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

@implementation MasterModuleView

-(instancetype)initWithFrame:(CGRect)frame buildView:(BuildView*)buildView {
    if (self = [super initWithFrame:frame]) {
        self.identifier = @"Master";
        [self addGlobalIObuildView:buildView];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
    }
    return self;
}

-(void)addGlobalIObuildView:(BuildView*)buildView {
    COLComponentIO *mainInL = [[COLAudioContext globalContext] masterInputAtIndex:0];
    ConnectorView *mainInLConnectorView = [[ConnectorView alloc] initWithComponentIO:mainInL];
    [mainInLConnectorView setCenter:CGPointMake(600, self.frame.size.height / 2.0)];
    [mainInLConnectorView setDelegate:buildView];
    [self addSubview:mainInLConnectorView];
    
    COLComponentIO *mainInR = [[COLAudioContext globalContext] masterInputAtIndex:1];
    ConnectorView *mainInRConnectorView = [[ConnectorView alloc] initWithComponentIO:mainInR];
    [mainInRConnectorView setCenter:CGPointMake(650, self.frame.size.height  / 2.0)];
    [mainInRConnectorView setDelegate:buildView];
    [self addSubview:mainInRConnectorView];
    
    COLComponentIO *keyboardOut = [[[COLAudioEnvironment sharedEnvironment] keyboardComponent] outputForIndex:0];
    ConnectorView *keyboardOutView = [[ConnectorView alloc] initWithComponentIO:keyboardOut];
    [keyboardOutView setCenter:CGPointMake(120, self.frame.size.height  / 2.0)];
    [keyboardOutView setDelegate:buildView];
    [self addSubview:keyboardOutView];
    
    COLComponentIO *keyboardGate = [[[COLAudioEnvironment sharedEnvironment] keyboardComponent] outputForIndex:1];
    ConnectorView *keyboardGateView = [[ConnectorView alloc] initWithComponentIO:keyboardGate];
    [keyboardGateView setCenter:CGPointMake(168, self.frame.size.height  / 2.0)];
    [keyboardGateView setDelegate:buildView];
    [self addSubview:keyboardGateView];
}

@end
