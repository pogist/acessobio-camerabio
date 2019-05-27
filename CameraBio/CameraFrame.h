//
//  CameraFrame.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 24/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColorBio.h"
#import "CameraValueFixed.h"

@class CameraMain;


NS_ASSUME_NONNULL_BEGIN

@interface CameraFrame : NSObject {
    
    UIView *rectangle;
    UIView *rectangleTop;
    UIView *rectangleLeft;
    UIView *rectangleRight;
    
    UILabel *labelMessage;
    
    UILabel *lbCountPic;
    
    NSTimer * timerCountDown;
    NSInteger countDown;
    
    
    BOOL isCountDown;
    
    float topOffsetPercent;
    float sizeBetweenTopAndBottomPercent;
    float marginOfSides;
    
}

- (id)initWithView:(CameraMain *)cameraMain button: (UIButton *)button autoCapture: (BOOL)autoCapture contagem: (BOOL) contagem view: (UIView*)view;

@property (strong, nonatomic) UIButton *btTakePicture;
@property (strong, nonatomic) UIView *view;

@property (assign, nonatomic) BOOL isAutoCapture;
@property (assign, nonatomic) BOOL isContagem;

@property (strong, nonatomic) CameraMain *cameraMain;

- (void)setupFrame;

-(void)setCountdownValue:(NSInteger)countdownValue;

- (void)setOffsetTopPercent : (float)percent;
- (void)setSizePercentBetweenTopAndBottom  : (float)percent;
- (float)getOffsetTopPercent;
- (float)getSizePercentBetweenTopAndBottom;
- (float)getMarginOfSides;


- (void)showRed;
- (void)showGray;
- (void)showGreen;

@end

NS_ASSUME_NONNULL_END
