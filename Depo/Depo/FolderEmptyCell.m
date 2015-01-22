//
//  FolderEmptyCell.m
//  Depo
//
//  Created by Mahir on 9/26/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FolderEmptyCell.h"
#import "CustomLabel.h"
#import "Util.h"
#import "AppConstants.h"

@implementation FolderEmptyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFolderTitle:(NSString *) folderTitle {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        int topIndex = 40;
        if(IS_IPHONE_5) {
            topIndex = 80;
        }
        
        UIImage *emptyImg = [UIImage imageNamed:@"empty_state_icon.png"];
        UIImageView *emptyImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, topIndex, 320, 130)];
        emptyImgView.image = emptyImg;
        [self addSubview:emptyImgView];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, topIndex + 170, self.frame.size.width, 24) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363E4F"] withText:[NSString stringWithFormat:NSLocalizedString(@"FolderEmptyMessage", @""), folderTitle == nil ? NSLocalizedString(@"FilesTitle", @"") : folderTitle]];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];

        CustomLabel *descLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(30, topIndex + 196, self.frame.size.width - 60, 44) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:18] withColor:[Util UIColorForHexColor:@"707A8F"] withText:NSLocalizedString(@"FolderEmptySubMessage", @"")];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.numberOfLines = 2;
        [self addSubview:descLabel];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
