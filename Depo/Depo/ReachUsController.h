//
//  ReachUsController.h
//  Depo
//
//  Created by Mahir Tarlan on 04/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "FeedbackDao.h"
#import "AccountDao.h"
#import <MessageUI/MessageUI.h>
#import "CustomAlertView.h"

@interface ReachUsController : MyViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, CustomAlertDelegate>

@property (nonatomic, strong) FeedbackDao *dao;
@property (nonatomic, strong) AccountDao *accountDao;
@property (nonatomic, strong) UITableView *choiceTable;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSArray *subscriptions;

@end
