//
//  PatchesViewController.m
//  ColaApp
//
//  Created by Chris on 13/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "FilesViewController.h"
#import "BuildViewController.h"
#import "RenameFileViewController.h"

#define FILE_EXTENSION @"col"
#define DEFAULT_FILE_NAME @"New File.%@"
#define DEFAULT_FILE_NAME_OVERFLOW @"New File %d.%@"

@interface FilesViewController ()

@property (nonatomic, weak) BuildViewController *buildViewController;

@property CGSize cellSize;

@property (nonatomic, strong) UIBarButtonItem *editBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *addBarButtonItem;

@property (nonatomic, strong) UIBarButtonItem *exportBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *trashBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *duplicateBarButtonItem;

@property (nonatomic, strong) NSArray *editBarButtonItems;

@property (nonatomic, strong) NSArray *files;

@end

#define CELL_IDENTIFIER @"CELL_IDENTIFIER"

@implementation FilesViewController

-(instancetype)initWithBuildViewController:(BuildViewController*)buildViewController {
        
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    [flowLayout setMinimumInteritemSpacing:10];
    [flowLayout setMinimumLineSpacing:20];
    
    if (self = [super initWithCollectionViewLayout:flowLayout]) {
        self.buildViewController = buildViewController;
        self.cellSize = CGSizeMake(170, 250);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Files"];
    
    [self.collectionView registerClass:[FilesViewControllerCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];

    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"wallpaper"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile]];
    [backgroundView setFrame:self.view.bounds];
    [backgroundView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    [self.collectionView setBackgroundView:backgroundView];
    
    self.addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTapped)];
    [self.navigationItem setLeftBarButtonItem:self.addBarButtonItem];
    
    self.editBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(editTapped)];
    [self.navigationItem setRightBarButtonItem:self.editBarButtonItem];
    
    self.exportBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:nil];
    self.trashBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashTapped)];
    
    UIImage* copyImage = [UIImage imageNamed:TOOLBAR_COPY_ICON];
    self.duplicateBarButtonItem = [[UIBarButtonItem alloc] initWithImage:copyImage style:UIBarButtonItemStylePlain target:self action:nil];
    self.editBarButtonItems = @[self.exportBarButtonItem, self.duplicateBarButtonItem, self.trashBarButtonItem];
    
    [self.collectionView setAllowsMultipleSelection:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [self refreshFiles];
    [self.collectionView reloadData];
}

-(void)refreshFiles {
    self.files = [Preset getPresets];
    [self sortFiles];
}

- (NSString*)presetsPath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *presetsPath = documentsPath;
    return presetsPath;
}

-(NSString*)fullPathForFilename:(NSString*)filename {
    return [[self presetsPath] stringByAppendingPathComponent:filename];
}

-(void)sortFiles {
    // Sort files by date modified
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSMutableArray *fileInfos = [[NSMutableArray alloc] initWithCapacity:self.files.count];
    for (NSString *thisFile in self.files) {
        NSError* error;
        NSDictionary *properties = [fm attributesOfItemAtPath:[self fullPathForFilename:thisFile] error:&error];
        if (error) {
            NSLog(@"PresetController: Error reading properties of file %@. %@", thisFile, error.debugDescription);
        } else {
            NSDate *modDate = [properties objectForKey:NSFileModificationDate];
            [fileInfos addObject:@{
                                   @"file" : thisFile,
                                   @"date" : modDate
                                   }];
        }
    }
    
    NSArray* sortedFileInfos = [fileInfos sortedArrayUsingComparator:
                                ^(id path1, id path2)
                                {
                                    // compare
                                    NSComparisonResult comp = [[path1 objectForKey:@"date"] compare:
                                                               [path2 objectForKey:@"date"]];
                                    // invert ordering
                                    if (comp == NSOrderedDescending) {
                                        comp = NSOrderedAscending;
                                    }
                                    else if(comp == NSOrderedAscending){
                                        comp = NSOrderedDescending;
                                    }
                                    return comp;
                                }];
    
    NSMutableArray *sortedFiles = [[NSMutableArray alloc] initWithCapacity:sortedFileInfos.count];
    
    for (NSDictionary *thisDictionary in sortedFileInfos) {
        [sortedFiles addObject:[thisDictionary objectForKey:@"file"]];
    }
    
    self.files = [NSArray arrayWithArray:sortedFiles];
}


-(void)addTapped {
    [self.addBarButtonItem setEnabled:false];
    [self.editBarButtonItem setEnabled:false];
    
    [self.buildViewController clear];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)editTapped {
    if (self.editing) {
        [self setEditing:NO animated:YES];
    } else {
        [self.trashBarButtonItem setEnabled:NO];
        [self.exportBarButtonItem setEnabled:NO];
        [self.duplicateBarButtonItem setEnabled:NO];
        [self setEditing:YES animated:YES];
    }
}

-(void)trashTapped {
    
    [self.collectionView performBatchUpdates:^ {
        for (NSIndexPath *thisIndexPath in [self.collectionView indexPathsForSelectedItems]) {
            NSString *filename = [self.files objectAtIndex:thisIndexPath.row];
            if ([Preset removePreset:filename]) {
                [self.collectionView deleteItemsAtIndexPaths:@[thisIndexPath]];
                NSMutableArray *mutableFiles = [self.files mutableCopy];
                [mutableFiles removeObject:filename];
                self.files = [NSArray arrayWithArray:mutableFiles];
            }
        }
    } completion:nil];
    
    [self.trashBarButtonItem setEnabled:NO];
    [self.exportBarButtonItem setEnabled:NO];
    [self.duplicateBarButtonItem setEnabled:NO];
    
    [self setEditing:NO animated:YES];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if (editing) {
        [self.editBarButtonItem setTitle:@"Done"];
        [self.navigationItem setLeftBarButtonItems:self.editBarButtonItems animated:YES];
        for (FilesViewControllerCell *thisCell in [self.collectionView visibleCells]) {
            [thisCell startJiggling];
            [thisCell setSelected:NO];
        }        
    } else {
        [self.editBarButtonItem setTitle:@"Select"];
        [self.navigationItem setLeftBarButtonItems:@[self.addBarButtonItem] animated:YES];
        [self deselectAll];
        for (FilesViewControllerCell *thisCell in [self.collectionView visibleCells]) {
            [thisCell stopJiggling];
            [thisCell setSelected:NO];
        }
    }
}

-(void)deselectAll {
    for (NSIndexPath *thisIndexPath in [self.collectionView indexPathsForSelectedItems]) {
        [self.collectionView deselectItemAtIndexPath:thisIndexPath animated:NO];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.files count];
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(16, 16, 16, 16);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellSize;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    FilesViewControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    [cell setPreset:[self.files objectAtIndex:indexPath.row]];

    
    [cell setDelegate:self];
    [cell setHighlighted:NO];
    [cell setSelected:[[self.collectionView indexPathsForSelectedItems] containsObject:indexPath]];
    
    if (self.editing) {
        [cell startJiggling];
    } else {
        [cell stopJiggling];
    }
    
    return cell;
}

-(void)updateEditBarButtons {
    if ([[self.collectionView indexPathsForSelectedItems] count] == 0) {
        [self.trashBarButtonItem setEnabled:NO];
        [self.duplicateBarButtonItem setEnabled:NO];
        [self.exportBarButtonItem setEnabled:NO];
    } else if ([[self.collectionView indexPathsForSelectedItems] count] == 1) {
        [self.trashBarButtonItem setEnabled:YES];
        [self.duplicateBarButtonItem setEnabled:YES];
        [self.exportBarButtonItem setEnabled:YES];
    } else {
        [self.trashBarButtonItem setEnabled:YES];
        [self.duplicateBarButtonItem setEnabled:NO];
        [self.exportBarButtonItem setEnabled:NO];
    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        return YES;
    } else {
        return NO;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self updateEditBarButtons];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        [self updateEditBarButtons];
    }
}

-(void)loadPresetNamed:(NSString*)presetName {

    UIView *blockingView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    [blockingView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [self.navigationController.view addSubview:blockingView];

    [self.buildViewController recallPreset:presetName onCompletion:^(BOOL success) {
        [self.buildViewController setFilename:presetName];
        [blockingView removeFromSuperview];
        [self.navigationController popViewControllerAnimated:YES];
    } onError:^(NSError *error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Sorry, there appears to be a problem when opening this file.\n\nThis file cannot be opened."
                                                                preferredStyle:UIAlertControllerStyleAlert];
    
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [blockingView removeFromSuperview];
            });
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
}

// Cell Delegates
-(void)FilesViewControllerCellDidTapLabel:(FilesViewControllerCell *)cell {
    RenameFileViewController *vc = [[RenameFileViewController alloc] init];

    [vc setPresetName:cell.preset];
    
    [vc.thumbnailView setImage:cell.thumbnailView.image];
    [vc.textField setText:[cell.preset stringByDeletingPathExtension]];
    
    [self.navigationController pushViewController:vc animated:true];
}

-(void)FilesViewControllerCellDidTapThumbnail:(FilesViewControllerCell *)cell {
    if (!self.editing) {
        // Load the preset
        NSString *preset = [self.files objectAtIndex:[self.collectionView indexPathForCell:cell].row];
        [self loadPresetNamed:preset];
    } 
}

@end
