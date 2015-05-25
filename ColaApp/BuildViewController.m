//
//  BuildViewController.m
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "ModuleDescription.h"
#import "BuildViewController.h"
#import "KeyboardView.h"
#import "BuildView.h"
#import "ModuleView.h"
#import "ModuleCatalog.h"
#import "FilesViewController.h"
#import "PresetController.h"
#import "UIView+Snapshot.h"
#import "BuildViewScrollView.h"

static BuildView *buildView = nil;

@interface BuildViewController()

@property (nonatomic, strong) BuildViewScrollView   *buildViewScrollView;
@property (nonatomic, strong) BuildView             *buildView;

@property (nonatomic, strong) ComponentShelfView    *componentShelf;
@property (nonatomic, strong) KeyboardView          *keyboardView;
@property (nonatomic, strong) UIView                *iaaView;

@property (nonatomic, strong) UIView                *dragView;
@property (nonatomic, strong) ModuleView            *dragModule;

@property (nonatomic, strong) UIBarButtonItem       *buildBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem       *keyboardBarButtonItem;

@property (nonatomic) BOOL buildMode;
@property (nonatomic) BOOL keyboardHidden;

@property (nonatomic, strong) NSLayoutConstraint    *shiftBuildViewConstraint; // Constraint to shift the build view down when the build view appears

@property (nonatomic, strong) NSString              *filename;

@end

@implementation BuildViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];

    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ImageAssets/sunset_ipad.jpg"]];
    [backgroundView setFrame:self.view.bounds];
    [backgroundView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    [self.view addSubview:backgroundView];
    
    self.buildViewScrollView = [[BuildViewScrollView alloc] init];
    [self.buildViewScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.buildViewScrollView setClipsToBounds:YES];
    [self.view addSubview:self.buildViewScrollView];
    
    self.buildView = [[BuildView alloc] initWithScrollView:self.buildViewScrollView];
    [self.buildView setClipsToBounds:NO];
    [self.buildView setBuildViewController:self];
    [self.buildViewScrollView addSubview:self.buildView];
    [self.buildViewScrollView setDelegate:self.buildView];
//   [self.buildViewScrollView setMaximumZoomScale:2];
//   [self.buildViewScrollView setMinimumZoomScale:1];
    
    buildView = self.buildView;
    
    self.componentShelf = [[ComponentShelfView alloc] init];
    [self.componentShelf setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.componentShelf setDelegate:self];
    [self.view addSubview:self.componentShelf];
    
    self.keyboardView = [[KeyboardView alloc] init];
    [self.keyboardView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.keyboardView setKbComponent:[[COLAudioEnvironment sharedEnvironment] keyboardComponent]];
    [self.view addSubview:self.keyboardView];

    NSDictionary *viewsDictionary = @{
                                      @"buildView"      :   self.buildViewScrollView,
                                      @"componentShelf" :   self.componentShelf,
                                      @"keyboardView"   :   self.keyboardView,
                                      @"topGuide"       :   self.topLayoutGuide
                                      };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[componentShelf]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[keyboardView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    NSDictionary *metricsDictionary = @{
                                        @"buildViewWidth"       : [NSNumber numberWithFloat:kBuildViewWidth],
                                        @"componentShelfHeight" : [NSNumber numberWithFloat:kComponentShelfHeight],
                                        @"keyboardHeight"       : [NSNumber numberWithFloat:kKeyboardHeight]
                                        };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide][componentShelf(componentShelfHeight)]"
                                                                      options:0
                                                                      metrics:metricsDictionary
                                                                        views:viewsDictionary]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[keyboardView(keyboardHeight)]|"
                                                                      options:0
                                                                      metrics:metricsDictionary
                                                                        views:viewsDictionary]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buildViewScrollView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:kBuildViewWidth]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buildViewScrollView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0@750-[buildView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    self.shiftBuildViewConstraint = [NSLayoutConstraint constraintWithItem:self.buildViewScrollView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:self.componentShelf
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:0];
    
    [self.shiftBuildViewConstraint setPriority:UILayoutPriorityRequired];
    [self.view addConstraint:self.shiftBuildViewConstraint];
    
    UIImage *wrenchIcon = [UIImage imageNamed:TOOLBAR_BUILD_ICON];
    self.buildBarButtonItem = [[UIBarButtonItem alloc] initWithImage:wrenchIcon style:UIBarButtonItemStylePlain target:self action:@selector(editTapped)];
    [self setBuildMode:NO animated:NO];
    
    UIImage *keyboardIcon = [UIImage imageNamed:TOOLBAR_PIANO_ICON];
    self.keyboardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:keyboardIcon style:UIBarButtonItemStylePlain target:self action:@selector(keyboardTapped)];
    [self.navigationItem setLeftBarButtonItems:@[self.buildBarButtonItem, self.keyboardBarButtonItem]];
    [self setKeyboardHidden:NO animated:NO];
    
    UIImage *filesIcon = [UIImage imageNamed:TOOLBAR_FILES_ICON];
    UIBarButtonItem *filesButton = [[UIBarButtonItem alloc] initWithImage:filesIcon style:UIBarButtonItemStylePlain target:self action:@selector(filesTapped)];
    [self.navigationItem setRightBarButtonItem:filesButton];
    
    self.iaaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 512, 512)];
    [self.iaaView setBackgroundColor:[UIColor redColor]];
    [self.iaaView setHidden:YES];
    [self.view addSubview:self.iaaView];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appWillEnterForeground)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    Preset *preset = [[PresetController sharedController] recallPresetAtIndex:0];
    [self.buildView buildFromDictionary:preset.dictionary];
}

-(void)appWillEnterForeground {
    if ([[COLAudioEnvironment sharedEnvironment] isInterAppAudioConnected]) {
        [self.iaaView setHidden:NO];
    } else {
        [self.iaaView setHidden:YES];
    }
}

#pragma mark Toolbar

-(void)editTapped {
    if (!self.buildMode) {
        [self setBuildMode:YES animated:YES];
    } else {
        [self setBuildMode:NO animated:YES];
    }
}

-(void)keyboardTapped {
    if (!self.keyboardHidden) {
        [self setKeyboardHidden:YES animated:YES];
    } else {
        [self setKeyboardHidden:NO animated:YES];
    }
}

-(void)filesTapped {
    if (self.buildMode) {
        [self setBuildMode:NO animated:YES];
    }
    
    [[[COLAudioEnvironment sharedEnvironment] keyboardComponent] allNotesOff];
    
    UIView *blockingView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    [blockingView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [self.navigationController.view addSubview:blockingView];
    
    [self savePresetCompletion:^(BOOL success) {
        [blockingView removeFromSuperview];
        FilesViewController *filesViewController = [[FilesViewController alloc] initWithBuildViewController:self];
        [self.navigationController pushViewController:filesViewController animated:YES];
    }];
}

-(void)setBuildMode:(BOOL)buildMode animated:(BOOL)animated {
    self.buildMode = buildMode;
    if (buildMode) {
        // show shelf
        if (animated) {
            [self.shiftBuildViewConstraint setActive:YES];
            [UIView animateWithDuration:0.2 animations:^ {
                [self.componentShelf setTransform:CGAffineTransformIdentity];
                [self.view layoutIfNeeded];

            }];

        } else {
            [self.componentShelf setTransform:CGAffineTransformIdentity];
            [self.shiftBuildViewConstraint setActive:YES];
        }
        [self.buildBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_BUILD_ICON_SELECTED]];
    } else {
        // Hide shelf
        if (animated) {
            [self.shiftBuildViewConstraint setActive:NO];
            [UIView animateWithDuration:0.2 animations:^ {
                [self.componentShelf setTransform:CGAffineTransformMakeTranslation(0, -kComponentShelfHeight - 40.0)];
                [self.view layoutIfNeeded];
            }];
        } else {
            [self.componentShelf setTransform:CGAffineTransformMakeTranslation(0, -kComponentShelfHeight - 40.0)];
            [self.shiftBuildViewConstraint setActive:NO];
        }
        [self.buildBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_BUILD_ICON]];
    }
}

-(void)setKeyboardHidden:(BOOL)keyboardHidden animated:(BOOL)animated {
    self.keyboardHidden = keyboardHidden;
    if (keyboardHidden) {
        // Hide keyboard
        UIEdgeInsets buildviewEdgeInsets = [self.buildViewScrollView contentInset];
        buildviewEdgeInsets.bottom = 0;
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^ {
                [self.keyboardView setTransform:CGAffineTransformMakeTranslation(0, kKeyboardHeight)];
                [self.buildViewScrollView setContentInset:buildviewEdgeInsets];
                [self.buildViewScrollView setScrollIndicatorInsets:buildviewEdgeInsets];

            }];
        } else {
            [self.keyboardView setTransform:CGAffineTransformMakeTranslation(0, kKeyboardHeight)];
            [self.buildViewScrollView setContentInset:buildviewEdgeInsets];
            [self.buildViewScrollView setScrollIndicatorInsets:buildviewEdgeInsets];
        }
        [self.keyboardBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_PIANO_ICON]];
    } else {
        UIEdgeInsets buildviewEdgeInsets = [self.buildViewScrollView contentInset];
        buildviewEdgeInsets.bottom = kKeyboardHeight;
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^ {
                [self.keyboardView setTransform:CGAffineTransformIdentity];
                [self.buildViewScrollView setContentInset:buildviewEdgeInsets];
                [self.buildViewScrollView setScrollIndicatorInsets:buildviewEdgeInsets];
            }];
        } else {
            [self.keyboardView setTransform:CGAffineTransformIdentity];
            [self.buildViewScrollView setContentInset:buildviewEdgeInsets];
            [self.buildViewScrollView setScrollIndicatorInsets:buildviewEdgeInsets];
        }
        [self.keyboardBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_PIANO_ICON_SELECTED]];
    }
}

#pragma mark ComponentShelf

-(void)componentShelf:(ComponentShelfView *)componentTray didBeginDraggingModule:(ModuleDescription*)module withGesture:(UIGestureRecognizer *)gesture {
    
    CGPoint dragPoint = [gesture locationInView:self.view];

    self.dragView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, module.thumbnail.size.width, module.thumbnail.size.height)];
    [self.dragView setCenter:dragPoint];
    [self.dragView setUserInteractionEnabled:NO];
    [self.dragView.layer setOpacity:0.5];
    [self.dragView.layer setContents:(id)[module.thumbnail CGImage]];
    
    [self.buildViewScrollView setEnableAutoscroll:YES];
    
    [self.view addSubview:self.dragView];
}

-(void)componentShelf:(ComponentShelfView *)componentTray didContinueDraggingModule:(ModuleDescription*)module withGesture:(UIGestureRecognizer *)gesture {
    
    CGPoint dragPoint = [gesture locationInView:self.view];
    [self.dragView setCenter:dragPoint];
    
    BOOL occupied;
    NSSet *hoverSet = [self.buildView cellPathsForModuleOfWidth:module.width center:[gesture locationInView:self.buildView] occupied:&occupied];
    
    if (hoverSet && !occupied && [self.view hitTest:dragPoint withEvent:nil] == self.buildView) {
        [self.buildView setHighlightedCellSet:hoverSet];
    } else {
        [self.buildView setHighlightedCellSet:nil];
    }
    
}

-(void)componentShelf:(ComponentShelfView *)componentTray didEndDraggingModule:(ModuleDescription*)module withGesture:(UIGestureRecognizer *)gesture {
    [self.dragView removeFromSuperview];
    [self.buildView setHighlightedCellSet:nil];
    
    [self.buildViewScrollView setEnableAutoscroll:NO];
    
    if (gesture.state != UIGestureRecognizerStateCancelled ){
        CGPoint pointInWindow = [gesture locationInView:self.view];
        // Don't drop if drag is likely to have gone off-screen
        if (pointInWindow.x > 8 &&
            pointInWindow.x < self.view.frame.size.width - 8 &&
            pointInWindow.y > 8 &&
            pointInWindow.y < self.view.frame.size.height - 8) {
            if ([self.view hitTest:pointInWindow withEvent:nil] == self.buildView) {
                // Add a component
                [self.buildView addViewForModule:module atPoint:[gesture locationInView:self.buildView] identifier:nil];
            }
        }
    }
}

#pragma LoadSave

-(void)savePresetCompletion:(void (^)(BOOL success))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^ {
        UIImage *thumbnail = [self.buildView snapshot];
        NSDictionary *dictionary = [self.buildView getPresetDictionary];
        
        [[PresetController sharedController] updatePresetAtIndex:[[PresetController sharedController] selectedPresetIndex]
                                                  withDictionary:dictionary
                                                            name:nil
                                                       thumbnail:thumbnail];
       
        dispatch_async(dispatch_get_main_queue(), ^ {
            completion(YES);
        });
    });
}

-(void)recallPreset:(Preset*)preset completion:(void (^)(BOOL success))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL success = [self.buildView buildFromDictionary:preset.dictionary];
        if (completion) {
            completion(success);
        }
    });
}

#pragma mark Convenience Methods

+(BuildView*)buildView {
    return buildView;
}

@end
