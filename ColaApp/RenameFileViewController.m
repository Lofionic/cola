//
//  RenameFileViewController.m
//  ColaApp
//
//  Created by Chris on 01/04/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import "RenameFileViewController.h"
#import "PresetController.h"

@interface RenameFileViewController ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *keyboardView;
@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, strong) NSLayoutConstraint *keyboardHeightConstraint;

@end

@implementation RenameFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeTop];
    [self setTitle:@"Rename File"];
    
    [self.navigationItem setHidesBackButton:true];

    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)];
    [self.navigationItem setRightBarButtonItem:self.doneButton];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"wallpaper"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile]];
    [backgroundView setFrame:self.view.bounds];
    [backgroundView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    [self.view addSubview:backgroundView];
    
    self.containerView = [[UIView alloc] init];
    [self.containerView setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.view addSubview:self.containerView];
    
    self.keyboardView = [[UIView alloc] init];
    [self.keyboardView setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.view addSubview:self.keyboardView];
    
    self.thumbnailView = [[UIImageView alloc] init];
    [self.thumbnailView setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.thumbnailView setContentMode:UIViewContentModeScaleAspectFit];
    [self.containerView addSubview:self.thumbnailView];
    
    self.textField = [[UITextField alloc] init];
    [self.textField setBackgroundColor:[UIColor darkGrayColor]];
    [self.textField setTextColor:[UIColor whiteColor]];
    [self.textField setTextAlignment:NSTextAlignmentCenter];
    [self.textField setClearButtonMode:UITextFieldViewModeAlways];
    [self.textField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.textField setReturnKeyType:UIReturnKeyDone];
    [self.textField setDelegate:self];
    
//    [self.textField.layer setCornerRadius:4.0];
    [self.textField setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.containerView addSubview:self.textField];
    
    NSDictionary *viewsDictionary = @{
                                      @"top"       : self.topLayoutGuide,
                                      @"bottom"    : self.bottomLayoutGuide,
                                      @"container" : self.containerView,
                                      @"keyboard"  : self.keyboardView,
                                      @"thumbnail" : self.thumbnailView,
                                      @"textfield" : self.textField
                                      };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[container]|" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[keyboard]|" options:0 metrics:nil views:viewsDictionary]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[top][container][keyboard]|" options:0 metrics:nil views:viewsDictionary]];

    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[thumbnail]-|" options:0 metrics:nil views:viewsDictionary]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textfield(300)]" options:0 metrics:nil views:viewsDictionary]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[thumbnail]-20-[textfield]-20-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewsDictionary]];

    self.keyboardHeightConstraint = [NSLayoutConstraint constraintWithItem:self.keyboardView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:128];
    [self.view addConstraint:self.keyboardHeightConstraint];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.textField setText:[[PresetController sharedController] nameOfPresetAtIndex:self.presetIndex]];
    [[PresetController sharedController] fetchThumbnailForPresetAtIndex:self.presetIndex onCompletion:^(NSUInteger index, UIImage *image) {
        if (index == self.presetIndex) {
            [self.thumbnailView setImage:image];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.textField becomeFirstResponder];
}

- (void)keyboardWillShowNotification:(NSNotification*)note {
    CGRect keyboardEndFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self.keyboardHeightConstraint setConstant:keyboardEndFrame.size.height];
}

-(void)keyboardWillHideNotification:(NSNotification*)note {
    [self dismissMe];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

- (void)doneTapped {
    [self dismissMe];
}

-(void)dismissMe {
    [[PresetController sharedController] renameFileAtIndex:self.presetIndex to:self.textField.text];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
