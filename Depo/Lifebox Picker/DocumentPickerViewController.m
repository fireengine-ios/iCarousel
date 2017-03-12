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
    if(networkStatus == kReachableViaWiFi || networkStatus == kReachableViaWWAN) {
        [self requestForDocs:0 completion:^(NSMutableArray *list, NSError *error) {
            if (!error) {
                docList = list;
                dispatch_async(dispatch_get_main_queue(), ^{
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
    
//    UITableViewCell *cell = [self.docTable dequeueReusableCellWithIdentifier:@"DOC_CELL" forIndexPath:indexPath];
//    Document *doc = [docList objectAtIndex:indexPath.row];
//    cell.textLabel.text = doc.docName;
//    NSString *docSizeString = [Util transformedSizeValue:doc.docSize];
//    cell.detailTextLabel.text = docSizeString;
    
//    NSString *identifier = [NSString stringWithFormat:@"DOC_CELL_%d", (int)indexPath.row];
//    ShareDocCell *cell = [self.docTable dequeueReusableCellWithIdentifier:identifier];
//    
//    if (!cell) {
//        Document *doc = [docList objectAtIndex:indexPath.row];
//        cell.titleLabel.text = doc.docName;
//        NSString *docSizeString = [Util transformedSizeValue:doc.docSize];
//        cell.subTitleLabel.text = docSizeString;
//        
//        if (![self validFile:doc.docName]) {
//            [cell setUserInteractionEnabled:NO];
//            cell.backgroundColor = [UIColor grayColor];
//        }
//    }
    
    ShareDocCell *cell;
    Document *doc = [docList objectAtIndex:indexPath.row];
    
    if ([self validFile:doc.docName]) {
        cell = [self.docTable dequeueReusableCellWithIdentifier:@"DOC_CELL_ENABLED" forIndexPath:indexPath];
    } else {
        cell = [self.docTable dequeueReusableCellWithIdentifier:@"DOC_CELL_DISABLED" forIndexPath:indexPath];
    }
    
    cell.titleLabel.text = doc.docName;
    NSString *docSizeString = [Util transformedSizeValue:doc.docSize];
    cell.subTitleLabel.text = docSizeString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [indicator startAnimating];
    self.docTable.allowsSelection = NO;
    
    Document *doc = docList[indexPath.row];
    NSURL *url = [NSURL URLWithString:doc.tempDownloadURL];
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    NSURLSessionTask *downloadTask = [urlSession downloadTaskWithRequest:downloadRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [indicator stopAnimating];
        if (!error) {
            self.docTable.allowsSelection = YES;
            
            NSData *downloadedData = [NSData dataWithContentsOfURL:location];
            
            NSString *filePath = [storagePath stringByAppendingPathComponent:doc.docName];
            NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
            
            if([downloadedData writeToFile:filePath atomically:YES]) {
                [self dismissGrantingAccessToURL:fileUrl];
            }
        }
    }];
    
    [downloadTask resume];
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

-(void) requestForDocs:(int)pageNum completion:(void (^)(NSMutableArray *docList, NSError *error))completion {
    NSString *parentListingUrl = [NSString stringWithFormat:ELASTIC_LISTING_MAIN_URL, @"content_type", @"application%20OR%20text%20NOT%20directory", @"",@"DESC", pageNum, 21];
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
                if(data) {
                    Document *doc;
                    NSArray *mainArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    
                    NSMutableArray *list = [[NSMutableArray alloc] init];
                    if(mainArray != nil && [mainArray isKindOfClass:[NSArray class]]) {
                        for(NSDictionary *fileDict in mainArray) {
                            if([fileDict isKindOfClass:[NSDictionary class]]) {
                                doc = [[Document alloc] init];
                                doc.docName = [fileDict objectForKey:@"name"];
                                doc.tempDownloadURL = [fileDict objectForKey:@"tempDownloadURL"];
                                NSNumber *docSize = [fileDict objectForKey:@"bytes"];
                                doc.docSize = [docSize longValue];
                                [list addObject:doc];
                            }
                        }
                        completion(list,nil);
                    }
                }
                else {
                    completion(nil,nil);
                }
            }
            else {
                [self handleResponse:response completionHandler:^(NSError * _Nullable error) {
                    if(!error) {
                        [self requestForDocs:pageNum completion:^(NSMutableArray *list, NSError *error) {
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

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
//    CGFloat currentOffset = self.docTable.contentOffset.y;
//    CGFloat maximumOffset = self.docTable.contentSize.height - self.docTable.frame.size.height;
//    
//    if(currentOffset - maximumOffset >= 0.0) {
//        page++;
//        [self requestForDocs:page completion:^(NSMutableArray *list, NSError *error) {
//            if(!error) {
//                [docList addObjectsFromArray:list];
//                dispatch_async(dispatch_get_main_queue(), ^(){
//                    [self.docTable reloadData];
//                });
//            }
//        }];
//    }
//}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGFloat currentOffset = self.docTable.contentOffset.y;
    CGFloat maximumOffset = self.docTable.contentSize.height - self.docTable.frame.size.height;
    
    if(currentOffset - maximumOffset >= 0.0) {
        page++;
        [self requestForDocs:page completion:^(NSMutableArray *list, NSError *error) {
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
}

// check validity of document type
- (BOOL)validFile:(NSString *)file {
    NSArray *extensionArray = @[@"doc",@"docx",@"pdf",@"ppt",@"pptx",@"xls",@"xlsx"];
    NSString *extension = [file pathExtension];
    for (NSString *UTI in self.validTypes) {
        if ([UTI isEqualToString:@"public.content"]) {
            return YES;
        } else if ([UTI isEqualToString:@"public.text"]) {
            if ([extension isEqualToString:@"txt"]) {
                return YES;
            }
        } else if ([UTI isEqualToString:@"public.html"]) {
            if ([extension isEqualToString:@"html"]) {
                return YES;
            }
        } else {
            if ([extensionArray containsObject:extension]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
