//
//  ReachUsController.h
//  Depo
//
//  Created by Mahir Tarlan on 04/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "FeedbackDao.h"
#import <MessageUI/MessageUI.h>

@interface ReachUsController : MyViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) FeedbackDao *dao;
@property (nonatomic, strong) UITableView *choiceTable;
@property (nonatomic, strong) UITextView *textView;

@end
