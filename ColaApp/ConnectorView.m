//
//  ConnectorView.m
//  ColaApp
//
//  Created by Chris on 22/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "ConnectorView.h"
#import "defines.h"
#import "ColaLib/COLAudioEnvironment.h"

@interface ConnectorView ()

@property (nonatomic) CCOLConnectorAddress connector;
@property (nonatomic) CALayer   *connectedLayer;
@property (nonatomic) BOOL      connected;

@end

@implementation ConnectorView

-(instancetype)initWithComponentIO:(CCOLConnectorAddress)componentIO {
    
    if (self = [super init]) {
        self.connector = componentIO;
        self.frame = CGRectMake(0, 0, 40, 40);
        NSString *connectorAssetName = @"connector_blue";
        
        kIOType ioType = [[COLAudioEnvironment sharedEnvironment] getConnectorType:componentIO];
        if (ioType & kIOTypeControl || ioType & kIOType1VOct || ioType & kIOTypeGate) {
            connectorAssetName = @"connector_yellow";
        }

        connectorAssetName = [ASSETS_PATH_CONNECTORS stringByAppendingString:connectorAssetName];
        UIImage *connectorImage = [UIImage imageNamed:connectorAssetName];
        
        if (connectorImage) {
            [self.layer setContents:(id)connectorImage.CGImage];
        }
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
        [panGesture setCancelsTouchesInView:NO];
        [self addGestureRecognizer:panGesture];
//        
//        self.connectedLayer = [CALayer layer];
//        [self.connectedLayer setFrame:self.bounds];
//        [self.connectedLayer setContents:(id)[UIImage imageNamed:[ASSETS_PATH_CONNECTORS stringByAppendingString:@"connector_plug"]].CGImage];
//        [self.layer addSublayer:self.connectedLayer];
//        
//        self.connected = false;
    }
    
    return self;
}

-(void)panGestureHandler:(UIGestureRecognizer*)uigr {
    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)uigr;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(connectorView:didBeginDrag:)]) {
            [self.delegate connectorView:self didBeginDrag:panGesture];
        }
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        if ([self.delegate respondsToSelector:@selector(connectorView:didContinueDrag:)]) {
            [self.delegate connectorView:self didContinueDrag:panGesture];
        }
    } else if (panGesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(connectorView:didEndDrag:)]) {
            [self.delegate connectorView:self didEndDrag:panGesture];
        }
    }
}

@end
