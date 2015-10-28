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
#import "IAAView.h"

static BuildView *buildView = nil;

@interface BuildViewController()

@property (nonatomic, strong) BuildViewScrollView   *buildViewScrollView;
@property (nonatomic, strong) BuildView             *buildView;

@property (nonatomic, strong) ComponentShelfView    *componentShelf;
@property (nonatomic, strong) KeyboardView          *keyboardView;

@property (nonatomic, strong) IAAView               *iaaView;

@property (nonatomic, strong) UIView                *dragView;
@property (nonatomic, strong) ModuleView            *dragModule;

@property (nonatomic, strong) UIBarButtonItem       *buildBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem       *keyboardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem       *playStopBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem       *saveBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem       *filesBarButtonItem;

@property (nonatomic, strong) NSLayoutConstraint    *keyboardPositionConstraint;
@property (nonatomic, strong) NSLayoutConstraint    *iaaPositionConstraint;

@property (nonatomic) BOOL buildMode;
@property (nonatomic) BOOL keyboardHidden;

@property (nonatomic, strong) NSLayoutConstraint    *shiftBuildViewConstraint; // Constraint to shift the build view down when the build view appears

@property (nonatomic, strong) Preset *preset;

@end

@implementation BuildViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];

    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"wallpaper"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile]];
    [backgroundView setFrame:self.view.bounds];
    [backgroundView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    [self.view addSubview:backgroundView];
    
    self.buildViewScrollView = [[BuildViewScrollView alloc] init];
    [self.buildViewScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.buildViewScrollView];
    
    self.buildView = [[BuildView alloc] initWithScrollView:self.buildViewScrollView];
    [self.buildView setClipsToBounds:NO];
    [self.buildView setBuildViewController:self];
    [self.buildViewScrollView addSubview:self.buildView];
    [self.buildViewScrollView setDelegate:self.buildView];
    buildView = self.buildView;
    
    self.componentShelf = [[ComponentShelfView alloc] init];
    [self.componentShelf setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.componentShelf setDelegate:self];
    [self.view addSubview:self.componentShelf];
    
    self.keyboardView = [[KeyboardView alloc] init];
    [self.keyboardView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.keyboardView setKbComponent:[[COLAudioEnvironment sharedEnvironment] keyboardComponent]];
    [self.view addSubview:self.keyboardView];
    
    self.iaaView = [[IAAView alloc] init];
    [self.iaaView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.iaaView setHidden:YES];
    [self.view addSubview:self.iaaView];

    NSDictionary *viewsDictionary = @{
                                      @"buildView"      :   self.buildViewScrollView,
                                      @"componentShelf" :   self.componentShelf,
                                      @"keyboardView"   :   self.keyboardView,
                                      @"iaaView"        :   self.iaaView,
                                      @"topGuide"       :   self.topLayoutGuide,
                                      @"bottomGuide"    :   self.bottomLayoutGuide
                                      };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[componentShelf]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[keyboardView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[iaaView]|"
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
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buildViewScrollView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:kBuildViewWidth + (kBuildViewPadding * 2.0)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buildViewScrollView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    // Constraints used to show / hide keyboard & iaaview
    self.iaaPositionConstraint = [NSLayoutConstraint constraintWithItem:self.iaaView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.keyboardView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:0];
    
    self.keyboardPositionConstraint = [NSLayoutConstraint constraintWithItem:self.keyboardView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.bottomLayoutGuide
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0];
    
    [self.view addConstraint:self.iaaPositionConstraint];
    [self.view addConstraint:self.keyboardPositionConstraint];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.keyboardView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:kKeyboardHeight]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0@750-[buildView][iaaView]"
                                                                      options:0
                                                                      metrics:metricsDictionary
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
    
    UIImage *playIcon = [UIImage imageNamed:TOOLBAR_PLAY_ICON];
    self.playStopBarButtonItem = [[UIBarButtonItem alloc] initWithImage:playIcon style:UIBarButtonItemStylePlain target:self action:@selector(playStopTapped)];

    [self.navigationItem setLeftBarButtonItems:@[self.buildBarButtonItem, self.keyboardBarButtonItem, self.playStopBarButtonItem]];
    
    UIImage *filesIcon = [UIImage imageNamed:TOOLBAR_FILES_ICON];
    self.filesBarButtonItem = [[UIBarButtonItem alloc] initWithImage:filesIcon style:UIBarButtonItemStylePlain target:self action:@selector(filesTapped)];
    
    UIImage *saveIcon = [UIImage imageNamed:TOOLBAR_SAVE_ICON];
    self.saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:saveIcon style:UIBarButtonItemStylePlain target:self action:@selector(saveTapped)];
    
    [self.navigationItem setRightBarButtonItems:@[self.filesBarButtonItem, self.saveBarButtonItem]];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appWillEnterForeground)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    // Setup initial view
    [self setKeyboardHidden:NO animated:NO];
    [self setIaaViewHidden:YES];
    
    // Load initial preset
    self.preset = [[PresetController sharedController] recallPresetAtIndex:0];
    [self.buildView buildFromDictionary:[self.preset dictionary]];
    
    // Register for updates form the transport controller
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedOfTransportUpdate:) name:kCOLEventTransportStateUpdated object:nil];

    // We need to know when a dynamic input has disconnected its linked outputs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dynamicInputDidForceDisconnect:) name:kCOLEventDynamicInputDidForceDisconnect object:nil];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[COLAudioEnvironment sharedEnvironment] unmute];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[[COLAudioEnvironment sharedEnvironment] transportController] stop];
    [[[COLAudioEnvironment sharedEnvironment] transportController] stopAndReset];
    [[COLAudioEnvironment sharedEnvironment] mute];
}


-(void)appWillEnterForeground {
    if ([[COLAudioEnvironment sharedEnvironment] isInterAppAudioConnected]) {
        [self setIaaViewHidden:NO];
        [self.playStopBarButtonItem setEnabled:NO];
    } else {
        [self setIaaViewHidden:YES];
        [self.playStopBarButtonItem setEnabled:YES];
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
    
    [self savePresetCompletion:^(BOOL success) {
        FilesViewController *filesViewController = [[FilesViewController alloc] initWithBuildViewController:self];
        [self.navigationController pushViewController:filesViewController animated:YES];
    }];
}

-(void)saveTapped {
    [[COLAudioEnvironment sharedEnvironment] exportEnvironment];
    
    if (self.buildMode) {
        [self setBuildMode:NO animated:YES];
    }
    
    [self savePresetCompletion:nil];
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


-(void)setIaaViewHidden:(BOOL)hidden {
    [self.iaaView setHidden:hidden];
    if (hidden) {
        [self.iaaPositionConstraint setConstant:58];
    } else {
        [self.iaaView updateContents];
        [self.iaaPositionConstraint setConstant:0];
    }
}


-(void)setKeyboardHidden:(BOOL)keyboardHidden animated:(BOOL)animated {
    self.keyboardHidden = keyboardHidden;
    if (keyboardHidden) {
        // Hide keyboard
        if (animated) {
            [UIView animateWithDuration:0.2f animations:^ {
                [self.keyboardPositionConstraint setConstant:kKeyboardHeight];
                [self.view layoutIfNeeded];
            }];
        } else {
            [self.keyboardPositionConstraint setConstant:kKeyboardHeight];
        }
        [self.keyboardBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_PIANO_ICON]];
    } else {
        // Show keyboard
        if (animated) {
            [UIView animateWithDuration:0.2f animations:^ {
                [self.keyboardPositionConstraint setConstant:0];
                [self.view layoutIfNeeded];
            }];
        } else {
            [self.keyboardPositionConstraint setConstant:0];
        }
        [self.keyboardBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_PIANO_ICON_SELECTED]];
    }
}

#pragma mark Transport

-(void)playStopTapped {
    COLTransportController *transport = [[COLAudioEnvironment sharedEnvironment] transportController];
    if (transport.isPlaying) {
        [transport stopAndReset];
    } else {
        [transport start];
    }
}

-(void)notifiedOfTransportUpdate:(NSNotification*)note {
    
    __weak BuildViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [weakSelf.iaaView updateContents];
        
        if ([[[COLAudioEnvironment sharedEnvironment] transportController] isPlaying]) {
            [weakSelf.playStopBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_STOP_ICON]];
        } else {
            [weakSelf.playStopBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_PLAY_ICON]];
        }
    });
}

-(void)dynamicInputDidForceDisconnect:(NSNotification*)note {
    [self.buildView forceDisconnect:note.userInfo];
    
}

#pragma mark ComponentShelf

-(void)componentShelf:(ComponentShelfView *)componentTray didBeginDraggingModule:(ModuleDescription*)module withGesture:(UIGestureRecognizer *)gesture {
    
    CGPoint dragPoint = [gesture locationInView:self.view];

    self.dragView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, module.thumbnail.size.width, module.thumbnail.size.height)];
    [self.dragView setCenter:dragPoint];
    [self.dragView setUserInteractionEnabled:NO];
    [self.dragView.layer setOpacity:0.5];
    [self.dragView.layer setContents:(id)[module.thumbnail CGImage]];

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
    
    UIView *blockingView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    [blockingView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.6]];
    [self.navigationController.view addSubview:blockingView];
    
    UILabel *blockingViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                           (blockingView.bounds.size.height / 2.0) - 64.0,
                                                                           blockingView.bounds.size.width,
                                                                           64)];
    [blockingViewLabel setTextAlignment:NSTextAlignmentCenter];
    [blockingViewLabel setTextColor:[UIColor whiteColor]];
    [blockingViewLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
    [blockingViewLabel setText:@"Saving..."];
    [blockingView addSubview:blockingViewLabel];
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(blockingView.bounds.size.width / 2.0 - 100,
                                                                                    blockingView.bounds.size.height / 2.0,
                                                                                    200,
                                                                                    64)];
    [progressView setProgress:0.0];
    [blockingView addSubview:progressView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^ {
        UIImage *thumbnail = [self.buildViewScrollView snapshot];
        NSDictionary *dictionary = [self.buildView getPresetDictionary];
        
        [[PresetController sharedController] updatePresetAtIndex:[[PresetController sharedController] selectedPresetIndex]
                                                  withDictionary:dictionary
                                                            name:nil
                                                       thumbnail:thumbnail
                                                        progress:^ (float progress){
                                                            [progressView setProgress:progress animated:YES];;
                                                        }];
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (completion) {
                completion(YES);
            }
            [blockingView removeFromSuperview];
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

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
