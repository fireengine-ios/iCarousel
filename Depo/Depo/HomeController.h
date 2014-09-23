//
//  HomeController.h
//  Depo
//
//  Created by Mahir on 9/19/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "FileListDao.h"

@interface HomeController : MyViewController {
    FileListDao *fileListDao;
}

@end
