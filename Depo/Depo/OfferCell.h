//
//  OfferCell.h
//  Depo
//
//  Created by RDC Partner on 13.02.2015.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfferCell : UITableViewCell {
    NSString *titleText;
    BOOL hasSeparator;
    CGFloat topIndex;
    CGFloat bottomIndex;
    CGFloat cellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)_titleText hasSeparator:(BOOL)_hasSeparator topIndex:(CGFloat)_topIndex bottomIndex:(CGFloat)_bottomIndex;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)_titleText hasSeparator:(BOOL)_hasSeparator;

@end
