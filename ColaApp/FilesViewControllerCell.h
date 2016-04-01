//
//  FilesViewControllerCell.h
//  ColaApp
//
//  Created by Chris on 16/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresetController.h"

@class FilesViewControllerCell;
@protocol FilesViewControllerCellDelegate <NSObject>

-(void)FilesViewControllerCellDidTapThumbnail:(FilesViewControllerCell*)cell;
-(void)FilesViewControllerCellDidTapLabel:(FilesViewControllerCell*)cell;

@end

@interface FilesViewControllerCell : UICollectionViewCell

@property (nonatomic, weak) id<FilesViewControllerCellDelegate> delegate;
@property (nonatomic) NSInteger presetIndex;

-(void)updateContents;
-(void)startJiggling;
-(void)stopJiggling;

@end
