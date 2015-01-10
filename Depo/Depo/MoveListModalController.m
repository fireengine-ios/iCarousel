//
//  MoveListModalController.m
//  Depo
//
//  Created by Mahir on 01/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MoveListModalController.h"
#import "FolderCell.h"
#import "AppDelegate.h"
#import "AppSession.h"

@interface MoveListModalController ()

@end

@implementation MoveListModalController

@synthesize delegate;
@synthesize folder;
@synthesize folderTable;
@synthesize folderList;
@synthesize prohibitedList;
@synthesize footerView;
@synthesize exludingFolderUuid;

- (id)initForFolder:(MetaFile *) _folder {
    return [self initForFolder:_folder withExludingFolder:nil];
}

- (id)initForFolder:(MetaFile *) _folder withExludingFolder:(NSString *) _exludingFolderUuid {
    return [self initForFolder:_folder withExludingFolder:_exludingFolderUuid withProhibitedFolders:nil];
}

- (id)initForFolder:(MetaFile *) _folder withExludingFolder:(NSString *) _exludingFolderUuid withProhibitedFolders:(NSArray *) prohibitedFolderList {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.folder = _folder;
        self.exludingFolderUuid = _exludingFolderUuid;
        self.prohibitedList = prohibitedFolderList;
        self.title = @" ";

        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.rightBarButtonItem = cancelItem;

        fileListDao = [[FileListDao alloc] init];
        fileListDao.delegate = self;
        fileListDao.successMethod = @selector(fileListSuccessCallback:);
        fileListDao.failMethod = @selector(fileListFailCallback:);

        folderTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex) style:UITableViewStylePlain];
        folderTable.delegate = self;
        folderTable.dataSource = self;
        folderTable.backgroundColor = [UIColor clearColor];
        folderTable.backgroundView = nil;
        folderTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        folderTable.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        [self.view addSubview:folderTable];

        [fileListDao requestFolderListingForFolder:self.folder?self.folder.uuid:nil andForPage:0 andSize:NO_OF_FILES_PER_PAGE sortBy:APPDELEGATE.session.sortType];

        footerView = [[MoveModalFooterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60)];
        footerView.delegate = self;
        [self.view addSubview:footerView];
    }
    return self;
}

- (void) fileListSuccessCallback:(NSArray *) files {
    NSMutableArray *filteredList = [[NSMutableArray alloc] init];
    for(MetaFile *row in files) {
        if(self.prohibitedList != nil) {
            if([self.prohibitedList containsObject:row.uuid]) {
                continue;
            }
        }
        [filteredList addObject:row];
    }
    self.folderList = filteredList;

    [folderTable reloadData];
}

- (void) fileListFailCallback:(NSString *) errorMessage {
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [folderList count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MOVE_FOLDER_CELL_%d", (int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        MetaFile *fileAtIndex = [folderList objectAtIndex:indexPath.row];
        cell = [[FolderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex isSelectible:NO];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MetaFile *fileAtIndex = [folderList objectAtIndex:indexPath.row];
    MoveListModalController *subList = [[MoveListModalController alloc] initForFolder:fileAtIndex withExludingFolder:self.exludingFolderUuid withProhibitedFolders:self.prohibitedList];
    subList.delegate = self.delegate;
    [self.navigationController pushViewController:subList animated:NO];
}

- (void) prepareAndSetNavigationTitleView {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
    CustomLabel *subTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 0, titleView.frame.size.width, 16) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] withColor:[UIColor whiteColor] withText:NSLocalizedString(@"MoveModalSubTitle", @"")];
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:subTitleLabel];
    CustomLabel *mainTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 18, titleView.frame.size.width, 22) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:18] withColor:[UIColor whiteColor] withText:self.folder?self.folder.name:NSLocalizedString(@"FilesTitle", @"")];
    mainTitleLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:mainTitleLabel];
    [self.navigationItem setTitleView:titleView];
}

#pragma mark MoveModalFooterDelegate

- (void) moveModalFooterDidSelectMove {
    if([exludingFolderUuid isEqualToString:self.folder.uuid]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"SameMoveError", @"")];
    } else {
        [delegate moveListModalDidSelectFolder:self.folder?self.folder.uuid:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
    [self prepareAndSetNavigationTitleView];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
