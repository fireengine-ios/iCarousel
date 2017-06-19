//
//  PostLoginPrefCell.h
//  Depo
//
//  Created by Mahir on 11.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostLoginPrefCell : UITableViewCell {
    UIImageView *checkView;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *) titleVal;

@end
