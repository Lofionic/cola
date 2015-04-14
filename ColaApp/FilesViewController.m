//
//  PatchesViewController.m
//  ColaApp
//
//  Created by Chris on 13/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "FilesViewController.h"
#import "PresetController.h"

@interface FilesViewController ()

@end

#define CELL_IDENTIFIER @"CELL_IDENTIFIER"

@implementation FilesViewController


-(instancetype)init {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    if (self = [super initWithCollectionViewLayout:flowLayout]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1]];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[PresetController sharedController] presetCount];
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(16, 16, 16, 16);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150, 150);
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    Preset *preset = [[PresetController sharedController] presetAtIndex:indexPath.row];
    
    UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 134, 100)];
    [thumbnailView setBackgroundColor:[UIColor lightGrayColor]];
    [cell addSubview:thumbnailView];
    
    UILabel *presetNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 110, 134, 16)];
    [presetNameLabel setText:preset.name];
    [presetNameLabel setTextAlignment:NSTextAlignmentCenter];
    [presetNameLabel setFont:[UIFont fontWithName:@"DINAlternate-Bold" size:14]];
    [presetNameLabel setTextColor:[UIColor whiteColor]];
    [cell addSubview:presetNameLabel];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 126, 134, 16)];
    [dateLabel setText:@"SaveDate"];
    [dateLabel setTextAlignment:NSTextAlignmentCenter];
    [dateLabel setFont:[UIFont fontWithName:@"DINAlternate-Bold" size:10]];
    [dateLabel setTextColor:[UIColor lightGrayColor]];
    [cell addSubview:dateLabel];
    
    if (indexPath.row == [[PresetController sharedController] selectedPresetIndex]) {
        [cell.layer setBorderWidth:2];
        [cell.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    } else {
        [cell.layer setBorderWidth:0];
    }
    
    return cell;
}

@end
