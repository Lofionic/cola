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

@interface ComponentShelfCollectionViewCell ()

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ComponentShelfCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
 
    self = [super initWithFrame:frame];
    
    if (self) {
        self.thumbnailImageView = [[UIImageView alloc] init];
        [self.thumbnailImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.thumbnailImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:self.thumbnailImageView];

        self.titleLabel = [[UILabel alloc] init];
        [self.titleLabel setText:@"TITLE"];
        [self.titleLabel setFont:[UIFont fontWithName:@"DINAlternate-Bold" size:12]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.titleLabel];
        
        NSDictionary *viewsDictionary = @{
                                          @"titleLabel"     :   self.titleLabel,
                                          @"thumbnail"      :   self.thumbnailImageView
                                          };
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabel]|" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[thumbnail]-|" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[thumbnail][titleLabel]-|" options:0 metrics:nil views:viewsDictionary]];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [longPress setMinimumPressDuration:0.5f];
        [longPress setCancelsTouchesInView:NO];
        [self addGestureRecognizer:longPress];
    }
    return self;
}

@synthesize moduleDescription = _moduleDescription;

-(void)setModuleDescription:(ModuleDescription *)moduleDescription {
    _moduleDescription = moduleDescription;
    [self.thumbnailImageView setImage:_moduleDescription.thumbnail];
    [self.titleLabel setText:_moduleDescription.name];
}

-(ModuleDescription*)moduleDescription {
    return _moduleDescription;
}

-(void)handleLongPress:(UIGestureRecognizer*)uigr {
    UILongPressGestureRecognizer *longPressGesture = (UILongPressGestureRecognizer*)uigr;

    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        if ([[self.componentShelf delegate] respondsToSelector:@selector(componentShelf:didBeginDraggingModule:withGesture:)]) {
            [[self.componentShelf delegate] componentShelf:self.componentShelf didBeginDraggingModule:self.moduleDescription withGesture:longPressGesture];
        }
    } else if (longPressGesture.state == UIGestureRecognizerStateChanged) {
        if ([[self.componentShelf delegate] respondsToSelector:@selector(componentShelf:didContinueDraggingModule:withGesture:)]) {
            [[self.componentShelf delegate] componentShelf:self.componentShelf didContinueDraggingModule:self.moduleDescription withGesture:longPressGesture];
        }
    } else if (longPressGesture.state == UIGestureRecognizerStateEnded) {
        if ([[self.componentShelf delegate] respondsToSelector:@selector(componentShelf:didEndDraggingModule:withGesture:)]) {
            [[self.componentShelf delegate] componentShelf:self.componentShelf didEndDraggingModule:self.moduleDescription withGesture:longPressGesture];
        }
    }
}

@end
