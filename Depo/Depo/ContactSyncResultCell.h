//
//  ContactSyncResultCell.h
//  Depo
//
//  Created by Mahir on 08/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactSyncResultCell : UITableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *) titleVal withClientVal:(int) clientVal withServerVal:(int) serverVal;
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *) titleVal withVal:(int) val isBold:(BOOL)isBoldval;

@end
