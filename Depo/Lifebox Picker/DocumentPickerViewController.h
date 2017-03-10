//
//  DocumentPickerViewController.h
//  Lifebox Picker
//
//  Created by RDC Partner on 06/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertView.h"

@interface DocumentPickerViewController : UIDocumentPickerExtensionViewController<UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate, CustomAlertDelegate>

@property (nonatomic, strong) CustomAlertView *alertView;
@property (nonatomic, strong) NSMutableArray *docList;
@property (nonatomic, strong) NSString *storagePath;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property int page;

@end
