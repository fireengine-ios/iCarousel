//
//  Story.h
//  Depo
//
//  Created by Mahir Tarlan on 05/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetaFile.h"

@interface Story : NSObject

@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) MetaFile *musicFile;
@property (nonatomic, strong) NSString *title;

@end
