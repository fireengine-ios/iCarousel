//
//  RevisitedPhotoHeaderSegmentView.m
//  Depo
//
//  Created by Mahir Tarlan on 01/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedPhotoHeaderSegmentView.h"
#import "Util.h"

@interface RevisitedPhotoHeaderSegmentView() {
    float itemWidth;
}
@end

@implementation RevisitedPhotoHeaderSegmentView

@synthesize delegate;
@synthesize indicator;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        
        itemWidth = self.frame.size.width / 3;

        UIImage *indicatorImg = [UIImage imageNamed:@"edge_tab.png"];
        
        indicator = [[UIImageView alloc] initWithFrame:CGRectMake((itemWidth - indicatorImg.size.width)/2, self.frame.size.height - indicatorImg.size.height, indicatorImg.size.width, indicatorImg.size.height)];
        indicator.image = indicatorImg;
        [self addSubview:indicator];
    }
    return self;
}

@end
