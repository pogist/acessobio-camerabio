//
//  FaceInsertView.h
//  CaptureAcesso
//
//  Created by Matheus  domingos on 27/03/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import "UIImageUtils.h"
#import "UIView+Toast.h"
#import "CameraMain.h"

@class CameraBio;
//#import <BiometryFrameAcesso/FaceUtility.h>

NS_ASSUME_NONNULL_BEGIN

@interface FaceInsertView : CameraMain

@property (nonatomic) UIImageView *face;
@property (nonatomic) UIImageView *frame;

@property (strong, nonatomic) NSString *proccessId;



@property(assign, nonatomic) BOOL isAutoCapture;
@property(assign, nonatomic) BOOL isCountdown;

@property (strong, nonatomic) CameraBio *cam;



@end

NS_ASSUME_NONNULL_END
