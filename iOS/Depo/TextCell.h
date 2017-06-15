//
//  TextCell.h
//  Depo
//
//  Created by Mustafa Talha Celik on 25.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextCell : UITableViewCell {
    NSString *titleText;
    UIColor *titleColor;
    BOOL hasTitle;
    NSString *contentText;
    UIColor *contentTextColor;
    double contentTextTop;
    double contentTextHeight;
    UIColor *backgroundColor;
    BOOL hasSeparator;
    double cellHeight;
}

- (id)initWithCellStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)_titleText titleColor:(UIColor *)_titleColor contentText:(NSString *)_contentText contentTextColor:(UIColor *)_contentTextColor backgroundColor:(UIColor *)_backgroundColor hasSeparator:(BOOL)_hasSeparator;

@end
