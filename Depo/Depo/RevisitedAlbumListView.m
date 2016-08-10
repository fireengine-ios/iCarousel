//
//  RevisitedAlbumListView.m
//  Depo
//
//  Created by Mahir Tarlan on 09/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedAlbumListView.h"
#import "Util.h"

@implementation RevisitedAlbumListView

@synthesize delegate;
@synthesize albums;
@synthesize albumTable;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"FEFEFE"];
    }
    return self;
}

@end
