//
//  SearchContainerCollCell.h
//  Depo
//
//  Created by Mahir Tarlan on 07/12/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainSearchTextfield.h"

@interface SearchContainerCollCell : UICollectionViewCell

@property (nonatomic, strong) MainSearchTextfield *field;

- (void) loadContent;

@end
