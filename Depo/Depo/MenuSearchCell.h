//
//  MenuSearchCell.h
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractMenuCell.h"
#import "SearchTextField.h"

@interface MenuSearchCell : AbstractMenuCell <UITextFieldDelegate> {
    SearchTextField *textField;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withMetaData:(MetaMenu *) _metaData;

@end
