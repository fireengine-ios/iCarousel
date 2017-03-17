//
//  Document.h
//  Depo
//
//  Created by RDC Partner on 06/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Document : NSObject

@property (nonatomic, strong) NSString *docName;
@property (nonatomic) long docSize;
@property (nonatomic, strong) NSString *tempDownloadURL;

@end
