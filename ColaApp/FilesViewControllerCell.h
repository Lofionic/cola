//
//  FilesViewControllerCell.h
//  ColaApp
//
//  Created by Chris on 16/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresetController.h"

@interface FilesViewControllerCell : UICollectionViewCell

@property (nonatomic, weak) Preset *preset;
@property (nonatomic) NSInteger presetIndex;

-(void)updateContents;
-(void)startJiggling;
-(void)stopJiggling;

@end
