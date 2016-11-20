//
//  GroupPhotoSectionView.m
//  Depo
//
//  Created by Mahir Tarlan on 15/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "GroupPhotoSectionView.h"
#import "CustomLabel.h"
#import "Util.h"

@interface GroupPhotoSectionView() {
    CustomLabel *titleLabel;
}
@end

@implementation GroupPhotoSectionView

- (void) loadSectionWithTitle:(NSString *) titleVal {
    if(!titleLabel) {
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, (self.frame.size.width-40)/2, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:14] withColor:[Util UIColorForHexColor:@"555555"] withText:titleVal];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:titleLabel];
    } else {
        titleLabel.text = titleVal;
    }
}

@end
