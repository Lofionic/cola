//
//  FilesViewControllerCell.h
//  ColaApp
//
//  Created by Chris on 16/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Preset.h"

@class FilesViewControllerCell;
@protocol FilesViewControllerCellDelegate <NSObject>

-(void)FilesViewControllerCellDidTapThumbnail:(FilesViewControllerCell*)cell;
-(void)FilesViewControllerCellDidTapLabel:(FilesViewControllerCell*)cell;

@end

@interface FilesViewControllerCell : UICollectionViewCell

@property (nonatomic, weak) id<FilesViewControllerCellDelegate> delegate;

@property (nonatomic, strong) NSString*         preset;
@property (readonly) UILabel*                   presetNameLabel;
@property (readonly) UILabel*                   dateLabel;
@property (readonly) UIImageView*               thumbnailView;
@property (readonly) UIActivityIndicatorView*   activityIndicator;

-(void)startJiggling;
-(void)stopJiggling;

@end
