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

@interface FolderEmptyCell () {
    UIImageView *emptyImgView;
    CustomLabel *titleLabel;
    CustomLabel *descLabel;
}
@end

@implementation FolderEmptyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFolderTitle:(NSString *) folderTitle {
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier withFolderTitle:folderTitle withDescMessage:@"FolderEmptySubMessage"];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFolderTitle:(NSString *) folderTitle withDescMessage:(NSString *) msgKey {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        int topIndex = 40;
        if(IS_IPHONE_5) {
            topIndex = 80;
        } else if(IS_IPAD) {
            topIndex = 180;
        }
        
        UIImage *emptyImg = [UIImage imageNamed:@"empty_state_icon.png"];
        emptyImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, topIndex, 320, 130)];
        emptyImgView.image = emptyImg;
        [self addSubview:emptyImgView];
        
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, topIndex + 170, self.frame.size.width, 24) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363E4F"] withText:[NSString stringWithFormat:NSLocalizedString(@"FolderEmptyMessage", @""), folderTitle == nil ? NSLocalizedString(@"FilesTitle", @"") : folderTitle]];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];

        descLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(30, topIndex + 196, self.frame.size.width - 60, 44) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:18] withColor:[Util UIColorForHexColor:@"707A8F"] withText:NSLocalizedString(msgKey, @"")];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.numberOfLines = 2;
        [self addSubview:descLabel];
    }
    return self;
}

- (void) layoutSubviews {
    int topIndex = 40;
    if(IS_IPHONE_5) {
        topIndex = 80;
    } else if(IS_IPAD) {
        topIndex = 180;
    }
    emptyImgView.frame = CGRectMake((self.frame.size.width - 320)/2, topIndex, 320, 130);
    titleLabel.frame = CGRectMake((self.frame.size.width - 320)/2, topIndex + 170, 320, 24);
    descLabel.frame = CGRectMake((self.frame.size.width - 260)/2, topIndex + 196, 260, 44);
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
