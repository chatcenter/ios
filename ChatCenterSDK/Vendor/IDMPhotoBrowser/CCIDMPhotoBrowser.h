//
//  IDMPhotoBrowser.h
//  IDMPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "CCIDMPhoto.h"
#import "CCIDMPhotoProtocol.h"
#import "CCIDMCaptionView.h"

// Delgate
@class CCIDMPhotoBrowser;
@protocol CCIDMPhotoBrowserDelegate <NSObject>
@optional
- (void)willAppearPhotoBrowser:(CCIDMPhotoBrowser *)photoBrowser;
- (void)willDisappearPhotoBrowser:(CCIDMPhotoBrowser *)photoBrowser;
- (void)photoBrowser:(CCIDMPhotoBrowser *)photoBrowser didShowPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(CCIDMPhotoBrowser *)photoBrowser didDismissAtPageIndex:(NSUInteger)index;
- (void)photoBrowser:(CCIDMPhotoBrowser *)photoBrowser willDismissAtPageIndex:(NSUInteger)index;
- (void)photoBrowser:(CCIDMPhotoBrowser *)photoBrowser didDismissActionSheetWithButtonIndex:(NSUInteger)buttonIndex photoIndex:(NSUInteger)photoIndex;
- (CCIDMCaptionView *)photoBrowser:(CCIDMPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
@end

// IDMPhotoBrowser
@interface CCIDMPhotoBrowser : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>

// Properties
@property (nonatomic, strong) id <CCIDMPhotoBrowserDelegate> delegate;

// Toolbar customization
@property (nonatomic) BOOL displayToolbar;
@property (nonatomic) BOOL displayCounterLabel;
@property (nonatomic) BOOL displayArrowButton;
@property (nonatomic) BOOL displayActionButton;
@property (nonatomic, strong) NSArray *actionButtonTitles;
@property (nonatomic, weak) UIImage *leftArrowImage, *leftArrowSelectedImage;
@property (nonatomic, weak) UIImage *rightArrowImage, *rightArrowSelectedImage;
@property (nonatomic, weak) UIImage *actionButtonImage, *actionButtonSelectedImage;
@property (nonatomic) CGRect doneButtonBounds;

// View customization
@property (nonatomic) BOOL displayDoneButton;
@property (nonatomic) BOOL useWhiteBackgroundColor;
@property (nonatomic, weak) UIImage *doneButtonImage;
@property (nonatomic, weak) UIColor *trackTintColor, *progressTintColor;

@property (nonatomic, weak) UIImage *scaleImage;

@property (nonatomic) BOOL arrowButtonsChangePhotosAnimated;

@property (nonatomic) BOOL forceHideStatusBar;
@property (nonatomic) BOOL usePopAnimation;
@property (nonatomic) BOOL disableVerticalSwipe;

@property (nonatomic) BOOL dismissOnTouch;

// Default value: true
// Set to false to tell the photo viewer not to hide the interface when scrolling
@property (nonatomic) BOOL autoHideInterface;

// Defines zooming of the background (default 1.0)
@property (nonatomic) float backgroundScaleFactor;

// Animation time (default .28)
@property (nonatomic) float animationDuration;

// Init
- (id)initWithPhotos:(NSArray *)photosArray;

// Init (animated from view)
- (id)initWithPhotos:(NSArray *)photosArray animatedFromView:(UIView*)view;

// Init with NSURL objects
- (id)initWithPhotoURLs:(NSArray *)photoURLsArray;

// Init with NSURL objects (animated from view)
- (id)initWithPhotoURLs:(NSArray *)photoURLsArray animatedFromView:(UIView*)view;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setInitialPageIndex:(NSUInteger)index;

// Get IDMPhoto at index
- (id<CCIDMPhoto>)photoAtIndex:(NSUInteger)index;

@end
