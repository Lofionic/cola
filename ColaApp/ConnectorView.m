//
//  ConnectorView.m
//  ColaApp
//
//  Created by Chris on 22/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "ConnectorView.h"

#import "defines.h"

@interface ConnectorView ()

@property (nonatomic, weak) COLComponentIO *componentIO;

@end

@implementation ConnectorView

-(instancetype)initWithComponentIO:(COLComponentIO*)componentIO {
    
    if (self = [super init]) {
        self.componentIO = componentIO;
        self.frame = CGRectMake(0, 0, 44, 44);
        
        NSString *connectorAssetName;
        if (componentIO.type == kComponentIOTypeAudio) {
            if ([componentIO isKindOfClass:[COLComponentOutput class]]) {
                connectorAssetName = @"connector_blue";
            } else if ([componentIO isKindOfClass:[COLComponentInput class]]) {
                connectorAssetName = @"connector_green";
            }
        } else if (componentIO.type == kComponentIOTypeControl || componentIO.type == kComponentIOType1VOct) {
            connectorAssetName = @"connector_yellow";
        }
        
        connectorAssetName = [ASSETS_PATH_CONNECTORS stringByAppendingString:connectorAssetName];
        UIImage *connectorImage = [UIImage imageNamed:connectorAssetName];
        
        if (connectorImage) {
            [self.layer setContents:(id)connectorImage.CGImage];
        }
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
        [self addGestureRecognizer:panGesture];
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
