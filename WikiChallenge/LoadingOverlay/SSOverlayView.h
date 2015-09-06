//
//  SSOverlayView.h
//  SSLoadingOverlay
//
//  Created by Sopan Sharma on 6/25/15.
//  Copyright (c) 2015 Sopan Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSOverlayView : UIView

- (void)start;
- (void)stop;
+ (SSOverlayView *)showLoadingOverlayOnView:(UIView *)iView;
+ (SSOverlayView *)showLoadingOverlayWithTitle:(NSString *)iText view:(UIView *)iView;
+ (void)hideLoadingOverlayFromView:(UIView *)iView;

@end
