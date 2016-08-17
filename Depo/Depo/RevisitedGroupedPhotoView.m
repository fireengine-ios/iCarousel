//
//  RevisitedGroupedPhotoView.m
//  Depo
//
//  Created by Mahir Tarlan on 09/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedGroupedPhotoView.h"
#import "Util.h"

@interface RevisitedGroupedPhotoView() {
    int tableUpdateCounter;
    int listOffset;
    BOOL isLoading;
}
@end

@implementation RevisitedGroupedPhotoView

@synthesize delegate;
@synthesize groups;
@synthesize selectedFileList;
@synthesize refreshControl;
@synthesize groupTable;
@synthesize collDao;
@synthesize imgFooterActionMenu;
@synthesize isSelectible;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
    }
    return self;
}

@end
