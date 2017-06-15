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
//  UIAlertViewCustom.h
//  TurkcellUpdaterSampleApp
//
//  Created by Sonat Karakas on 1/11/13.
//  Copyright (c) 2013 Turkcell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertViewCustom : UIAlertView

@property (nonatomic, retain) NSString *targetPackageURL;
@property (nonatomic, retain) NSString *forceUpdate;
@property (nonatomic, retain) NSString *forceExit;

@end
