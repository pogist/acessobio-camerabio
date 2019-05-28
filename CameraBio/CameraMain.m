//
//  CameraMain.m
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 20/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import "CameraMain.h"
#import "UIColorBio.h"
#import "CameraMain.h"

@interface CameraMain ()

@end

@implementation CameraMain

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
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
            break;
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"entrou landscpae");
            
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
    
    self.btTakePic = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH/2) - 40, SCREEN_HEIGHT - 100, 80, 80)];
    [self.btTakePic setImage:[UIImage imageNamed:@"icon_take_pic"] forState:UIControlStateNormal];
    [self.btTakePic addTarget:self action:@selector(invokeTakePicture) forControlEvents:UIControlEventTouchUpInside];
    [self.btTakePic setAlpha:0.5];
    [self.btTakePic setEnabled:NO];
    [self.view addSubview:self.btTakePic];
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    UIView *myView = self.view;
    previewLayer.frame = myView.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:previewLayer];
    
    [self updateOrientation:[self getCurrentOrientation]];
    
    self.view.userInteractionEnabled = TRUE;
    
}

- (void) startCamera {
    [self.session startRunning];
}

- (void) stopCamera {
    [self.session stopRunning];
}


- (void)setIsDebug : (BOOL)isDebug {
    self.debug = isDebug;
    
    if(self.debug){
        self.cameraDebug = [[CameraDebug alloc]initWithView:self.view];
        [cameraDebug showLogs:SCREEN_WIDTH screen_height:SCREEN_HEIGHT topOffsetPercent:[cameraFrame getOffsetTopPercent] sizeBetweenTopAndBottomPercent:[cameraFrame getSizePercentBetweenTopAndBottom] marginOfSides:[cameraFrame getMarginOfSides]];
    }
    
}


- (void) restartCameraTap:(UITapGestureRecognizer*)recognizer {
    
    [self.view removeGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(restartCameraTap:)]];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTakePictureTap:)]];
    
    [self startCamera];
    
}

- (void)showAlert : (NSString *)alert {
    
    if(countTimeAlert >= 10) {
        countTimeAlert = 0;
        isShowAlert = NO;
        
        [cameraFrame showRed];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:alert
                        duration:1.0
                        position:CSToastPositionTop];
        });
        
    }
    
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

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if ([self.renderLock tryLock]) {
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        
        self.latestFrame = image;
        
        [self.renderLock unlock];
    }
    
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


@end
