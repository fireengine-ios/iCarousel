//
//  PrintViewController.m
//  Depo
//
//  Created by Gürhan KODALAK on 28/07/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//


#import "PrintWebViewController.h"
#import "MetaFile.h"
#import "SyncUtil.h"
#import "ASIFormDataRequest.h"
#import "CurioSDK.h"
#import "CustomButton.h"
#import "MyNavigationController.h"

static const NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@interface PrintWebViewController ()

@end

@implementation PrintWebViewController

- (id) initWithUrl:(NSString *)url withFileList:(NSArray *)fileList{
    if (self = [super init]) {
        
        [[CurioSDK shared] sendEvent:@"PhotoPrint" eventValue:[NSString stringWithFormat:@"%lu",(unsigned long)[fileList count]]];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[self createPhotoJson:fileList],@"data", nil];
        
        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 200, 30) withImageName:nil withTitle:NSLocalizedString(@"PrintBackTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[UIColor whiteColor] isMultipleLine:YES];
        [cancelButton addTarget:self action:@selector(triggerBackToPhotos) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backToPhotos = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        [self.navigationItem setLeftBarButtonItem:backToPhotos];
        [self.navigationItem setRightBarButtonItem:nil];
        
        NSMutableURLRequest *printRequest = [self requestWithPost:dict];
        UIWebView *printWeb = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        printWeb.scalesPageToFit = YES;
        [self.view addSubview:printWeb];
        [printWeb loadRequest:printRequest];
        
    }
    return self;
}

- (BOOL) shouldAutorotate {
    return NO;
}

- (void) triggerBackToPhotos {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableURLRequest *) requestWithGet:(NSDictionary *) dictionary {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSJSONWritingPrettyPrinted];
    NSString *jsontoStr = @"http://akillidepo.cellograf.com/?jsonPhotos=";
    NSString *tempStr = [jsonStr stringByReplacingOccurrencesOfString:@"&" withString:@"\\u0026"];
    //NSString *tempStr2 = [tempStr stringByReplacingOccurrencesOfString:@"=" withString:@"\\u003"];
    NSString *finalStr = [NSString stringWithFormat:@"%@%@",jsontoStr,tempStr];
    NSLog(@"Final Str : %@",finalStr);
    
    NSString *webStr = [finalStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *finalUrl = [NSURL URLWithString:webStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:finalUrl];
    
    NSLog(@"Final URL:  %@",finalUrl);
    
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:30];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return request;
}

- (NSMutableURLRequest *) requestWithPost:(NSDictionary *) dictionary {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *urlString = @"http://akillidepo.cellograf.com";
    NSString *encodedURLString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *finalUrl = [NSURL URLWithString:encodedURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:finalUrl];
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:30];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%lu",(unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];

    return request;
}

- (NSDictionary *) createPhotoJson:(NSArray *)fileList {
    NSString *uid = [SyncUtil readBaseUrlConstant];
    NSString *request_id = [self randomStringWithLength:28];
    NSString *date_created = [self currentDateString];
    NSString *date_send = [self currentDateString];
    NSNumber *total_photos = [NSNumber numberWithLong:[fileList count]];
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (int i = 0; i<[fileList count]; i++) {
        MetaFile *tempFile = [fileList objectAtIndex:i];
        NSString *thumb =[tempFile.detail.thumbMediumUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *original = [tempFile.tempDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:thumb,@"thumb",original,@"original" ,nil];
        [photos addObject:tempDict];
    }
    
    NSMutableDictionary *jsonBodyDict = [[NSMutableDictionary alloc] init];
    [jsonBodyDict setValue:uid forKey:@"uid"];
    [jsonBodyDict setValue:request_id forKey:@"request_id"];
    [jsonBodyDict setValue:date_created forKey:@"date_created"];
    [jsonBodyDict setValue:date_send forKey:@"date_send"];
    [jsonBodyDict setValue:total_photos forKey:@"total_photos"];
    [jsonBodyDict setValue:photos forKey:@"photos"];
    
    
    return  jsonBodyDict;
}

- (NSString *) currentDateString {
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [DateFormatter stringFromDate:[NSDate date]];
}

-(NSString *) randomStringWithLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
       // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
