//
//  SSOverlayView.m
//  SSLoadingOverlay
//
//  Created by Sopan Sharma on 6/25/15.
//  Copyright (c) 2015 Sopan Sharma. All rights reserved.
//

#import "SSOverlayView.h"


#define kOverlayColor       [UIColor grayColor]
#define kOverlayFrame       CGRectMake(40.0f, 40.0f, 40.0f, 40.0f)
#define kSpinnerLineWidth  fmaxf(self.frame.size.width * 0.025, 1.f)


@interface SSOverlayView ()

@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, assign) BOOL isSpinning;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) UIColor *lineTintColor;

@end


@implementation SSOverlayView


- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    return self;
}


+ (SSOverlayView *)showLoadingOverlayOnView:(UIView *)iView {
    return [[self class] showLoadingOverlayWithTitle:@"" view:iView];
}


+ (SSOverlayView *)showLoadingOverlayWithTitle:(NSString *)iText view:(UIView *)iView {
    SSOverlayView *anOverlayView = [[SSOverlayView alloc] initWithFrame:kOverlayFrame];
    
    UILabel *aTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(-70.0f, 35.0f, 200.0f, 42.0f)];
    aTextLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18.0f];
    aTextLabel.textColor = kOverlayColor;
    aTextLabel.textAlignment = NSTextAlignmentCenter;
    aTextLabel.text = iText;
    [anOverlayView addSubview:aTextLabel];
    
    [anOverlayView start];
    [iView addSubview:anOverlayView];
    float aHeight = [[UIScreen mainScreen] bounds].size.height;
    float aWidth = [[UIScreen mainScreen] bounds].size.width;
    CGPoint center = CGPointMake(aWidth/2, aHeight/2);
    anOverlayView.center = center;
    
    return anOverlayView;
}


+ (void)hideLoadingOverlayFromView:(UIView *)iView {
    SSOverlayView *anOverlayView = [SSOverlayView overlayForView:iView];
    [anOverlayView stop];
    if (anOverlayView) {
        [anOverlayView removeFromSuperview];
    }
}


+ (SSOverlayView *)overlayForView:(UIView *)iView {
    SSOverlayView *anOverlay = nil;
    NSArray *aSubViewList = iView.subviews;
    for (UIView *aView in aSubViewList) {
        if ([aView isKindOfClass:[SSOverlayView class]]) {
            anOverlay = (SSOverlayView *)aView;
        }
    }
    
    return anOverlay;
}


- (void)start {
    self.isSpinning = YES;
    [self drawBackgroundCircle:YES];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [self.backgroundLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


- (void)stop {
    [self drawBackgroundCircle:NO];
    [self.backgroundLayer removeAllAnimations];
    self.isSpinning = NO;
}


- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.lineWidth = kSpinnerLineWidth;
    self.backgroundLayer = [CAShapeLayer layer];
    self.backgroundLayer.strokeColor = kOverlayColor.CGColor;
    self.backgroundLayer.fillColor = self.backgroundColor.CGColor;
    self.backgroundLayer.lineCap = kCALineCapRound;
    self.backgroundLayer.lineWidth = self.lineWidth;
    [self.layer addSublayer:self.backgroundLayer];
}


- (void)drawRect:(CGRect)iRect {
    self.backgroundLayer.frame = self.bounds;
}


- (void)drawBackgroundCircle:(BOOL)iPartial {
    // Create path
    CGFloat aStartAngle = - ((float)M_PI / 2); // 90 Degrees
    CGFloat theEndAngle = (2 * (float)M_PI) + aStartAngle;
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = (self.bounds.size.width - _lineWidth)/2;
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = self.lineWidth;

    if (iPartial) {
        theEndAngle = (1.8f * (float)M_PI) + aStartAngle;
    }
    
    [aPath addArcWithCenter:center radius:radius startAngle:aStartAngle endAngle:theEndAngle clockwise:YES];
    self.backgroundLayer.path = aPath.CGPath;
}


@end
