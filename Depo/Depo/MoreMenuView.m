//
//  MoreMenuView.m
//  Depo
//
//  Created by Mahir on 9/26/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MoreMenuView.h"
#import "MoreMenuCell.h"
#import "Util.h"
#import "AppDelegate.h"
#import "BaseViewController.h"

@implementation MoreMenuView

@synthesize moreTable;
@synthesize moreList;

- (id)initWithFrame:(CGRect)frame withList:(NSArray *) moreListRef {
    self = [super initWithFrame:frame];
    if (self) {
        self.moreList = moreListRef;
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.8;
        [self addSubview:bgView];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerDismiss)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];

        moreTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
        moreTable.bounces = NO;
        moreTable.delegate = self;
        moreTable.dataSource = self;
        moreTable.backgroundColor = [UIColor clearColor];
        moreTable.backgroundView = nil;
        moreTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [moreTable sizeToFit];
        [self addSubview:moreTable];
        
        UIImage *dropImg = [UIImage imageNamed:@"menu_drop.png"];
        UIImageView *dropImgView = [[UIImageView alloc] initWithFrame:CGRectMake(290, 0, dropImg.size.width, dropImg.size.height)];
        dropImgView.image = dropImg;
        [self addSubview:dropImgView];
    }
    return self;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [moreList count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MORE_MENU_CELL_%d", (int)indexPath.row];
    NSNumber *typeAsNumber = [moreList objectAtIndex:indexPath.row];
    MoreMenuType type = (MoreMenuType)[typeAsNumber intValue];
    MoreMenuCell *cell = [[MoreMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMenuType:type];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self removeFromSuperview];
    NSNumber *typeAsNumber = [moreList objectAtIndex:indexPath.row];
    MoreMenuType type = (MoreMenuType)[typeAsNumber intValue];
    switch (type) {
        case MoreMenuTypeDelete:
            [APPDELEGATE.base showConfirmDelete];
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:moreTable]) {
        return NO;
    }
    return YES;
}

- (void) triggerDismiss {
    [self removeFromSuperview];
}

 /*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
