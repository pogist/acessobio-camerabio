
//
//  FaceInsertView.m
//  CaptureAcesso
//
//  Created by Matheus  domingos on 27/03/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import "FaceInsertView.h"
#import "CameraBio.h"

#define NAME_APPLICATION [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define TAB_HEIGHT self.tabBarController.tabBar.frame.size.height

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

#define PLATAFORM = [[[UIDevice currentDevice] systemVersion] intValue];

float topOffsetPercent = 30.0f;
float sizeBetweenTopAndBottomPercent = 50.0f;
float marginOfSides = 80.0f;

@interface FaceInsertView ()

@end

@implementation FaceInsertView


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    countDown = 3;
    
    [self setIsDebug:YES];
    
    [self setOffsetTopPercent:30.0f];
    [self setSizePercentBetweenTopAndBottom:20.0f];
    
    isSelfie = YES;
    [self setupCamera:isSelfie];
    [self startCamera];
    
    
    // Initialize the face detector.
    NSDictionary *options = @{
                              GMVDetectorFaceMode : @(GMVDetectorFaceAccurateMode),
                              GMVDetectorFaceMinSize : @(0.1),
                              GMVDetectorFaceTrackingEnabled : @(YES),
                              GMVDetectorFaceLandmarkType : @(GMVDetectorFaceLandmarkAll)
                              };
    self.faceDetector = [GMVDetector detectorOfType:GMVDetectorTypeFace options:options];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start special animation */
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            /* start special animation */
            
            NSLog(@"entrou landscpae");
            [self showRed];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"entrou landscpae");
            [self showRed];
            
            break;
        default:
            break;
    };
}

- (void) setupCamera:(BOOL) isSelfie {
    
    self.session = [[AVCaptureSession alloc] init];
    self.delegate = self;
    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.renderLock = [[NSLock alloc] init];
    
    NSError *error = nil;
    
    if (isSelfie) {
        self.defaultCamera = AVCaptureDevicePositionFront;
    } else {
        self.defaultCamera = AVCaptureDevicePositionBack;
    }
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    AVCaptureDevice *videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:self.defaultCamera];
    
    if ([videoDevice hasFlash] && [videoDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
        if ([videoDevice lockForConfiguration:&error]) {
            [videoDevice setFlashMode:AVCaptureFlashModeOff];
            [videoDevice unlockForConfiguration];
        } else {
            NSLog(@"%@", error);
        }
    }
    
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (!videoDeviceInput) {
        NSLog(@"No Input");
    }
    
    if ([[videoDeviceInput device] supportsAVCaptureSessionPreset:AVCaptureSessionPreset1280x720]) {
        
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
        
    } else if ([[videoDeviceInput device] supportsAVCaptureSessionPreset:AVCaptureSessionPreset640x480]) {
        
        self.session.sessionPreset = AVCaptureSessionPreset640x480;
        
    }
    
    if ([self.session canAddInput:videoDeviceInput]) {
        [self.session addInput:videoDeviceInput];
        self.videoDeviceInput = videoDeviceInput;
    }
    
    
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([self.session canAddOutput:stillImageOutput]) {
        [self.session addOutput:stillImageOutput];
        [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecTypeJPEG}];
        self.stillImageOutput = stillImageOutput;
    }
    
    self.dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    if ([self.session canAddOutput:self.dataOutput]) {
        self.dataOutput = self.dataOutput;
        [self.dataOutput setAlwaysDiscardsLateVideoFrames:YES];
        [self.dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        
        [self.dataOutput setSampleBufferDelegate:self.delegate queue:self.sessionQueue];
        
        [self.session addOutput:self.dataOutput];
    }
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    UIView *myView = self.view;
    previewLayer.frame = myView.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:previewLayer];
    
    rectangle = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 5, self.view.bounds.size.width, 5)];
    [rectangle setBackgroundColor:[UIColor redColor]];
    
    [self.view addSubview:rectangle];
    
    rectangleTop = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 5)];
    [rectangleTop setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:rectangleTop];
    
    rectangleLeft = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, self.view.bounds.size.height)];
    [rectangleLeft setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:rectangleLeft];
    
    rectangleRight = [[UIView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 5, 0, 5, self.view.bounds.size.height)];
    [rectangleRight setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:rectangleRight];
    
    self.btTakePic = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH/2) - 40, SCREEN_HEIGHT - 100, 80, 80)];
    [self.btTakePic setImage:[UIImage imageNamed:@"icon_take_pic"] forState:UIControlStateNormal];
    [self.btTakePic addTarget:self action:@selector(invokeTakePicture) forControlEvents:UIControlEventTouchUpInside];
    [self.btTakePic setAlpha:0.5];
    [self.btTakePic setEnabled:NO];
    [self.view addSubview:self.btTakePic];
    
    /*  UIButton *btSwitch = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 50) - 20, SCREEN_HEIGHT - 90, 50, 50)];
     [btSwitch setImage:[UIImage imageNamed:@"switch_cam"] forState:UIControlStateNormal];
     [[btSwitch imageView] setContentMode: UIViewContentModeScaleAspectFit];
     [btSwitch addTarget:self action:@selector(switchCam) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:btSwitch]; */
    
    
    if(self.isDebug) {
        
        UIButton *btClear = [[UIButton alloc]initWithFrame:CGRectMake(20, SCREEN_HEIGHT - 100 , 80, 50)];
        [btClear setTitle:@"RESET" forState:UIControlStateNormal];
        [btClear.titleLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:14.0]];
        [btClear setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btClear setBackgroundColor:[UIColor blackColor]];
        [btClear addTarget:self action:@selector(clearDots) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btClear];
        
        
        viewLog = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 160)];
        [viewLog setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:viewLog];
        
        lbLeftEye = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 150, 20)];
        [lbLeftEye setFont:[UIFont systemFontOfSize:10.0]];
        [lbLeftEye setTextColor: [UIColor blackColor]];
        [lbLeftEye setTag:-1];
        [viewLog addSubview:lbLeftEye];
        
        lbRightEye = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 150, 20)];
        [lbRightEye setFont:[UIFont systemFontOfSize:10.0]];
        [lbRightEye setTextColor: [UIColor blackColor]];
        [lbRightEye setTag:-1];
        [viewLog addSubview:lbRightEye];
        
        lbNosePosition = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 150, 20)];
        [lbNosePosition setFont:[UIFont systemFontOfSize:10.0]];
        [lbNosePosition setTextColor: [UIColor blackColor]];
        [lbNosePosition setTag:-1];
        [viewLog addSubview:lbNosePosition];
        
        lbLeftEar = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 150, 20)];
        [lbLeftEar setFont:[UIFont systemFontOfSize:10.0]];
        [lbLeftEar setTextColor: [UIColor blackColor]];
        [lbLeftEar setTag:-1];
        [viewLog addSubview:lbLeftEar];
        
        lbRightEar = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 150, 20)];
        [lbRightEar setFont:[UIFont systemFontOfSize:10.0]];
        [lbRightEar setTextColor: [UIColor blackColor]];
        [lbRightEar setTag:-1];
        [viewLog addSubview:lbRightEar];
        
        lbEulerX = [[UILabel alloc]initWithFrame:CGRectMake(10, 120, 150, 20)];
        [lbEulerX setFont:[UIFont systemFontOfSize:10.0]];
        [lbEulerX setTextColor: [UIColor blackColor]];
        [lbEulerX setTag:-1];
        [viewLog addSubview:lbEulerX];
        
        lbSpaceEye = [[UILabel alloc]initWithFrame:CGRectMake(10, 140, 150, 20)];
        [lbSpaceEye setFont:[UIFont systemFontOfSize:10.0]];
        [lbSpaceEye setTextColor: [UIColor blackColor]];
        [lbEulerX setTag:-1];
        [viewLog addSubview:lbSpaceEye];
        
        
        UIView *v1 = [[UIView alloc]initWithFrame:CGRectMake(0, topOffsetPercent, SCREEN_WIDTH, 2)];
        [v1 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v1];
        
        UIView *v2 = [[UIView alloc]initWithFrame:CGRectMake(0, sizeBetweenTopAndBottomPercent, SCREEN_WIDTH, 2)];
        [v2 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v2];
        
        UIView *v3 = [[UIView alloc]initWithFrame:CGRectMake(marginOfSides, 0, 2, SCREEN_HEIGHT)];
        [v3 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v3];
        
        UIView *v4 = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - marginOfSides, 0, 2, SCREEN_HEIGHT)];
        [v4 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v4];
        
        
    }
    
    lbCountPic = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH/2) - 50, (SCREEN_HEIGHT/2) - 60 , 100, 120)];
    [lbCountPic setTextColor: [UIColor darkGrayColor]];
    [lbCountPic setTag:-1];
    [lbCountPic setText:@"3"];
    [lbCountPic setTextAlignment:NSTextAlignmentCenter];
    [lbCountPic setAlpha:0.7];
    [lbCountPic setFont:[UIFont fontWithName:@"Avenir-Medium" size:120]];
    [lbCountPic setHidden:YES];
    [self.view addSubview:lbCountPic];
    
    [self updateOrientation:[self getCurrentOrientation]];
    
    self.view.userInteractionEnabled = TRUE;
}

- (void)setIsDebug : (BOOL)debug {
    self.isDebug = debug;
}

- (void)setOffsetTopPercent : (float)percent {
    topOffsetPercent = percent/100 *  SCREEN_HEIGHT;
}

- (void)setSizePercentBetweenTopAndBottom  : (float)percent {
    float pixels = percent/100 *  SCREEN_HEIGHT;
    sizeBetweenTopAndBottomPercent = topOffsetPercent + pixels;
}

- (void)setMarginOfSides: (float)margin {
    marginOfSides = margin;
}

- (void)clearDots {
    for (UIView *view in [self.view subviews]) {
        if(view.tag == - 1) {
            [view removeFromSuperview];
        }
    }
}

- (void)addCircleToPoint : (CGPoint) point color : (UIColor *)color{
    
    CGFloat widht = 10;
    
    CGFloat POINT_X = point.x;
    CGFloat POINT_Y = point.y;
    
    CGRect circleRect = CGRectMake(POINT_X - (widht / 2), POINT_Y - (widht / 2), widht, widht);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIView *circleView = [[UIView alloc] initWithFrame:circleRect];
        circleView.layer.cornerRadius = widht/2;
        circleView.alpha = 0.7;
        circleView.backgroundColor = color;
        circleView.tag = -1;
        [self.view addSubview:circleView];
        
    });
    
}

- (void)addLabelToLog : (CGPoint) point type : (NSString * )type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([type isEqualToString:@"left_eye"]) {
            [self->lbLeftEye setText:[NSString stringWithFormat:@"Leyft eye - X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"right_eye"]) {
            [self->lbRightEye setText:[NSString stringWithFormat:@"Right eye - X: %.0f Y: %.0f", point.x, point.y]];
        }if([type isEqualToString:@"left_ear"]) {
            [self->lbLeftEar setText:[NSString stringWithFormat:@"Leyft ear - X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"right_ear"]) {
            [self->lbRightEar setText:[NSString stringWithFormat:@"Right ear - X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"euler"]) {
            [self->lbEulerX setText:[NSString stringWithFormat:@"Euler X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"space-eye"]) {
            [self->lbSpaceEye setText:[NSString stringWithFormat:@"Space eye: %.0f", point.x]];
        }else{
            [self->lbNosePosition setText:[NSString stringWithFormat:@"Base nose - X: %.0f Y: %.0f", point.x, point.y]];
        }
        
    });
    
}

- (void) startCamera {
    [self.session startRunning];
}

- (void) stopCamera {
    [self.session stopRunning];
}


- (void) restartCameraTap:(UITapGestureRecognizer*)recognizer {
    self.face.hidden = TRUE;
    self.frame.hidden = NO;
    
    [self.view removeGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(restartCameraTap:)]];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTakePictureTap:)]];
    
    [self startCamera];
}



- (void) invokeTakePicture {
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef sampleBuffer, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            [self.renderLock lock];
            [self.renderLock unlock];
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage *capturedImage = [[UIImage alloc] initWithData:imageData];
            
            if (self.defaultCamera == AVCaptureDevicePositionFront) {
                capturedImage = [UIImageUtils flipImage:[UIImageUtils imageRotatedByDegrees:capturedImage deg:-90]];
            } else {
                capturedImage = [UIImageUtils imageRotatedByDegrees:capturedImage deg:90];
            }
            
            [self stopCamera];
            
            NSString* base64;
            base64 = [UIImageUtils getBase64Image: capturedImage]; // Utilizar esse base64 para a validação no WebService
            [self actionAfterTakePicture:base64];
            
        }
    }];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,
                                                                 sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc]
                              initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata
                                   objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata
                              objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    NSLog(@"ILUMINAÇÃO: %.2f", brightnessValue);
    
    
    UIImage *image = [GMVUtility sampleBufferTo32RGBA:sampleBuffer];
    
    AVCaptureDevicePosition devicePosition =  AVCaptureDevicePositionFront;
    
    
    // Establish the image orientation.
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    GMVImageOrientation orientation = [GMVUtility
                                       imageOrientationFromOrientation:deviceOrientation
                                       withCaptureDevicePosition:devicePosition
                                       defaultDeviceOrientation:UIDeviceOrientationFaceUp];
    NSDictionary *options = @{
                              GMVDetectorImageOrientation : @(orientation)
                              };
    // Detect features using GMVDetector.
    NSArray<GMVFaceFeature *> *faces = [self.faceDetector featuresInImage:image options:options];
    NSLog(@"Detected %lu face(s).", (unsigned long)[faces count]);
    
    
    NSLog(@"%.2f", SCREEN_WIDTH);
    NSLog(@"%.2f", SCREEN_HEIGHT);
    
    if([faces count] == 1) {
        
        countNoFace = 0;
        
        GMVFaceFeature *faceFeature = faces[0];
        
        if(faceFeature.hasNoseBasePosition) {
            
            countNoNose = 0;
            
            /*
             - Get poits position at screen.
             */
            
            CGFloat scale = 2;// [UIScreen mainScreen].scale;
            
            // Olhos
            CGFloat X_LEFT_EYE_POINT = SCREEN_WIDTH - (faceFeature.leftEyePosition.x/scale);
            CGFloat Y_LEFT_EYE_POINT = faceFeature.leftEyePosition.y/scale;
            
            CGFloat X_RIGHT_EYE_POINT = SCREEN_WIDTH - (faceFeature.rightEyePosition.x/scale);
            CGFloat Y_RIGHT_EYE_POINT = faceFeature.rightEyePosition.y/scale;
            
            // Orelhas
            CGFloat X_LEFT_EAR_POINT = SCREEN_WIDTH - (faceFeature.leftEarPosition.x/scale);
            CGFloat Y_LEFT_EAR_POINT = faceFeature.leftEarPosition.y/scale;
            
            CGFloat X_RIGHT_EAR_POINT = SCREEN_WIDTH - (faceFeature.rightEarPosition.x/scale);
            CGFloat Y_RIGHT_EAR_POINT = faceFeature.rightEarPosition.y/scale;
            
            // Nariz
            CGFloat X_NOSEBASEPOSITION_POINT = SCREEN_WIDTH - (faceFeature.noseBasePosition.x/scale);
            CGFloat Y_NOSEBASEPOSITION_POINT = faceFeature.noseBasePosition.y/scale;
            
            //Angulo
            CGFloat ANGLE_HORIZONTAL = faceFeature.headEulerAngleY;
            CGFloat ANGLE_VERTICAL = faceFeature.headEulerAngleX;
            
            /*
             ------
             */
            
            /*
             - Plot points to visually with color on the screen.
             */
            
            
            if(self.isDebug){
                
                [self addCircleToPoint:CGPointMake(X_LEFT_EYE_POINT, Y_LEFT_EYE_POINT) color:[UIColor redColor]];
                
                [self addCircleToPoint:CGPointMake(X_RIGHT_EAR_POINT, Y_RIGHT_EAR_POINT) color:[UIColor yellowColor]];
                [self addCircleToPoint:CGPointMake(X_LEFT_EAR_POINT, Y_LEFT_EAR_POINT) color:[UIColor yellowColor]];
                
                [self addCircleToPoint:CGPointMake(X_RIGHT_EYE_POINT, Y_RIGHT_EYE_POINT) color:[UIColor blueColor]];
                
                [self addCircleToPoint:CGPointMake(X_NOSEBASEPOSITION_POINT, Y_NOSEBASEPOSITION_POINT) color:[UIColor greenColor]];
                
                
                
                [self addLabelToLog:CGPointMake(X_LEFT_EYE_POINT, Y_LEFT_EYE_POINT) type:@"left_eye"];
                [self addLabelToLog:CGPointMake(X_RIGHT_EYE_POINT, Y_RIGHT_EYE_POINT) type:@"right_eye"];
                
                [self addLabelToLog:CGPointMake(X_LEFT_EAR_POINT, Y_LEFT_EAR_POINT) type:@"left_ear"];
                [self addLabelToLog:CGPointMake(X_RIGHT_EAR_POINT, Y_RIGHT_EAR_POINT) type:@"right_ear"];
                
                [self addLabelToLog:CGPointMake(X_NOSEBASEPOSITION_POINT, Y_NOSEBASEPOSITION_POINT) type:@"nose_base"];
                
                [self addLabelToLog:CGPointMake((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2, 0) type:@"space-eye"];
                
            }
            
            
            /*
             ------
             */
            
            NSLog(@"X_NOSEBASEPOSITION_POINT %.2f - Y_NOSEBASEPOSITION_POINT %.2f", faceFeature.noseBasePosition.x, faceFeature.noseBasePosition.y);
            
            BOOL hasError = NO;
            NSMutableString *strError = [NSMutableString new];
            
            /*
             - Verify wether face is centralized.
             */
            //if((Y_NOSEBASEPOSITION_POINT > 250  && Y_NOSEBASEPOSITION_POINT < 400) &&
            
            
            if(IS_IPHONE_5) {
                
                if(!(((Y_LEFT_EYE_POINT > topOffsetPercent &&
                       Y_LEFT_EYE_POINT < sizeBetweenTopAndBottomPercent) || (Y_RIGHT_EYE_POINT > topOffsetPercent &&
                                                                              Y_RIGHT_EYE_POINT < sizeBetweenTopAndBottomPercent)) &&
                     (X_LEFT_EAR_POINT > (SCREEN_WIDTH / 6)  &&
                      X_RIGHT_EAR_POINT < ((SCREEN_WIDTH / 6) * 5)))) {
                         
                         
                         hasError = YES;
                         // [self showRed];
                         countTimeAlert ++;
                         [strError appendString:@"Centralize o rosto"];
                         
                     }
                
                
            }else if (IS_IPHONE_X || IS_IPHONE_6P){
                
                if(Y_NOSEBASEPOSITION_POINT > ((SCREEN_HEIGHT/2)-80) &&
                   Y_NOSEBASEPOSITION_POINT < ((SCREEN_HEIGHT/2) + 40) &&
                   (X_LEFT_EAR_POINT > (SCREEN_WIDTH / 5)  &&
                    X_RIGHT_EAR_POINT < ((SCREEN_WIDTH / 5) * 4))) {
                       
                       hasError = NO;
                       
                   }else{
                       hasError = YES;
                       // [self showRed];
                       countTimeAlert ++;
                       [strError appendString:@"Centralize o rosto"];
                   }
                
            }else{
                
                if(!(((Y_LEFT_EYE_POINT > topOffsetPercent &&
                       Y_LEFT_EYE_POINT < sizeBetweenTopAndBottomPercent) ||
                      (Y_RIGHT_EYE_POINT > topOffsetPercent &&
                       Y_RIGHT_EYE_POINT < sizeBetweenTopAndBottomPercent)) &&
                     (X_LEFT_EAR_POINT > marginOfSides &&
                      X_RIGHT_EAR_POINT < SCREEN_WIDTH - marginOfSides))) {
                         
                         hasError = YES;
                         // [self showRed];
                         countTimeAlert ++;
                         [strError appendString:@"Centralize o rosto"];
                     }
                
            }
            
            
            if(faceFeature.hasLeftEyePosition && faceFeature.hasRightEyePosition)  {
                
                NSLog(@"Y_LEFT_EYE_POINT: %.2f - Y_RIGHT_EYE_POINT %.2f", Y_LEFT_EYE_POINT, Y_RIGHT_EYE_POINT);
                NSLog(@"DIFERENCA ENTRE OLHOS Y: %.2f",fabs(Y_LEFT_EYE_POINT -  faceFeature.rightEyePosition.y));
                NSLog(@"DIFERENCA ENTRE OLHOS X: %.2f",fabs(faceFeature.leftEyePosition.x -  Y_RIGHT_EYE_POINT));
                
                
                if(((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2) > 220) {
                    countTimeAlert ++;
                    // [self showRed];
                    if(hasError){
                        [strError appendString:@" / Afaste o rosto"];
                    }else{
                        [strError appendString:@"Afaste o rosto"];
                    }
                    hasError = YES;
                    
                }else if(((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2) < 120) {
                    countTimeAlert ++;
                    // [self showRed];
                    if(hasError){
                        [strError appendString:@" / Aproxime o rosto"];
                    }else{
                        [strError appendString:@"Aproxime o rosto"];
                    }
                    hasError = YES;
                    
                }else if((fabs(Y_LEFT_EYE_POINT - Y_RIGHT_EYE_POINT) > 20) || (fabs(Y_RIGHT_EYE_POINT - Y_LEFT_EYE_POINT) > 20)){
                    countTimeAlert ++;
                    if(hasError){
                        [strError appendString:@" / Rosto inclinado"];
                    }else{
                        [strError appendString:@"Rosto inclinado"];
                    }
                    hasError = YES;
                    
                }
                
            }
            
            
            /*
             if(brightnessValue < 0) {
             countTimeAlert ++;
             [self showRed];
             
             if(hasError) {
             [strError appendString:@" / Ambiente muito escuro"];
             }else{
             [strError appendString:@"Ambiente muito escuro"];
             }
             
             }
             
             if( brightnessValue > 3.0) {
             countTimeAlert ++;
             [self showRed];
             
             if(hasError) {
             [strError appendString:@" / Ambiente muito claro"];
             }else{
             [strError appendString:@"Ambiente muito claro"];
             }
             }*/
            
            [self addLabelToLog:CGPointMake(ANGLE_HORIZONTAL , ANGLE_VERTICAL) type:@"euler"];
            
            if(ANGLE_HORIZONTAL > 20 || ANGLE_HORIZONTAL < -20) {
                countTimeAlert ++;
                //[self showRed];
                if(hasError){
                    if(ANGLE_HORIZONTAL > 20) {
                        [strError appendString:@" / Gire um pouco a esquerda"];
                    }else if(ANGLE_HORIZONTAL < -20){
                        [strError appendString:@" / Gire um pouco a direita"];
                    }
                }else{
                    if(ANGLE_HORIZONTAL > 20) {
                        [strError appendString:@"Gire um pouco a esquerda"];
                    }else if(ANGLE_HORIZONTAL < -20){
                        [strError appendString:@"Gire um pouco a direita"];
                    }
                }
                hasError = YES;
                
            }
            
            if(hasError) {
                [self showAlert:strError];
                hasError = NO;
            }else{
                [self showGreen]; // Face is centralized.
            }
            
        }else{
            
            //  countNoNose++;
            //if(countNoNose >= 10)
            [self showGray];
            
        }
    }else{
        
        countNoFace++;
        if(countNoFace >= 20)
            [self showGray];
        
    }
    
    if ([self.renderLock tryLock]) {
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        
        self.latestFrame = image;
        
        [self.renderLock unlock];
    }
}


- (void)showAlert : (NSString *)alert {
    
    if(countTimeAlert >= 10) {
        countTimeAlert = 0;
        isShowAlert = NO;
        
        [self showRed];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:alert
                        duration:1.0
                        position:CSToastPositionTop];
        });
        
    }
    
}

- (void)showRed{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self->timerCountDown != nil) {
            [self resetTimer];
        }
        
        [self->_btTakePic setAlpha:0.5];
        [self->_btTakePic setEnabled:NO];
        [self->rectangle setBackgroundColor:[UIColor redColor]];
        [self->rectangleTop setBackgroundColor:[UIColor redColor]];
        [self->rectangleLeft setBackgroundColor:[UIColor redColor]];
        [self->rectangleRight setBackgroundColor:[UIColor redColor]];
        
    });
}


- (void)showGray{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self->timerCountDown != nil) {
            [self resetTimer];
        }
        
        [self->_btTakePic setAlpha:0.5];
        [self->_btTakePic setEnabled:NO];
        [self->rectangle setBackgroundColor:[UIColor grayColor]];
        [self->rectangleTop setBackgroundColor:[UIColor grayColor]];
        [self->rectangleLeft setBackgroundColor:[UIColor grayColor]];
        [self->rectangleRight setBackgroundColor:[UIColor grayColor]];
        
    });
}

- (UIColor *)getColorPrimary {
    return [UIColor colorWithRed:41.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0];
}


- (void)showGreen{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.isAutoCapture) {
            if(!self->isCountDown) {
                [self performSelector:@selector(createTimer) withObject:nil afterDelay:1];;
                self->isCountDown = YES;
            }
        }
        
        [self.view hideToasts];
        
        [self->_btTakePic setAlpha:1];
        [self->_btTakePic setEnabled:YES];
        [self->rectangle setBackgroundColor:[self getColorPrimary]];
        [self->rectangleTop setBackgroundColor:[self getColorPrimary]];
        [self->rectangleLeft setBackgroundColor:[self getColorPrimary]];
        [self->rectangleRight setBackgroundColor:[self getColorPrimary]];
        
    });
}

- (void)resetTimer {
    [self->timerCountDown invalidate];
    [self->lbCountPic setHidden:YES];
    self->countDown = 3;
    self->isCountDown = NO;
    self->timerCountDown = nil;
}

- (void)createTimer {
    if(!self.isCountdown) {
        countDown = 0;
        [self countDown];
    }else{
        self->timerCountDown = [NSTimer scheduledTimerWithTimeInterval:1
                                                                target:self
                                                              selector:@selector(countDown)
                                                              userInfo:nil
                                                               repeats:YES];
    }
    
}

- (void)countDown {
    
    [lbCountPic setHidden:NO];
    [lbCountPic setText:[NSString stringWithFormat:@"%lu",countDown]];
    
    if(countDown == 0) {
        [self resetTimer];
        [self invokeTakePicture];
    }
    
    countDown --;
    
}


- (AVCaptureDevice *) deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (AVCaptureVideoOrientation) getCurrentOrientation {
    return [self getCurrentOrientation: [[UIApplication sharedApplication] statusBarOrientation]];
}

- (AVCaptureVideoOrientation) getCurrentOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    AVCaptureVideoOrientation orientation;
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
        case UIInterfaceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
    }
    return orientation;
}

- (void) updateOrientation:(AVCaptureVideoOrientation)orientation {
    AVCaptureConnection *captureConnection;
    if (self.stillImageOutput != nil) {
        captureConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoOrientationSupported]) {
            [captureConnection setVideoOrientation:orientation];
        }
    }
    if (self.dataOutput != nil) {
        captureConnection = [self.dataOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoOrientationSupported]) {
            [captureConnection setVideoOrientation:orientation];
        }
    }
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateOrientation:[self getCurrentOrientation:toInterfaceOrientation]];
}

- (void)switchCam {
    
    
    if(self.session)
    {
        //Indicate that some changes will be made to the session
        [self.session beginConfiguration];
        
        //Remove existing input
        AVCaptureInput* currentCameraInput = [self.session.inputs objectAtIndex:0];
        [self.session removeInput:currentCameraInput];
        
        //Get new input
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
        
        //Add input to session
        NSError *err = nil;
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
        if(!newVideoInput || err)
        {
            NSLog(@"Error creating capture device input: %@", err.localizedDescription);
        }
        else
        {
            [self.session addInput:newVideoInput];
        }
        
        //Commit all the configuration changes at once
        [self.session commitConfiguration];
    }
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position) return device;
    }
    return nil;
}

- (CGPoint)scaledPoint:(CGPoint)point
                xScale:(CGFloat)xscale
                yScale:(CGFloat)yscale
                offset:(CGPoint)offset {
    CGPoint resultPoint = CGPointMake(point.x * xscale + offset.x, point.y * yscale + offset.y);
    return resultPoint;
}

- (void)addCircleAtPoint:(CGPoint)point
                  toView:(UIView *)view
               withColor:(UIColor *)color
              withRadius:(NSInteger)width {
    CGRect circleRect = CGRectMake(point.x - width / 2, point.y - width / 2, width, width);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIView *circleView = [[UIView alloc] initWithFrame:circleRect];
        circleView.layer.cornerRadius = width / 2;
        circleView.alpha = 0.7;
        circleView.backgroundColor = color;
        [view addSubview:circleView];
        
    });
}

- (void)addRectangle:(CGRect)rect
              toView:(UIView *)view
           withColor:(UIColor *)color {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIView *newView = [[UIView alloc] initWithFrame:rect];
        newView.layer.cornerRadius = 10;
        newView.alpha = 0.3;
        newView.backgroundColor = color;
        [view addSubview:newView];
        
    });
    
}

- (CGRect)scaledRect:(CGRect)rect
              xScale:(CGFloat)xscale
              yScale:(CGFloat)yscale
              offset:(CGPoint)offset {
    CGRect resultRect = CGRectMake(rect.origin.x * xscale,
                                   rect.origin.y * yscale,
                                   rect.size.width * xscale,
                                   rect.size.height * yscale);
    //resultRect = CGRectOffset(resultRect, offset.x, offset.y);
    return resultRect;
}

- (void)actionAfterTakePicture : (NSString *)base64 {
    
    if(self.cam != nil){
        [self.cam onSuccesCapture:base64];
    }
    
}

@end
