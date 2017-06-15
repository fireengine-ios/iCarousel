//
//  DownloadedFile.h
//  Depo
//
//  Created by Salih GUC on 04/12/2016.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadedFile : NSObject

@property (nonatomic, strong) NSString *fileUUID;
@property (nonatomic, strong) NSString *fileLocalIdentifier;
@property (nonatomic, strong) NSString *albumName;

-(id)initWithFileUUID:(NSString *)uuid localIdentifier:(NSString *)localIdentifier inAlbumName:(NSString *)inAlbumName;

@end