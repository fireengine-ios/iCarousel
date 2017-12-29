//
//  CRYShareImageViewController.h
//  CropyMain
//
//  Created by Ugur Eratalar on 11/07/16.
//  Copyright © 2016 Alper KIRDÖK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACEDrawingView.h"
#import "GPUImage.h"
#import "UIRotateImageView.h"
#import <MessageUI/MessageUI.h>
#import "SLDUtils.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "CRYUserContractViewController.h"
#import "SZTextView.h"
//@import imglyKit;

typedef enum {
    PhotoEventType = 0,
    CameraEventType = 1,
    WebEventType = 2
} ImageEventType;

@protocol CRYShareImageViewControllerProtocol <NSObject>

@optional

- (void)goToBrowserAndCrop;
- (void)goToBrowser;

@end

@interface CRYShareImageViewController : UIViewController <MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate,ACEDrawingViewDelegate, UITextViewDelegate, UITextFieldDelegate> {
    
    /* button */
    __weak IBOutlet UIButton *buttonShare;
    __weak IBOutlet UIButton *buttonCloseShareSheet;
    
    /* autolayout constraints */
    __weak IBOutlet NSLayoutConstraint *constraintShareSheetHeight; //248
    __weak IBOutlet NSLayoutConstraint *contraintImageViewWidth;    //270
    __weak IBOutlet NSLayoutConstraint *constraintImageViewHeight;  //373
    __weak IBOutlet NSLayoutConstraint *constraintShareTop;
    __weak IBOutlet NSLayoutConstraint *bgViewHeightConstraint;
    
    /* label */
    __weak IBOutlet UILabel *labelHeader;
    __weak IBOutlet UILabel *labelSave;
    __weak IBOutlet UILabel *labelEmail;
    __weak IBOutlet UILabel *labelOthers;
    
    /* drawView */
    
    __weak IBOutlet UICollectionView *schemeCollectionView;
    __weak IBOutlet UICollectionView *colorCollectionView;
    __weak IBOutlet UICollectionView *frameCollectionView;
    __weak IBOutlet UICollectionView *filterCollectionView;
    
    __weak IBOutlet NSLayoutConstraint *colorBGViewBottomContraint;
    __weak IBOutlet NSLayoutConstraint *frameViewBottomContraint;
    __weak IBOutlet NSLayoutConstraint *filterViewBottomContraint;
    __weak IBOutlet NSLayoutConstraint *bgViewLeadingConstraint;
    __weak IBOutlet NSLayoutConstraint *brightnessViewBottomConstraint;
    __weak IBOutlet NSLayoutConstraint *focusViewBottomConstraint;
    __weak IBOutlet NSLayoutConstraint *rotationViewBottomConstraint;
    
    __weak IBOutlet NSLayoutConstraint *bgImageViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *bgImageViewWidthConstraint;
    
    __weak IBOutlet NSLayoutConstraint *capsTextViewHeightConstraint;
    
    __weak IBOutlet UIButton *line1ButtonOutlet;
    __weak IBOutlet UIButton *line2ButtonOutlet;
    __weak IBOutlet UIButton *line3ButtonOutlet;
    __weak IBOutlet UIButton *doneButtonOutlet;
    
    __weak IBOutlet UIView *bgView;
    
    __weak IBOutlet ACEDrawingView *drawingView;
    /* scrollView */
    
    __weak IBOutlet UIButton *undoButtonOutlet;
    
    __weak IBOutlet UIView *othersButton;
    __weak IBOutlet UIButton *backButtonOutlet;
    __weak IBOutlet UIButton *exitButtonOutlet;
    __weak IBOutlet UIButton *shareButtonOutlet;
    __weak IBOutlet UIImageView *whatappShareImageView;
    __weak IBOutlet UILabel *whatsappShareLabel;
    __weak IBOutlet UIImageView *twitterShareImageView;
    __weak IBOutlet UIImageView *saveShareImageView;
    __weak IBOutlet UIImageView *linkedinShareImageView;
    __weak IBOutlet UIImageView *emailShareImageView;
    __weak IBOutlet UIImageView *otherShareImageView;
    __weak IBOutlet UIImageView *facebookShareImageView;
    __weak IBOutlet UIImageView *bipShareImageView;
    __weak IBOutlet UIImageView *akilliDepoShareImageView;
    
    __weak IBOutlet NSLayoutConstraint *scrollviewWidthContraint;
    
#pragma mark - Configurations
    
    __weak IBOutlet UIView *headerView;
    __weak IBOutlet UIView *safeAreaView;
    __weak IBOutlet UIView *bottomSafeAreaView;
    __weak IBOutlet UIView *colorBGView;
    __weak IBOutlet UIView *filterView;
    __weak IBOutlet UIView *brightnessView;
    __weak IBOutlet UIView *focusView;
    __weak IBOutlet UIView *rotationView;
    __weak IBOutlet UIView *frameView;
    __weak IBOutlet UIView *schemeView;
    __weak IBOutlet UIView *viewShareSheet;
    __weak IBOutlet UIView *undoView;

    
}

#pragma mark - Properties

@property (nonatomic, weak) id<CRYShareImageViewControllerProtocol> delegate;
@property (nonatomic, assign) BOOL comingFromPhotos;
@property (nonatomic, assign) BOOL comingFromExtension;
@property (nonatomic, assign) BOOL comingFromTutorial;
@property (nonatomic, assign) BOOL hasCropped;
@property (nonatomic, assign) BOOL comingFromMain;
@property (nonatomic, assign) BOOL capsHasText;

@property (nonatomic, assign) ImageEventType imageEventType;
@property (nonatomic, strong) NSString *UUID;
/* bool */
@property (nonatomic, assign) BOOL saveButtonChosen;
@property (nonatomic, assign) BOOL isSaved;
@property (nonatomic, assign) BOOL sharedAndSaved;

@property (nonatomic, assign) BOOL textMovedForKeyboard;
@property (nonatomic, assign) CGRect drawingViewTextViewFrame;
@property (nonatomic, assign) BOOL isComingFromMain;
/* string*/
@property (nonatomic, strong) NSString * shareUrl;
@property (nonatomic, strong) NSString * webTitle;
@property (nonatomic, strong) NSString *token;

/* NSTimeInterval */
@property (nonatomic, assign) NSTimeInterval lastClickTime;

/* bool */
@property (nonatomic, assign) BOOL isExists;
@property (nonatomic, assign) BOOL saveFirstTimeToAlbum;
@property (nonatomic, assign) BOOL saveButtonTapped;

/* image */
@property (nonatomic, strong) UIImage *imageToShare;

/* UIDocumentInteractionController */
@property (nonatomic, strong) UIDocumentInteractionController * documentInteractionController;

//About Draw Tools
@property (nonatomic, assign) NSInteger keepSelectedScheme;
@property (nonatomic, assign) NSInteger keepSelectedColor;
@property (nonatomic, assign) NSInteger keepSelectedFrame;
@property (nonatomic, assign) NSInteger keepSelectedFilter;

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgPixelImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *bgFocusImageView;

@property (nonatomic, assign) int typeScheme;
@property (nonatomic, assign) int typeColor;
@property (nonatomic, assign) int typeWidth;

@property (nonatomic, strong) NSMutableArray *notSelectedSchemeMaterials;
@property (nonatomic, strong) NSMutableArray *selectedSchemeMaterials;
@property (nonatomic, strong) NSMutableArray *colorMaterials;
@property (nonatomic, strong) NSMutableArray *frameImageMaterials;
@property (nonatomic, strong) NSMutableArray *frameNamesArray;
@property (nonatomic, strong) NSMutableArray *filterIconMaterials;
@property (nonatomic, strong) NSMutableArray *filterImageMaterials;
@property (nonatomic, strong) NSMutableArray *filterNameArray;
@property (nonatomic, strong) NSMutableArray *filterNameArray2;

@property (nonatomic, strong) UIImage *orginalImage;

//scrollView
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//bgImageView
@property (nonatomic, strong)UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, assign) CGSize myResize;
@property (nonatomic, assign) float imageHeight;

//pixellate Views
@property (nonatomic, assign)BOOL alreadyPixellated;
@property (nonatomic, strong)GPUImagePixellateFilter *pixellateFilter;

//brigthness/contrast sliders & views
@property (nonatomic, strong)UIImageView *filterScratchPad;
@property (nonatomic, strong)UIImageView *pixellateFilterScratchPad;

@property (nonatomic, strong)GPUImageBrightnessFilter *brightnessFilter;
@property (nonatomic, strong)GPUImageContrastFilter *contrastFilter;
@property (nonatomic, strong)GPUImageRGBFilter *rgbFilter;

@property (nonatomic, strong)IBOutlet UISlider *brightnessSlider;
@property (nonatomic, strong)IBOutlet UISlider *contrastSlider;

@property (nonatomic, strong)IBOutlet UILabel *brightnessLevelLabel;
@property (nonatomic, strong)IBOutlet UILabel *contrastLevelLabel;

@property (nonatomic, assign)BOOL comingFromBrightness;

//focus views
@property (nonatomic, assign)CGRect focusSourceRect;
@property (nonatomic, strong)UIImageView *focusBorderView;
@property (nonatomic, strong)UIImageView *focusImageView;
@property (nonatomic, strong)GPUImageGaussianBlurFilter *blurFilter;

@property (nonatomic, strong)IBOutlet UISlider *focusScaleSlider;
@property (nonatomic, assign)int focusCircleRadius;
@property (nonatomic, assign)CGFloat lastScale;
@property (nonatomic, assign)BOOL focusMoved;

@property (nonatomic, strong)UIPinchGestureRecognizer *focusPinchGestureRecognizer;
@property (nonatomic, strong)UIPanGestureRecognizer *focusPanGestureRecognizer;

@property (nonatomic, strong)UIImageView *focusScratchPad;
@property (nonatomic, strong)UIImageView *blurScratchPad;

//rotation views
@property (nonatomic, strong)IBOutlet UISlider *rotationSlider;
@property (nonatomic, strong)UIRotateImageView *rotationScratchPad;
@property (nonatomic, strong)UIRotateImageView *drawingViewRotationScratchPad;
@property (nonatomic, strong)UIImage *imageToRotate;

@property (nonatomic, assign)int rotateDegree;
@property (nonatomic, assign)BOOL rotateON;
@property (nonatomic, assign)BOOL hasRotated;
@property (nonatomic, assign)BOOL comingFromRotation;
@property (nonatomic, assign)BOOL inRotation;
@property (nonatomic, strong)IBOutlet UIButton *rotateSaveButton;

@property (nonatomic, assign)CGAffineTransform drawingViewTransform;
@property (nonatomic, assign)CGAffineTransform bgImageViewTransform;

@property (nonatomic, strong)UIView *rotationBorderView;
@property (nonatomic, strong)UIView *leftRectangle;
@property (nonatomic, strong)UIView *rightRectangle;
@property (nonatomic, strong)UIView *bottomRectangle;
@property (nonatomic, strong)UIView *topRectangle;

//CAPS views
@property (nonatomic, strong)SZTextView *capsTextView;
@property (nonatomic, strong)UIButton *smallText;
@property (nonatomic, strong)UIButton *mediumText;
@property (nonatomic, strong)UIButton *largeText;

@property (nonatomic, strong)UILabel *smallTextLabel;
@property (nonatomic, strong)UILabel *mediumTextLabel;
@property (nonatomic, strong)UILabel *largeTextLabel;

@property (nonatomic, strong)NSString *capString;
@property (nonatomic, assign)BOOL capsON;

@property (nonatomic, strong)IBOutlet UITextView *capsTextViewNew;

@property (nonatomic, assign)int defaultBGHeightConstraint;

//Filter and Frame Properties
@property (nonatomic, strong)UIImage *originalFilterImage;
@property (nonatomic, strong)UIImage *originalFrameImage;

@property (nonatomic, strong)UIImageView *frameBorderView;
@property (nonatomic, assign)BOOL frameSet;
@property (nonatomic, assign)BOOL imglyFrameSet;
@property (nonatomic, assign)int imglyFrameIndex;

@property (nonatomic, assign)BOOL hasShared;

@property (nonatomic, assign)BOOL hasEdited;


#pragma mark - Button Actions
- (IBAction)buttonShareTapped:(id)sender;
- (IBAction)buttonCloseShareSheetTapped:(id)sender;
- (IBAction)buttonWhatsAppTapped:(id)sender;
- (IBAction)buttonTwittterTapped:(id)sender;
- (IBAction)buttonSaveTapped:(id)sender;
- (IBAction)buttonLinkedInTapped:(id)sender;
- (IBAction)buttonOthersTapped:(id)sender;
- (IBAction)buttonEmailTapped:(id)sender;
- (IBAction)buttonFacebookTapped:(id)sender;
- (IBAction)buttonBipTapped:(id)sender;
- (IBAction)buttonAkilliDepoTapped:(id)sender;
- (IBAction)backButtonTapped:(id)sender;
- (IBAction)exitButtonTapped:(id)sender;

- (IBAction)line1ButtonTapped:(id)sender;
- (IBAction)line2ButtonTapped:(id)sender;
- (IBAction)line3ButtonTapped:(id)sender;
- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)undoButtonTapped:(id)sender;

#pragma mark - Configuration Properties



@end


