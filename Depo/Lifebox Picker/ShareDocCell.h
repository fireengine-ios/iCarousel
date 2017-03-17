//
//  ShareDocCell.h
//  Depo
//
//  Created by RDC Partner on 08/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Document.h"

@interface ShareDocCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;


@end
