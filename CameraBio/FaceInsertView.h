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


@class CameraBio;
//#import <BiometryFrameAcesso/FaceUtility.h>
@import GoogleMobileVision;


NS_ASSUME_NONNULL_BEGIN

@interface FaceInsertView : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
    
    BOOL isSelfie;
    UIView *rectangle;
    UIView *rectangleTop;
    UIView *rectangleLeft;
    UIView *rectangleRight;
    UILabel *labelMessage;

    AVCaptureVideoPreviewLayer *previewLayer;
    
    int countNoFace;
    int countTimeAlert;
    int countNoNose;

    BOOL isShowAlert;
    
    UIView *viewLog;
    UILabel *lbNosePosition;
    UILabel *lbRightEye;
    UILabel *lbLeftEye;
    UILabel *lbRightEar;
    UILabel *lbLeftEar;
    UILabel *lbEulerX;
    UILabel *lbSpaceEye;

    UILabel *lbCountPic;
    
    NSTimer * timerCountDown;
    NSInteger countDown;
    BOOL isCountDown;
    
}

// * Configurable
@property (assign, nonatomic) BOOL isDebug;
@property (assign, nonatomic) BOOL isCountdown;
@property (assign, nonatomic) BOOL isAutoCapture;


@property (nonatomic, strong) UIButton *btTakePic;

@property(nonatomic, strong) GMVDetector *faceDetector;

@property (nonatomic) AVCaptureDevicePosition defaultCamera;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) AVCaptureVideoDataOutput *dataOutput;
@property (nonatomic, assign) id delegate;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) NSLock *renderLock;
@property (nonatomic) CIImage *latestFrame;

@property (nonatomic) UIImageView *face;
@property (nonatomic) UIImageView *frame;

@property (strong, nonatomic) NSString *proccessId;

- (void)successProcces : (NSString *)processId;

@property (strong, nonatomic) CameraBio *cam;

@end

NS_ASSUME_NONNULL_END
