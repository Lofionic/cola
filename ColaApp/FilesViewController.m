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
#import "FilesViewControllerCell.h"

@interface FilesViewController ()

@property (nonatomic, weak) BuildViewController *buildViewController;

@property CGSize cellSize;

@property (nonatomic) NSUInteger editingSelectedIndex;

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
    
    [self.collectionView registerClass:[FilesViewControllerCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1]];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTapped)];
    [self.navigationItem setLeftBarButtonItem:addBarButtonItem];
    
    UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTapped)];
    [self.navigationItem setRightBarButtonItem:editBarButtonItem];
    
    self.editingSelectedIndex = [[PresetController sharedController] selectedPresetIndex];
}

-(void)addTapped {
    [[PresetController sharedController] addNewPreset];
    
    NSArray *newIndexPath = @[[NSIndexPath indexPathForRow:[[PresetController sharedController] presetCount] - 1 inSection:0]];
    [self.collectionView insertItemsAtIndexPaths:newIndexPath];
}

-(void)editTapped {
    if (self.editing) {
        [self setEditing:NO animated:YES];
    } else {
        self.editingSelectedIndex = [[PresetController sharedController] selectedPresetIndex];
        [self setEditing:YES animated:YES];
    }
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [self.collectionView reloadData];
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
    FilesViewControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    Preset *preset = [[PresetController sharedController] presetAtIndex:indexPath.row];
    [cell setPreset:preset];
    [cell setEditing:self.editing];
    
    if (self.editing && self.editingSelectedIndex == indexPath.row) {
        [cell setBorder:YES];
    } else if (!self.editing && [[PresetController sharedController] selectedPresetIndex] == indexPath.row) {
        [cell setBorder:YES];
    } else {
        [cell setBorder:NO];
    }
    
    [cell updateContents];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        self.editingSelectedIndex = indexPath.row;
        [self.collectionView reloadData];
    } else {
        NSUInteger selectedIndex = indexPath.row;
        
        if (selectedIndex != [[PresetController sharedController] selectedPresetIndex]) {
            [self loadPresetAtIndex:selectedIndex];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
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
