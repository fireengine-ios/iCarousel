//
//  DocumentPickerViewController.m
//  Lifebox Picker
//
//  Created by RDC Partner on 06/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "DocumentPickerViewController.h"
#import "AppDelegate.h"
#import "AppUtil.h"
#import "SharedUtil.h"
#import "ElasticSearchDao.h"
#import "Document.h"
#import "ShareDocCell.h"
#import "Util.h"
#import "Reachability.h"
#import "CustomLabel.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define EXT_REMEMBER_ME_URL @"https://adepo.turkcell.com.tr/api/auth/rememberMe"
//#define EXT_REMEMBER_ME_URL @"http://tcloudstb.turkcell.com.tr/api/auth/rememberMe"

#ifdef PLATFORM_STORE
#define GROUP_NAME_SUITE_NSUSERDEFAULTS @"group.com.turkcell.akillidepo"
#elif defined PLATFORM_ICT
#define GROUP_NAME_SUITE_NSUSERDEFAULTS @"group.com.turkcell.akillideponew.ent"
#else
#define GROUP_NAME_SUITE_NSUSERDEFAULTS @"group.com.rdc.lifebox2"
#endif

@interface DocumentPickerViewController ()
@property (weak, nonatomic) IBOutlet UITableView *docTable;

@end

@implementation DocumentPickerViewController

@synthesize alertView;
@synthesize indicator;
@synthesize docList;
@synthesize storagePath;
@synthesize page;



- (void) viewDidLoad {
    [super viewDidLoad];
    
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.color = [UIColor darkGrayColor];
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    
    self.docTable.delegate = self;
    self.docTable.dataSource = self;
    
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
        [self requestForDocs:self.folderUUID pageNum:0 completion:^(NSMutableArray *list, NSError *error) {
            if (!error) {
                docList = list;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([list count] == 0) {
                        [self showFileIsEmpty];
                    }
                    [self.docTable reloadData];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showErrorAlert:NSLocalizedString(@"ExtLoginRequiredMessage", @"")];
                });
            }
        }];
    }
    else {
        [self showErrorAlert:NSLocalizedString(@"ConnectionErrorWarning", @"")];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.validFileTypes.count == 0) {
        self.validFileTypes = self.validTypes;
    }
    
    if (self.rootFolderName) {
        self.title = self.rootFolderName;
    } else {
        self.title = @"lifebox";
    }
    
    
    
//    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.rdc.lifebox2"];
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:GROUP_NAME_SUITE_NSUSERDEFAULTS];
    NSString *groupPath = [groupURL path];
    storagePath = [groupPath stringByAppendingPathComponent:@"File Provider Storage"];
    [[NSFileManager defaultManager] createDirectoryAtPath:storagePath withIntermediateDirectories:NO attributes:nil error:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [docList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShareDocCell *cell;
    MetaFile *file = [docList objectAtIndex:indexPath.row];
    
    if (file.contentType == ContentTypeFolder) {
        cell = [self.docTable dequeueReusableCellWithIdentifier:@"FOLDER_CELL" forIndexPath:indexPath];
        cell.titleLabel.text = file.name;
        NSString *docSizeString = [NSString stringWithFormat:NSLocalizedString(@"FolderSubTitle", @""), file.itemCount];
        cell.subTitleLabel.text = docSizeString;
        [cell.thumbnailImageView setImage:[UIImage imageNamed:@"folder_icon.png"]];
        return cell;
    } else if (file.contentType == ContentTypePhoto || file.contentType == ContentTypeVideo) {
        if([self validFile:file.name]) {
            cell = [self.docTable dequeueReusableCellWithIdentifier:@"PHOTO_CELL_ENABLED" forIndexPath:indexPath];
        } else {
            cell = [self.docTable dequeueReusableCellWithIdentifier:@"PHOTO_CELL_DISABLED" forIndexPath:indexPath];
        }
    } else if (file.contentType == ContentTypeMusic) {
        if([self validFile:file.name]) {
            cell = [self.docTable dequeueReusableCellWithIdentifier:@"MUSIC_CELL_ENABLED" forIndexPath:indexPath];
        } else {
            cell = [self.docTable dequeueReusableCellWithIdentifier:@"MUSIC_CELL_DISABLED" forIndexPath:indexPath];
        }
    } else {
        if([self validFile:file.name]) {
            cell = [self.docTable dequeueReusableCellWithIdentifier:@"DOC_CELL_ENABLED" forIndexPath:indexPath];
        } else {
            cell = [self.docTable dequeueReusableCellWithIdentifier:@"DOC_CELL_DISABLED" forIndexPath:indexPath];
        }
    }
    
    cell.titleLabel.text = file.name;
    NSString *fileSizeString = [Util transformedSizeValue:file.bytes];
    cell.subTitleLabel.text = fileSizeString;
    if (file.detail.thumbMediumUrl == nil) {
        if (file.contentType == ContentTypeMusic) {
            [cell.thumbnailImageView setImage:[UIImage imageNamed:@"green_music_icon.png"]];
        } else {
            [cell.thumbnailImageView setImage:[UIImage imageNamed:@"document_icon.png"]];
        }
    } else {
        NSURL *url = [NSURL URLWithString:file.detail.thumbMediumUrl];
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.thumbnailImageView.image = image;
                    });
                }
            }
        }];
        [task resume];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MetaFile *file = docList[indexPath.row];
    if (file.contentType == ContentTypeFolder) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainInterface" bundle:nil];
        DocumentPickerViewController *dpvcViewController = (DocumentPickerViewController *)[sb instantiateViewControllerWithIdentifier:@"dpvc_identifier"];
        dpvcViewController.folderUUID = file.uuid;
        dpvcViewController.rootFolderName = file.name;
        dpvcViewController.validFileTypes = self.validFileTypes;
        [self.navigationController pushViewController:dpvcViewController animated:YES];
    } else {
        self.docTable.allowsSelection = NO;
        [indicator startAnimating];
        MetaFile *doc = docList[indexPath.row];
        NSURL *url = [NSURL URLWithString:doc.tempDownloadUrl];
        NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:url];
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        NSURLSessionTask *downloadTask = [urlSession downloadTaskWithRequest:downloadRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            [indicator stopAnimating];
            if (!error) {
                self.docTable.allowsSelection = YES;
                
                NSData *downloadedData = [NSData dataWithContentsOfURL:location];
                
                NSString *filePath = [storagePath stringByAppendingPathComponent:doc.name];
                NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
                
                if([downloadedData writeToFile:filePath atomically:YES]) {
                    [self dismissGrantingAccessToURL:fileUrl];
                }
            }
        }];
        
        [downloadTask resume];
    }
}

//- (IBAction)openDocument:(id)sender {
//    NSURL* documentURL = [self.documentStorageURL URLByAppendingPathComponent:@"Untitled.txt"];
//    
//    // TODO: if you do not have a corresponding file provider, you must ensure that the URL returned here is backed by a file
//    [self dismissGrantingAccessToURL:documentURL];
//}

-(void)prepareForPresentationInMode:(UIDocumentPickerMode)mode {
    // TODO: present a view controller appropriate for picker mode here
}

-(void) requestForDocs:(NSString *) folderUUID pageNum:(int) pageNum completion:(void (^)(NSMutableArray *docList, NSError *error))completion {
    
    NSString *parentListingUrl = [NSString stringWithFormat:FILE_LISTING_MAIN_URL, folderUUID, @"createdDate",@"DESC", pageNum, 21];
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:30];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[SharedUtil readSharedToken] forHTTPHeaderField:@"X-Auth-Token"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    
    NSURLSessionDataTask *getDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            NSHTTPURLResponse *request = (NSHTTPURLResponse *) response;
            if ([request statusCode] == 200) {
                if (data) {
                    NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    NSDictionary *mainArray = [mainDict objectForKey:@"fileList"];
                    if (mainArray != nil || [mainArray isKindOfClass:[NSNull class]]) {
                        NSMutableArray *result = [[NSMutableArray alloc] init];
                        
                        if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
                            for(NSDictionary *fileDict in mainArray) {
                                MetaFile *parsedFile = [self parseFile:fileDict];
                                [result addObject:parsedFile];
                            }
                            completion(result,nil);
                        }
                    } else {
                        completion(nil,nil);
                    }
                } else {
                    completion(nil,nil);
                }
            }
            else {
                [self handleResponse:response completionHandler:^(NSError * _Nullable error) {
                    if(!error) {
                        [self requestForDocs:folderUUID pageNum:pageNum completion:^(NSMutableArray *list, NSError *error) {
                            completion(list,nil);
                        }];
                    } else {
                        completion(nil,error);
                    }
                }];
            }
        }
        else {
            NSLog(@"ERROR Doc Request: %ld", error.code);
        }
    }];
    
    [getDataTask resume];
}

-(void) handleResponse: (NSURLResponse *) response completionHandler:(void (^)(NSError * _Nullable error))completionHandler {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSLog(@"Response status code: %ld",[httpResponse statusCode]);
    if ([httpResponse statusCode] == 401) {
        NSLog(@"Unauthorized Error 401");
        if([SharedUtil readSharedRememberMeToken] != nil) {
            [self requestToken:^(NSError *error) {
                if (!error) {
                    completionHandler(nil);
                }
            }];
        } else {
            NSError *error = [NSError errorWithDomain:@"LoginRequired" code:401 userInfo:nil];
            completionHandler(error);
        }
    }
}

- (void) requestToken: (void (^)(NSError *error))completion {
    NSURL *url = [NSURL URLWithString:EXT_REMEMBER_ME_URL];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          [[UIDevice currentDevice] identifierForVendor].UUIDString, @"uuid",
                          [[UIDevice currentDevice] name], @"name",
                          (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"IPAD" : @"IPHONE"), @"deviceType",
                          nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:(NSJSONWritingOptions)0 error:&error];
    
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url];
    [postRequest setTimeoutInterval:60];
    [postRequest setValue:[SharedUtil readSharedRememberMeToken] forHTTPHeaderField:@"X-Remember-Me-Token"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [postRequest setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:jsonData];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:postRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self showErrorAlert:NSLocalizedString(@"ExtLoginRequiredMessage", @"")];
            });
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
                NSDictionary *dictionary = [httpResponse allHeaderFields];
                NSString *authToken = [dictionary objectForKey:@"X-Auth-Token"];
                if(authToken != nil) {
                    [SharedUtil writeSharedToken:authToken];
                    completion(nil);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [self showErrorAlert:NSLocalizedString(@"ExtLoginRequiredMessage", @"")];
                    });
                }
            }
        }
    }];
    [task resume];
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGFloat currentOffset = self.docTable.contentOffset.y;
    CGFloat maximumOffset = self.docTable.contentSize.height - self.docTable.frame.size.height;
    
    if(currentOffset - maximumOffset >= 0.0) {
        page++;
        [self requestForDocs:self.folderUUID pageNum:page completion:^(NSMutableArray *list, NSError *error) {
            if(!error) {
                [docList addObjectsFromArray:list];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self.docTable reloadData];
                });
            }
        }];
    }
}

-(void) showErrorAlert:(NSString *) withMessage {
    alertView = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:withMessage withModalType:ModalTypeError];
    alertView.delegate = self;
    [alertView reorientateModalView:self.view.center];
    [self.view addSubview:alertView];
    [self.view bringSubviewToFront:alertView];
}

-(void) didDismissCustomAlert:(CustomAlertView *)alertView {
    [self dismissGrantingAccessToURL:nil];
}

// check validity of file type
- (BOOL)validFile:(NSString *)file {
    NSString * UTI = (__bridge NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                                       (__bridge CFStringRef)[file pathExtension],
                                                                       NULL);
    for (NSString *UTIType in self.validFileTypes) {
        if (UTTypeConformsTo((__bridge CFStringRef _Nonnull)(UTI),(__bridge CFStringRef _Nonnull)(UTIType))) {
            return YES;
        }
    }
    if ([self.validFileTypes containsObject:@"public.content"]) {
        return YES;
    }
    return NO;
}

- (MetaFile *) parseFile:(NSDictionary *) dict {
    NSString *uuid = [dict objectForKey:@"uuid"];
    NSString *name = [dict objectForKey:@"name"];
    NSNumber *bytes = [dict objectForKey:@"bytes"];
    NSNumber *folder = [dict objectForKey:@"folder"];
    NSNumber *childCount = [dict objectForKey:@"childCount"];
    NSString *tempDownloadURL = [dict objectForKey:@"tempDownloadURL"];
    NSString *content_type = [dict objectForKey:@"content_type"];
    
    MetaFile *file = [[MetaFile alloc] init];
    if (uuid != nil || [uuid isKindOfClass:[NSNull class]]) {
        file.uuid = uuid;
    }
    if (name != nil || [name isKindOfClass:[NSNull class]]) {
        file.name = name;
    }
    if (bytes != nil || [bytes isKindOfClass:[NSNull class]]) {
        file.bytes = [bytes longValue];
    }
    if (folder != nil || [folder isKindOfClass:[NSNull class]]) {
        file.folder = [folder boolValue];
    }
    if (childCount != nil || [childCount isKindOfClass:[NSNull class]]) {
        file.itemCount = [childCount intValue];
    }
    if (tempDownloadURL != nil || [tempDownloadURL isKindOfClass:[NSNull class]]) {
        file.tempDownloadUrl = tempDownloadURL;
    }
    if (content_type != nil || [content_type isKindOfClass:[NSNull class]]) {
        file.rawContentType = content_type;
    }
    file.contentType = [self contentTypeByRawValue:file];
    
    NSDictionary *detailDict = [dict objectForKey:@"metadata"];
    if(detailDict != nil && ![detailDict isKindOfClass:[NSNull class]]) {
        NSString *thumbLarge = [detailDict objectForKey:@"Thumbnail-Large"];
        NSString *thumbMedium = [detailDict objectForKey:@"Thumbnail-Medium"];
        NSString *thumbSmall = [detailDict objectForKey:@"Thumbnail-Small"];
        NSString *videoPreview = [detailDict objectForKey:@"Video-Preview"];
        NSString *songTitle = [detailDict objectForKey:@"Title"];
        
        FileDetail *detail = [[FileDetail alloc] init];
        detail.thumbLargeUrl = thumbLarge;
        detail.thumbMediumUrl = thumbMedium;
        detail.thumbSmallUrl = thumbSmall;
        
        if (songTitle != nil || [songTitle isKindOfClass:[NSNull class]]) {
            detail.songTitle = songTitle;
        }
        if (videoPreview != nil || [videoPreview isKindOfClass:[NSNull class]]) {
            file.videoPreviewUrl = videoPreview;
        }
        
        file.detail = detail;
    }
    return file;
}

- (ContentType) contentTypeByRawValue:(MetaFile *) metaFile {
    if(metaFile.folder) {
        return ContentTypeFolder;
    }
    if([metaFile.rawContentType isEqualToString:CONTENT_TYPE_JPEG_VALUE] || [metaFile.rawContentType isEqualToString:CONTENT_TYPE_JPG_VALUE] || [metaFile.rawContentType isEqualToString:CONTENT_TYPE_PNG_VALUE]) {
        return ContentTypePhoto;
        //    } else if([metaFile.rawContentType isEqualToString:CONTENT_TYPE_AUDIO_MP3_VALUE] || [metaFile.rawContentType isEqualToString:CONTENT_TYPE_AUDIO_MPEG_VALUE]) {
        //            return ContentTypeMusic;
    } else if([metaFile.rawContentType hasPrefix:@"audio/"]) {
        return ContentTypeMusic;
    } else if([metaFile.rawContentType hasPrefix:@"video/"]) {
        return ContentTypeVideo;
    } else if ([metaFile.rawContentType hasPrefix:@"album/photo"]) {
        return ContentTypeAlbumPhoto;
    }else if([metaFile.rawContentType isEqualToString:CONTENT_TYPE_PDF_VALUE] || [metaFile.rawContentType isEqualToString:CONTENT_TYPE_DOC_VALUE] || [metaFile.rawContentType isEqualToString:CONTENT_TYPE_TXT_VALUE] || [metaFile.rawContentType isEqualToString:CONTENT_TYPE_HTML_VALUE]) {
        return ContentTypeDoc;
    }
    return ContentTypeOther;
}

-(void) showFileIsEmpty {
    UIImage *emptyImg = [UIImage imageNamed:@"empty_state_icon.png"];
    UIImageView *emptyImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 130)/2, self.view.frame.size.width, 130)];
    emptyImgView.contentMode = UIViewContentModeScaleAspectFit;
    emptyImgView.image = emptyImg;
    [self.view addSubview:emptyImgView];
    
    CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, emptyImgView.frame.origin.y + emptyImgView.frame.size.height + 10, self.view.frame.size.width, 24) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363E4F"] withText:[NSString stringWithFormat:NSLocalizedString(@"FolderEmptyMessage", @""), self.rootFolderName == nil ? NSLocalizedString(@"FilesTitle", @"") : self.rootFolderName]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
}


@end
