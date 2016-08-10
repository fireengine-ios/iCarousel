//
//  RevisitedCollectionView.m
//  Depo
//
//  Created by Mahir Tarlan on 09/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedCollectionView.h"
#import "Util.h"

@implementation RevisitedCollectionView

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"BBBBBB"];
    }
    return self;
}

@end
