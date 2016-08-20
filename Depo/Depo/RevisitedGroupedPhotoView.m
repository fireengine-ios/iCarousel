//
//  RevisitedGroupedPhotoView.m
//  Depo
//
//  Created by Mahir Tarlan on 09/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedGroupedPhotoView.h"
#import "Util.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "GroupedPhotosCell.h"

#define GROUP_PACKAGE_SIZE IS_IPAD ? 30 : 24
#define GROUP_IMG_COUNT_PER_ROW 4
#define GROUP_INPROGRESS_KEY @"in_progress"

@interface RevisitedGroupedPhotoView() {
    int tableUpdateCounter;
    int listOffset;
    BOOL isLoading;
    int photoCount;
    NSDateFormatter *dateCompareFormat;
}
@end

@implementation RevisitedGroupedPhotoView

@synthesize delegate;
@synthesize files;
@synthesize groups;
@synthesize groupDict;
@synthesize selectedFileList;
@synthesize refreshControl;
@synthesize fileTable;
@synthesize readDao;
@synthesize imgFooterActionMenu;
@synthesize isSelectible;
@synthesize progress;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];

        readDao = [[ElasticSearchDao alloc] init];
        readDao.delegate = self;
        readDao.successMethod = @selector(readSuccessCallback:);
        readDao.failMethod = @selector(readFailCallback:);
        
        tableUpdateCounter = 0;
        listOffset = 0;
        photoCount = 0;
        
        dateCompareFormat = [[NSDateFormatter alloc] init];
        [dateCompareFormat setDateFormat:@"MMM yyyy"];
        
        files = [[NSMutableArray alloc] init];
        groups = [[NSMutableArray alloc] init];
        selectedFileList = [[NSMutableArray alloc] init];
        groupDict = [[NSMutableDictionary alloc] init];
        
        fileTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
        fileTable.backgroundColor = [UIColor clearColor];
        fileTable.backgroundView = nil;
        fileTable.delegate = self;
        fileTable.dataSource = self;
        fileTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:fileTable];
        
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(pullData) forControlEvents:UIControlEventValueChanged];
        [fileTable addSubview:refreshControl];

        progress = [[MBProgressHUD alloc] initWithFrame:self.frame];
        progress.opacity = 0.4f;
        [self addSubview:progress];
    }
    return self;
}

- (void) pullData {
    listOffset = 0;
    
    [self.files removeAllObjects];
    
    [self addOngoingGroup];
    
    [readDao requestPhotosForPage:listOffset andSize:GROUP_PACKAGE_SIZE andSortType:SortTypeDateDesc];
    isLoading = YES;

    [self bringSubviewToFront:progress];
    [progress show:YES];
}

- (void) addOngoingGroup {
    FileInfoGroup *groupToRemove = [self.groupDict objectForKey:GROUP_INPROGRESS_KEY];
    if(groupToRemove) {
        [self.groupDict removeObjectForKey:GROUP_INPROGRESS_KEY];
    }
    NSArray *uploadingImageRefArray = [[UploadQueue sharedInstance] uploadImageRefs];
    if([uploadingImageRefArray count] > 0) {
        FileInfoGroup *inProgressGroup = [[FileInfoGroup alloc] init];
        inProgressGroup.customTitle = NSLocalizedString(@"ImageGroupTypeInProgress", @"");
        inProgressGroup.fileInfo = uploadingImageRefArray;
        inProgressGroup.groupType = ImageGroupTypeInProgress;
//        [groups addObject:inProgressGroup];
        [groupDict setObject:inProgressGroup forKey:GROUP_INPROGRESS_KEY];
    }
}

- (void) setToSelectible {
    isSelectible = YES;
    [refreshControl setEnabled:NO];
    [selectedFileList removeAllObjects];
}

- (void) setToUnselectible {
    isSelectible = NO;
    [refreshControl setEnabled:YES];
    [selectedFileList removeAllObjects];
    
    if(imgFooterActionMenu) {
        [imgFooterActionMenu removeFromSuperview];
        imgFooterActionMenu = nil;
    }
}

- (void) readSuccessCallback:(NSArray *) fileList {
    [progress hide:YES];
    [self.files addObjectsFromArray:fileList];
    
    for(MetaFile *row in fileList) {
        NSString *dateStr = [dateCompareFormat stringFromDate:row.lastModified];
        if([[groupDict allKeys] count] == 0) {
            FileInfoGroup *newGroup = [[FileInfoGroup alloc] init];
            newGroup.customTitle = dateStr;
            newGroup.fileInfo = [[NSMutableArray alloc] init];
            [newGroup.fileInfo addObject:row];
            [groupDict setObject:newGroup forKey:dateStr];
        } else {
            FileInfoGroup *currentGroup = [groupDict objectForKey:dateStr];
            if(currentGroup != nil) {
                [currentGroup.fileInfo addObject:row];
            } else {
                FileInfoGroup *newGroup = [[FileInfoGroup alloc] init];
                newGroup.customTitle = dateStr;
                newGroup.fileInfo = [[NSMutableArray alloc] init];
                [newGroup.fileInfo addObject:row];
                [groupDict setObject:newGroup forKey:dateStr];
            }
        }
    }
    FileInfoGroup *ongoingGroup = [groupDict objectForKey:GROUP_INPROGRESS_KEY];
    if(ongoingGroup) {
        [groupDict removeObjectForKey:GROUP_INPROGRESS_KEY];
        self.groups = [[NSMutableArray alloc] init];
        [self.groups addObject:ongoingGroup];
        [self.groups addObjectsFromArray:[groupDict allValues]];
    } else {
        self.groups = [groupDict allValues];
    }
    
    isLoading = NO;
    [refreshControl endRefreshing];
    
    tableUpdateCounter++;
    [fileTable reloadData];
}

- (void) readFailCallback:(NSString *) errorMessage {
    [progress hide:YES];
    isLoading = NO;
}

/*
- (void) photoListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    int counter = (int)[photoList count];
    
    int imagePerLine = 3;
    
    float imageWidth = 100;
    float interImageMargin = 5;
    
    if(IS_IPAD) {
        imagePerLine = 5;
        imageWidth = (self.view.frame.size.width - interImageMargin*(imagePerLine+1))/imagePerLine;
    }
    
    float imageTotalWidth = imageWidth + interImageMargin;
    
    for(MetaFile *row in files) {
        CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), 15 + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
        SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withFile:row withSelectibleStatus:isSelectible];
        imgView.delegate = self;
        [photosScroll addSubview:imgView];
        counter ++;
    }
    float contentSizeHeight = ((int)ceil(counter/imagePerLine)+1)*imageTotalWidth + 20;
    if(contentSizeHeight <= photosScroll.frame.size.height) {
        contentSizeHeight = photosScroll.frame.size.height + 1;
    }
    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, contentSizeHeight);
    [photoList addObjectsFromArray:files];
    if (photoList.count == 0) {
        if (noItemView == nil)
            noItemView = [[NoItemView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, photosScroll.frame.size.height) imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
        [photosScroll addSubview:noItemView];
    }
    else if (noItemView != nil)
        [noItemView removeFromSuperview];
    if(refreshControlPhotos) {
        [refreshControlPhotos endRefreshing];
    }
    if(refreshControlAlbums) {
        [refreshControlAlbums endRefreshing];
    }
    isLoading = NO;
}

- (void) alignPhotosScrollPostDelete {
    NSMutableArray *filteredFiles = [[NSMutableArray alloc] init];
    NSMutableArray *ongoingFiles = [[NSMutableArray alloc] init];
    for(id row in photoList) {
        if([row isKindOfClass:[MetaFile class]]) {
            MetaFile *file = (MetaFile *) row;
            if(![selectedFileList containsObject:file.uuid]) {
                [filteredFiles addObject:row];
            }
        } else {
            [ongoingFiles addObject:row];
        }
    }
    
    for(UIView *subView in photosScroll.subviews) {
        if([subView isKindOfClass:[SquareImageView class]]) {
            if(((SquareImageView *) subView).uploadRef == nil) {
                [subView removeFromSuperview];
            }
        }
    }
    
    int counter = (int)[ongoingFiles count];
    
    int imagePerLine = 3;
    
    float imageWidth = 100;
    float interImageMargin = 5;
    
    if(IS_IPAD) {
        imagePerLine = 5;
        imageWidth = (self.view.frame.size.width - interImageMargin*(imagePerLine+1))/imagePerLine;
    }
    
    float imageTotalWidth = imageWidth + interImageMargin;
    
    for(MetaFile *row in filteredFiles) {
        CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), 15 + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
        SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withFile:row withSelectibleStatus:isSelectible];
        imgView.delegate = self;
        [photosScroll addSubview:imgView];
        counter ++;
    }
    float contentSizeHeight = ((int)ceil(counter/imagePerLine)+1)*imageTotalWidth + 20;
    if(contentSizeHeight <= photosScroll.frame.size.height) {
        contentSizeHeight = photosScroll.frame.size.height + 1;
    }
    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, contentSizeHeight);
    
    self.photoList = ongoingFiles;
    [photoList addObjectsFromArray:filteredFiles];
    
    if (photoList.count == 0) {
        if (noItemView == nil)
            noItemView = [[NoItemView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, photosScroll.frame.size.height) imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
        [photosScroll addSubview:noItemView];
    }
}

- (void) photoListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}
*/

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(groups.count > 0) {
        FileInfoGroup *group = [groups objectAtIndex:indexPath.row];
        
        float boxWidth = fileTable.frame.size.width/GROUP_IMG_COUNT_PER_ROW;
        int boxCountPerRow = GROUP_IMG_COUNT_PER_ROW;
        
        float imageContainerHeight = 60;
        imageContainerHeight += floorf(group.fileInfo.count/boxCountPerRow)*boxWidth;
        if(group.fileInfo.count%boxCountPerRow > 0) {
            imageContainerHeight += boxWidth;
        }
        return imageContainerHeight;
    } else {
        return self.frame.size.width/2;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (groups.count == 0)
        return isLoading ? 0 : 1;
    return [groups count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d_%d", @"IMG_GROUP_CELL",  (int)indexPath.row, tableUpdateCounter];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        if(files.count > 0) {
            FileInfoGroup *group = [groups objectAtIndex:indexPath.row];
            float boxWidth = fileTable.frame.size.width/GROUP_IMG_COUNT_PER_ROW;
            int boxCountPerRow = GROUP_IMG_COUNT_PER_ROW;
            cell = [[GroupedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withGroup:group isSelectible:isSelectible withImageWidth:boxWidth withImageCountPerRow:boxCountPerRow];
            ((GroupedCell *)cell).delegate = self;
        } else {
            cell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!isLoading) {
        CGFloat currentOffset = fileTable.contentOffset.y;
        CGFloat maximumOffset = fileTable.contentSize.height - fileTable.frame.size.height;
        
        if (maximumOffset > 0.0f && currentOffset - maximumOffset >= 0.0f) {
            isLoading = YES;
            [self dynamicallyLoadNextPage];
        }
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    [readDao requestPhotosForPage:listOffset andSize:GROUP_PACKAGE_SIZE andSortType:SortTypeDateDesc];
}

- (void) groupedCellImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey {
    FileInfoGroup *groupSelected = nil;
    for(FileInfoGroup *row in self.groups) {
        if([row.customTitle isEqualToString:groupKey]) {
            groupSelected = row;
            break;
        }
    }
    NSArray *listToPass = @[fileSelected];
    if(groupSelected != nil) {
        listToPass = groupSelected.fileInfo;
    }
    [delegate revisitedGroupedPhotoDidSelectFile:fileSelected withList:listToPass];
}

- (void) groupedCellImageWasMarkedForFile:(MetaFile *) fileSelected {
    if(fileSelected.uuid) {
        if(![selectedFileList containsObject:fileSelected.uuid]) {
            [selectedFileList addObject:fileSelected.uuid];
        }
    }
    if([selectedFileList count] > 0) {
        //        [self showImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]]];
    } else {
        //        [self hideImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:NSLocalizedString(@"SelectFilesTitle", @"")];
    }
    
    if (fileSelected.contentType == ContentTypeVideo) {
        if (photoCount == 0) {
            //            [imgFooterActionMenu hidePrintIcon];
        } else{
            //            [imgFooterActionMenu showPrintIcon];
        }
    } else {
        photoCount++;
        //        [imgFooterActionMenu showPrintIcon];
    }
}

- (void) groupedCellImageWasUnmarkedForFile:(MetaFile *) fileSelected {
    if([selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList removeObject:fileSelected.uuid];
    }
    if([selectedFileList count] > 0) {
        //        [self showImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]]];
    } else {
        //        [self hideImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:NSLocalizedString(@"SelectFilesTitle", @"")];
    }
    if (fileSelected.contentType == ContentTypePhoto) {
        photoCount--;
    }
    if (photoCount == 0) {
        //        [imgFooterActionMenu hidePrintIcon];
    }
}

- (void) groupedCellImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
}

- (void) groupedCellImageWasLongPressedForFile:(MetaFile *) fileSelected {
}

- (void) groupedCellImageUploadQuotaError:(MetaFile *) fileSelected {
}

- (void) groupedCellImageUploadLoginError:(MetaFile *) fileSelected {
}

- (void) groupedCellImageWasSelectedForView:(SquareImageView *) ref {
}

@end
