//
//  IDMZoomingScrollView.h
//  IDMPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCIDMPhotoProtocol.h"
#import "CCIDMTapDetectingImageView.h"
#import "CCIDMTapDetectingView.h"

#import "CCDACircularProgressView.h"

@class CCIDMPhotoBrowser, CCIDMPhoto, CCIDMCaptionView;

@interface CCIDMZoomingScrollView : UIScrollView <UIScrollViewDelegate, CCIDMTapDetectingImageViewDelegate, CCIDMTapDetectingViewDelegate> {
	
	CCIDMPhotoBrowser *__weak _photoBrowser;
    id<CCIDMPhoto> _photo;
	
    // This view references the related caption view for simplified handling in photo browser
    CCIDMCaptionView *_captionView;
    
	CCIDMTapDetectingView *_tapView; // for background taps
    
    CCDACircularProgressView *_progressView;
}

@property (nonatomic, strong) CCIDMTapDetectingImageView *photoImageView;
@property (nonatomic, strong) CCIDMCaptionView *captionView;
@property (nonatomic, strong) id<CCIDMPhoto> photo;
@property (nonatomic) CGFloat maximumDoubleTapZoomScale;

- (id)initWithPhotoBrowser:(CCIDMPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setProgress:(CGFloat)progress forPhoto:(CCIDMPhoto*)photo;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;

@end
