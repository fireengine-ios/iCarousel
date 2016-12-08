//
//  SearchContainerCollCell.m
//  Depo
//
//  Created by Mahir Tarlan on 07/12/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SearchContainerCollCell.h"

@implementation SearchContainerCollCell

@synthesize field;

- (void) loadContent {
    if(!field) {
        field = [[MainSearchTextfield alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width - 40, 40)];
        field.returnKeyType = UIReturnKeySearch;
        field.userInteractionEnabled = NO;
        [self addSubview:field];
    }
}

@end
