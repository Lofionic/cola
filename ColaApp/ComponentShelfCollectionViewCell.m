//
//  ComponentShelfCollectionViewCell.m
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "ComponentShelfCollectionViewCell.h"

@implementation ComponentShelfCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
 
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.thumbnailImageView = [[UIImageView alloc] init];
        [self.thumbnailImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.thumbnailImageView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbnailImageView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbnailImageView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbnailImageView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:0.8
                                                                             constant:1]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbnailImageView
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.thumbnailImageView
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:2 / 3.0
                                                                             constant:1]];
        
        UIGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:panGesture];
        
    }
    return self;
}

-(void)handlePanGesture:(UIGestureRecognizer*)uigr {
    if (uigr.state == UIGestureRecognizerStateBegan) {
        [self.thumbnailImageView setHidden:YES];
    } else if (uigr.state == UIGestureRecognizerStateEnded) {
        [self.thumbnailImageView setHidden:NO];
    }
}

@end
