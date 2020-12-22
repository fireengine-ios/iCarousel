/*******************************************************************************
 *
 *  Copyright (C) 2014 Turkcell
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *******************************************************************************/
//
//  UpdaterController.h
//  TurkcellUpdaterSampleApp
//
//  Created by Sonat Karakas on 1/14/13.
//  Copyright (c) 2013 Turkcell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdaterControllerDelegate.h"

typedef NS_ENUM(NSInteger, UpdateAction){
    UpdateActionNone,
    UpdateActionUpdateChosen,
    UpdateActionUpdateCheckCompleted,
    UpdateActionUpdateFound
};

@interface UpdaterController : NSObject

@property (nonatomic, retain) NSString *updateServerURL;
@property (nonatomic, strong) NSString *preferredLanguage;
@property (nonatomic, weak) UIViewController *parentViewController;
@property (nonatomic, copy) void(^completionBlock)(UpdateAction updateAction);

+(instancetype)sharedInstance;

- (void)checkUpdateURL:(NSString *)URL
     preferredLanguageForTitles:(NSString *)preferredLanguage
  parentViewController: (UIViewController *)vc
     completionHandler:(void(^)(UpdateAction updateAction))completionBlock;

@end

