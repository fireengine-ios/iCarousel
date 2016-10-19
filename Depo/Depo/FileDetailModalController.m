//
//  FileDetailModalController.m
//  Depo
//
//  Created by Mahir on 03/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FileDetailModalController.h"
#import "Util.h"
#import "AppUtil.h"

@interface FileDetailModalController ()

@end

@implementation FileDetailModalController

@synthesize delegate;
@synthesize file;
@synthesize mainScroll;
@synthesize nameField;
@synthesize titleField;
@synthesize artistField;
@synthesize albumField;

- (id) initWithFile:(MetaFile *) _file {
    if(self = [super init]) {
        self.file = _file;
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"FileDetailTitle", @"");
        
        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        CustomButton *doneButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"DoneButtonTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [doneButton addTarget:self action:@selector(triggerDone) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
        self.navigationItem.rightBarButtonItem = doneItem;
        
        CGRect mainScrollRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex);
        if(IS_IPAD) {
            mainScrollRect = CGRectMake((self.view.frame.size.width - 500)/2, 0, 500, self.view.frame.size.height - self.bottomIndex);
        }
        
        mainScroll = [[UIScrollView alloc] initWithFrame:mainScrollRect];
        [self.view addSubview:mainScroll];
        
        float yIndex = self.topIndex + (IS_IPAD ? 100 : 30);

        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FileDetailNameTitle", @"")];
        [mainScroll addSubview:titleLabel];
        
        yIndex += 20;
        
        nameField = [[GeneralTextField alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"FileNamePlaceholder", @"")];
        nameField.delegate = self;
        NSString *fileNameWithoutExtension = [self.file.name stringByDeletingPathExtension];
        nameField.text = fileNameWithoutExtension;
        [mainScroll addSubview:nameField];
        
        yIndex += 63;

        if([AppUtil isMetaFileMusic:self.file]) {
            CustomLabel *songTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"SongTitleFieldTitle", @"")];
            [mainScroll addSubview:songTitleLabel];
            
            yIndex += 20;
            
            titleField = [[GeneralTextField alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, 43) withPlaceholder:@""];
            titleField.delegate = self;
            titleField.text = (self.file.detail && self.file.detail.songTitle) ? self.file.detail.songTitle : @"";
            titleField.userInteractionEnabled = NO;
            [mainScroll addSubview:titleField];
            
            yIndex += 63;

            CustomLabel *artistLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"ArtistFieldTitle", @"")];
            [mainScroll addSubview:artistLabel];
            
            yIndex += 20;
            
            artistField = [[GeneralTextField alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, 43) withPlaceholder:@""];
            artistField.delegate = self;
            artistField.text = (self.file.detail && self.file.detail.artist) ? self.file.detail.artist : @"";
            artistField.userInteractionEnabled = NO;
            [mainScroll addSubview:artistField];
            
            yIndex += 63;

            CustomLabel *albumLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"AlbumFieldTitle", @"")];
            [mainScroll addSubview:albumLabel];
            
            yIndex += 20;
            
            albumField = [[GeneralTextField alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, 43) withPlaceholder:@""];
            albumField.delegate = self;
            albumField.text = (self.file.detail && self.file.detail.album) ? self.file.detail.album : @"";
            albumField.userInteractionEnabled = NO;
            [mainScroll addSubview:albumField];
            
            yIndex += 63;
        }
        
        NSString *detailsMainTitle = NSLocalizedString(@"FileDetailSegmentTitle", @"");
        if([AppUtil isMetaFileMusic:self.file]) {
            detailsMainTitle = NSLocalizedString(@"TrackDetailSegmentTitle", @"");
        }
        CustomLabel *detailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"363e4f"] withText:detailsMainTitle];
        [mainScroll addSubview:detailLabel];
        
        yIndex += 30;

        UIView *detailSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, yIndex, mainScroll.frame.size.width, 1)];
        detailSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
        [mainScroll addSubview:detailSeparator];

        yIndex += 16;

        if([AppUtil isMetaFileMusic:self.file]) {
            //duration segment
            CustomLabel *durationLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, 175, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"DurationTitle", @"")];
            [mainScroll addSubview:durationLabel];
            
            NSString *durationVal = @"";
            if(self.file.detail && self.file.detail.duration) {
                int durationInSec = floor(self.file.detail.duration/1000);
                int durationInMin = floor(durationInSec/60);
                int remainingSec = durationInSec - durationInMin*60;
                durationVal = [NSString stringWithFormat:@"%d:%@%d", durationInMin, remainingSec <=9 ? @"0": @"", remainingSec];
            }
            CustomLabel *durationValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(mainScroll.frame.size.width - 115, yIndex, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:durationVal];
            durationValueLabel.textAlignment = NSTextAlignmentRight;
            [mainScroll addSubview:durationValueLabel];
            
            yIndex += 40;

            UIView *durationSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, yIndex, mainScroll.frame.size.width, 1)];
            durationSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
            [mainScroll addSubview:durationSeparator];
            
            yIndex += 16;
        }

        //size segment
        CustomLabel *sizeLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, 175, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FolderDetailSize", @"")];
        [mainScroll addSubview:sizeLabel];
        
        CustomLabel *sizeValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(mainScroll.frame.size.width - 115, yIndex, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[Util transformedSizeValue:self.file.bytes]];
        sizeValueLabel.textAlignment = NSTextAlignmentRight;
        [mainScroll addSubview:sizeValueLabel];
        
        yIndex += 40;

        UIView *sizeSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, yIndex, mainScroll.frame.size.width, 1)];
        sizeSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
        [mainScroll addSubview:sizeSeparator];
        
        yIndex += 16;

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd MMM yyyy"];

        if([AppUtil isMetaFileImage:self.file]) {
            CustomLabel *dateLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, 175, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FileDetailUploadDate", @"")];
            [mainScroll addSubview:dateLabel];
            
            CustomLabel *dateValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(mainScroll.frame.size.width - 115, yIndex, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[dateFormat stringFromDate:self.file.detail.createdDate]];
            dateValueLabel.textAlignment = NSTextAlignmentRight;
            [mainScroll addSubview:dateValueLabel];
            
            yIndex += 40;
            
            UIView *dateSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, yIndex, mainScroll.frame.size.width, 1)];
            dateSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
            [mainScroll addSubview:dateSeparator];
            
            yIndex += 11;

            CustomLabel *imageDateLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, 175, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FileDetailCreateDate", @"")];
            [mainScroll addSubview:imageDateLabel];
            
            CustomLabel *imageDateValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(mainScroll.frame.size.width - 115, yIndex, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[dateFormat stringFromDate:self.file.detail.imageDate]];
            imageDateValueLabel.textAlignment = NSTextAlignmentRight;
            [mainScroll addSubview:imageDateValueLabel];
            
            yIndex += 40;
            
            UIView *imageDateSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, yIndex, mainScroll.frame.size.width, 1)];
            imageDateSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
            [mainScroll addSubview:imageDateSeparator];
            
            yIndex += 11;
        } else {
            //modify date segment
            CustomLabel *dateLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, 175, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FolderDetailModifyDate", @"")];
            [mainScroll addSubview:dateLabel];
            
            CustomLabel *dateValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(mainScroll.frame.size.width - 115, yIndex, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[dateFormat stringFromDate:self.file.lastModified]];
            dateValueLabel.textAlignment = NSTextAlignmentRight;
            [mainScroll addSubview:dateValueLabel];
            
            yIndex += 40;
            
            UIView *dateSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, yIndex, mainScroll.frame.size.width, 1)];
            dateSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
            [mainScroll addSubview:dateSeparator];
            
            yIndex += 11;
        }

        mainScroll.contentSize = CGSizeMake(mainScroll.frame.size.width, yIndex);
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerResign)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void) triggerDone {
    NSString *finalName = nameField.text;
    NSString *filePath = [self.file.name pathExtension];
    NSString *addedDot = [finalName stringByAppendingString:@"."];
    NSString *finalNameWithExtension = [addedDot stringByAppendingString:filePath];
    if(![finalNameWithExtension isEqualToString:self.file.name]) {
        [delegate fileDetailShouldRename:finalName];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:nameField]) {
        return NO;
    }
    return YES;
}

- (void) triggerResign {
    [nameField resignFirstResponder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [nameField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [nameField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
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
