//
//  ConnectorView.h
//  ColaApp
//
//  Created by Chris on 22/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <ColaLib/ColaLib.h>
#import <UIKit/UIKit.h>

@class ConnectorView;

@protocol ConnectorViewDelegate <NSObject>

-(void)connectorView:(ConnectorView*)connectorView didBeginDrag:(UIPanGestureRecognizer*)uigr;
-(void)connectorView:(ConnectorView *)connectorView didContinueDrag:(UIPanGestureRecognizer *)uigr;
-(void)connectorView:(ConnectorView *)connectorView didEndDrag:(UIPanGestureRecognizer *)uigr;

@end

@interface ConnectorView : UIView

@property (nonatomic, weak) id<ConnectorViewDelegate>   delegate;
@property (readonly, weak) COLComponentIO *             componentIO;

-(instancetype)initWithComponentIO:(COLComponentIO*)componentIO;

@end
