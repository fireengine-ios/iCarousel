/*
 * ACEDrawingView: https://github.com/acerbetti/ACEDrawingView
 *
 * Copyright (c) 2013 Stefano Acerbetti
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import <UIKit/UIKit.h>
#import "ACEDrawingLabelView.h"
#import "ACEDrawingTools.h"
#import "GPUImage.h"
#import "MyTextView.h"

#define ACEDrawingViewVersion   2.0.0

typedef enum {
    ACEDrawingToolTypeNone,
    ACEDrawingToolTypePen,
    ACEDrawingToolTypeLine,
    ACEDrawingToolTypeArrow,
    ACEDrawingToolTypeRectagleStroke,
    ACEDrawingToolTypeRectagleFill,
    ACEDrawingToolTypeEllipseStroke,
    ACEDrawingToolTypeEllipseFill,
    ACEDrawingToolTypeEraser,
    ACEDrawingToolTypeDraggableText,
    ACEDrawingToolTypeText,
    ACEDrawingToolTypeMultilineText,
    ACEDrawingToolTypeCustom,
    ACEDrawingToolTypePixelated,
    ACEDrawingToolTypeOtherEffects
} ACEDrawingToolType;

typedef NS_ENUM(NSUInteger, ACEDrawingMode) {
    ACEDrawingModeScale,
    ACEDrawingModeOriginalSize
};

@protocol ACEDrawingViewDelegate, ACEDrawingTool;

@interface ACEDrawingView : UIView<ACEDrawingLabelViewDelegate, UIGestureRecognizerDelegate, UITextViewDelegate>

@property (nonatomic, strong)UIImage *originalImage;

//extension properties
@property (nonatomic, assign)BOOL fromExtension;
@property (nonatomic, assign)BOOL onlyDrawing;

//--------------------------------------------------PIXEL & FOCUS CODE PROPERTIES-------------------------------------------------------------//
@property (nonatomic, strong)UIImageView *pixellatedImageView;
@property (nonatomic, strong)UIImageView *focusImageView;
@property (nonatomic, strong)UIImageView *bgImageView;

@property (nonatomic, assign)float pixelWidth;
@property (nonatomic, assign)float pixelHeight;
@property (nonatomic, assign)int numOfPixels;

@property (nonatomic, assign)float adjustedImgWidth;
@property (nonatomic, assign)float adjustedImgHeight;

@property (nonatomic, assign)int numOfPixelsPerRow;

@property (nonatomic, assign)CGPoint lastTouch;
@property (nonatomic, assign)CGPoint currentTouch;

@property (nonatomic, assign)BOOL isPixellating;
@property (nonatomic, strong)GPUImagePixellateFilter *pixellateFilter;

@property (nonatomic, assign)BOOL moreThanOneFinger;

- (void)pixelateTheImage;
- (void)blurTheImage;

@property (nonatomic, strong)UIImageView *focusCenter;
@property (nonatomic, assign)BOOL isFocusing;

//---------------------------------------------------OTHER EFFECTS TOOL PROPERTIES--------------------------------------------------------------------//

- (void)addUndoForOtherEffects:(UIImage *)latestUndoImage;
@property (nonatomic, strong)NSMutableArray *otherEffectsPicArray;
@property (nonatomic, assign)BOOL hasFiltered;
@property (nonatomic, assign)int filterCount;


//- (void)addUndoForOtherEffects:(UIImage *)latestUndoImage forType:(EffectType)effectType;
- (void)addUndoForOtherEffects:(UIImage *)latestUndoImage forType:(EffectType)effectType forFrameImage:(UIImage *)frameImage forTransform:(CGAffineTransform)drawingViewTransform;
- (void)originalImageUndo:(EffectType)effectType;


@property (nonatomic, strong)NSMutableDictionary *textAttributesDictionary;

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, assign) CGFloat originalFrameYPos;
//@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) MyTextView *textView;
@property (nonatomic, assign) ACEDrawingToolType drawTool;
@property (nonatomic, strong) id<ACEDrawingTool> customDrawTool;
@property (nonatomic, assign) id<ACEDrawingViewDelegate> delegate;

// public properties
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat lineAlpha;
@property (nonatomic, assign) CGFloat edgeSnapThreshold;
@property (nonatomic, assign) ACEDrawingMode drawMode;

@property (nonatomic, strong) NSString *draggableTextFontName;
@property (nonatomic, strong) UIImage *draggableTextCloseImage;
@property (nonatomic, strong) UIImage *draggableTextRotateImage;

@property (nonatomic, strong) UIImage *theImage;

// get the current drawing
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, readonly) NSUInteger undoSteps;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;

// dragging properties
@property (nonatomic, strong) NSNumber* selectedShapeIndex;
@property (nonatomic, assign) BOOL isDraggingActive;
// load external image
- (void)loadImage:(UIImage *)image;
- (void)loadImageData:(NSData *)imageData;

// erase all
- (void)clear;

- (void)commitAndHideTextEntry;
- (void)endTextEditing;
- (void)closeTextTapped;

// cleanup in preparation for taking a snapshot
- (void)prepareForSnapshot;

// undo / redo
- (BOOL)canUndo;
- (void)undoLatestStep;

- (BOOL)canRedo;
- (void)redoLatestStep;

- (void)undoForFilter;



/**
 @discussion Discards the tool stack and renders them to prev_image, making the current state the 'start' state.
 (Can be called before resize to make content more predictable)
 */
- (void)commitAndDiscardToolStack;

@end

#pragma mark - 

@interface ACEDrawingView (Deprecated)
@property (nonatomic, strong) UIImage *prev_image DEPRECATED_MSG_ATTRIBUTE("Use 'backgroundImage' instead.");
@end

#pragma mark -

@protocol ACEDrawingViewDelegate <NSObject>

@optional
- (void)drawingView:(ACEDrawingView *)view willBeginDrawUsingTool:(id<ACEDrawingTool>)tool;
- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool;
- (void)drawingView:(ACEDrawingView *)view didRedoDrawUsingTool:(id<ACEDrawingTool>)tool;
- (void)drawingView:(ACEDrawingView *)view didUndoDrawUsingTool:(id<ACEDrawingTool>)tool;
- (void)drawingView:(ACEDrawingView *)view didMoveTool:(id<ACEDrawingTool>)tool;
- (void)updateButtonStatus;
- (void)disableUndoForEditing:(BOOL)disable;

- (void)clearScratchPadsFromUndo:(BOOL)undo;
- (void)removeCapsView;
- (void)setupCapsViewWithUndo:(BOOL)undo;
- (void)removeFrameBorderView;
- (void)setFrameBorderViewMethodWithFrameImage:(UIImage *)effectFrameImage;
- (void)resetPixelRotation;
- (void)updatePixelsAfterRotating;
- (void)undoForFilter;
- (void)undoForDrawingView:(CGAffineTransform)drawingViewTransform;
- (void)closeRotation;
- (void)updateBGImageViewAfterUndo:(UIImage *)undoImage;
- (void)updateViewAfterTextSelectionWithColor:(UIColor *)color LineWidth:(CGFloat)lineWidth;

@end
