//
//  ComponentTrayCollectionViewCell.m
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "ComponentShelfCollectionViewCell.h"
#import "ComponentShelfView.h"
#import "ModuleDescription.h"

@implementation ComponentShelfCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
 
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.thumbnailImageView = [[UIImageView alloc] init];
        [self.thumbnailImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.thumbnailImageView setContentMode:UIViewContentModeScaleAspectFit];
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
                                                                             constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbnailImageView
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.thumbnailImageView
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1
                                                                             constant:0]];
        
        UIGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:panGesture];
        
    }
    return self;
}

@synthesize moduleDescription = _moduleDescription;

-(void)setModuleDescription:(ModuleDescription *)moduleDescription {
    _moduleDescription = moduleDescription;
    [self.thumbnailImageView setImage:_moduleDescription.thumbnail];
}

-(ModuleDescription*)moduleDescription {
    return _moduleDescription;
}

-(void)handlePanGesture:(UIGestureRecognizer*)uigr {
    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)uigr;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if ([[self.componentShelf delegate] respondsToSelector:@selector(componentShelf:didBeginDraggingModule:withGesture:)]) {
            [[self.componentShelf delegate] componentShelf:self.componentShelf didBeginDraggingModule:self.moduleDescription withGesture:panGesture];
        }
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        if ([[self.componentShelf delegate] respondsToSelector:@selector(componentShelf:didContinueDraggingModule:withGesture:)]) {
            [[self.componentShelf delegate] componentShelf:self.componentShelf didContinueDraggingModule:self.moduleDescription withGesture:panGesture];
        }
    } else if (uigr.state == UIGestureRecognizerStateEnded) {
        if ([[self.componentShelf delegate] respondsToSelector:@selector(componentShelf:didEndDraggingModule:withGesture:)]) {
            [[self.componentShelf delegate] componentShelf:self.componentShelf didEndDraggingModule:self.moduleDescription withGesture:panGesture];
        }
    }
}



@end
