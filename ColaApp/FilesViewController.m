//
//  PatchesViewController.m
//  ColaApp
//
//  Created by Chris on 13/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "FilesViewController.h"
#import "PresetController.h"
#import "BuildViewController.h"

@interface FilesViewController ()

@property (nonatomic, weak) BuildViewController *buildViewController;
@property CGSize cellSize;

@end

#define CELL_IDENTIFIER @"CELL_IDENTIFIER"

@implementation FilesViewController


-(instancetype)initWithBuildViewController:(BuildViewController*)buildViewController {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    if (self = [super initWithCollectionViewLayout:flowLayout]) {
        self.buildViewController = buildViewController;
        self.cellSize = CGSizeMake(180, 180);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Files"];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1]];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTapped)];
    [self.navigationItem setLeftBarButtonItem:addBarButtonItem];
    
    UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTapped)];
    [self.navigationItem setRightBarButtonItem:editBarButtonItem];
}

-(void)addTapped {
    [[PresetController sharedController] addNewPreset];
    
    NSArray *newIndexPath = @[[NSIndexPath indexPathForRow:[[PresetController sharedController] presetCount] - 1 inSection:0]];
    [self.collectionView insertItemsAtIndexPaths:newIndexPath];
}

-(void)editTapped {
    
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
    return self.cellSize;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    Preset *preset = [[PresetController sharedController] presetAtIndex:indexPath.row];
    
    UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, self.cellSize.width - 16, self.cellSize.height - 50)];
    [thumbnailView setBackgroundColor:[UIColor clearColor]];
    [thumbnailView setContentMode:UIViewContentModeScaleAspectFit];
    if (preset.thumbnail) {
        [thumbnailView setImage:preset.thumbnail];
    }
    [cell addSubview:thumbnailView];
    
    UILabel *presetNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, self.cellSize.height - 40, self.cellSize.width - 16, 16)];
    [presetNameLabel setText:preset.name];
    [presetNameLabel setTextAlignment:NSTextAlignmentCenter];
    [presetNameLabel setFont:[UIFont fontWithName:@"DINAlternate-Bold" size:14]];
    [presetNameLabel setTextColor:[UIColor whiteColor]];
    [cell addSubview:presetNameLabel];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.doesRelativeDateFormatting = YES;
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, self.cellSize.height - 24, self.cellSize.width - 16, 16)];
    [dateLabel setText:[dateFormatter stringFromDate:preset.saveDate]];
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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger selectedIndex = indexPath.row;
    
    if (selectedIndex != [[PresetController sharedController] selectedPresetIndex]) {
        [self loadPresetAtIndex:selectedIndex];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)loadPresetAtIndex:(NSUInteger)index {
    Preset *selectedPreset = [[PresetController sharedController] recallPresetAtIndex:index];
    [self.collectionView reloadData];
    
    UIView *blockingView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    [blockingView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [self.navigationController.view addSubview:blockingView];
    
    [self.buildViewController recallPreset:selectedPreset completion:^(BOOL success) {
        [blockingView removeFromSuperview];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
