//
//  FilesViewControllerCell.m
//  ColaApp
//
//  Created by Chris on 16/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "FilesViewControllerCell.h"
@interface FilesViewControllerCell()

@property (nonatomic, strong) UIImageView   *thumbnailView;
@property (nonatomic, strong) UILabel       *presetNameLabel;
@property (nonatomic, strong) UILabel       *dateLabel;
@property (nonatomic, strong) UIImageView   *deleteImage;

@end

@implementation FilesViewControllerCell

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, frame.size.width - 16, frame.size.height - 50)];
        [self.thumbnailView setBackgroundColor:[UIColor clearColor]];
        [self.thumbnailView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:self.thumbnailView];
        
        self.presetNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, frame.size.height - 40, frame.size.width - 16, 16)];
        [self.presetNameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.presetNameLabel setFont:[UIFont fontWithName:@"DINAlternate-Bold" size:14]];
        [self.presetNameLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:self.presetNameLabel];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, frame.size.height - 24, frame.size.width - 16, 16)];
        [self.dateLabel setTextAlignment:NSTextAlignmentCenter];
        [self.dateLabel setFont:[UIFont fontWithName:@"DINAlternate-Bold" size:10]];
        [self.dateLabel setTextColor:[UIColor lightGrayColor]];
        [self addSubview:self.dateLabel];
        
        self.deleteImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self.deleteImage setImage:[UIImage imageNamed:CROSS_ICON]];
        [self.deleteImage setContentMode:UIViewContentModeCenter];
        [self addSubview:self.deleteImage];
    }
    return self;
}

-(void)updateContents {
    
    if (self.preset.thumbnail) {
        [self.thumbnailView setImage:self.preset.thumbnail];
    }
    
    [self.presetNameLabel setText:self.preset.name];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.doesRelativeDateFormatting = YES;
    [self.dateLabel setText:[dateFormatter stringFromDate:self.preset.saveDate]];
    
    if (self.editing) {
        [self.deleteImage setHidden:NO];
    } else {
        [self.deleteImage setHidden:YES];
    }
    
    if (self.border) {
        [self.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.layer setBorderWidth:2.0];
    } else {
        [self.layer setBorderWidth:0];
    }
}

@end
