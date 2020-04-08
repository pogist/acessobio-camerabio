
//
//  FaceInsertView.m
//  CaptureAcesso
//
//  Created by Matheus  domingos on 27/03/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import "FaceInsertView.h"
#import "CameraBio.h"

@interface FaceInsertView ()

@end

@implementation FaceInsertView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [cameraFrame setCountdownValue:3];
    [cameraFrame setOffsetTopPercent:30.0f];
    [cameraFrame setSizePercentBetweenTopAndBottom:20.0f];
    
    isSelfie = YES;
    [self setupCamera:isSelfie];
    [self startCamera];
    
    // High-accuracy landmark detection and face classification
    FIRVisionFaceDetectorOptions *options = [[FIRVisionFaceDetectorOptions alloc] init];
    options.performanceMode = FIRVisionFaceDetectorPerformanceModeAccurate;
    options.landmarkMode = FIRVisionFaceDetectorLandmarkModeAll;
    options.trackingEnabled = YES;
    options.minFaceSize = 0.1;
    options.classificationMode = FIRVisionFaceDetectorClassificationModeAll;
    
    
    FIRVision *vision = [FIRVision vision];
    self.faceDetector = [vision faceDetectorWithOptions:options];
    
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
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"entrou landscpae");
            [cameraFrame showRed];
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"entrou landscpae");
            [cameraFrame showRed];
            break;
        default:
            break;
    };
}


- (FIRVisionDetectorImageOrientation)
imageOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation
cameraPosition:(AVCaptureDevicePosition)cameraPosition {
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            if (cameraPosition == AVCaptureDevicePositionFront) {
                return FIRVisionDetectorImageOrientationLeftTop;
            } else {
                return FIRVisionDetectorImageOrientationRightTop;
            }
        case UIDeviceOrientationLandscapeLeft:
            if (cameraPosition == AVCaptureDevicePositionFront) {
                return FIRVisionDetectorImageOrientationBottomLeft;
            } else {
                return FIRVisionDetectorImageOrientationTopLeft;
            }
        case UIDeviceOrientationPortraitUpsideDown:
            if (cameraPosition == AVCaptureDevicePositionFront) {
                return FIRVisionDetectorImageOrientationRightBottom;
            } else {
                return FIRVisionDetectorImageOrientationLeftBottom;
            }
        case UIDeviceOrientationLandscapeRight:
            if (cameraPosition == AVCaptureDevicePositionFront) {
                return FIRVisionDetectorImageOrientationTopRight;
            } else {
                return FIRVisionDetectorImageOrientationBottomRight;
            }
        default:
            return FIRVisionDetectorImageOrientationTopLeft;
    }
}

- (void) setupCamera:(BOOL) isSelfie {
    [super setupCamera:isSelfie];
    
    cameraFrame = [[CameraFrame alloc]initWithView:self button:self.btTakePic autoCapture:self.isAutoCapture contagem:self.isCountdown view:self.view];
    
}


/* ------------|----------
 - (void) startCamera {
 [self.session startRunning];
 }
 
 - (void) stopCamera {
 [self.session stopRunning];
 }
 */

- (CGPoint)pointFromVisionPoint:(FIRVisionPoint *)visionPoint {
    return CGPointMake(visionPoint.x.floatValue, visionPoint.y.floatValue);
}


-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    FIRVisionImageMetadata *metadata = [[FIRVisionImageMetadata alloc] init];
    AVCaptureDevicePosition cameraPosition =
    AVCaptureDevicePositionBack;  // Set to the capture device you used.
    metadata.orientation =
    [self imageOrientationFromDeviceOrientation:UIDevice.currentDevice.orientation
                                 cameraPosition:cameraPosition];
    
    FIRVisionImage *image = [[FIRVisionImage alloc] initWithBuffer:sampleBuffer];
    image.metadata = metadata;
    
    
    [self.faceDetector
     processImage:image
     completion:^(NSArray<FIRVisionFace *> *_Nullable faces, NSError *_Nullable error) {
        
        if (!faces) {
            return;
        }
        
        if([faces count] > 0) {
            
            
            if([faces count] == 1) {
                
                self->countNoFace = 0;
                
                FIRVisionFace *faceFeature = faces[0];
                
                
                FIRVisionFaceLandmark *leftEyeLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeLeftEye];
                
                CGPoint leftEyePosition = [self pointFromVisionPoint:leftEyeLandmark.position];
                
                FIRVisionFaceLandmark *rightEyeLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeRightEye];
                
                CGPoint rightEyePosition = [self pointFromVisionPoint:rightEyeLandmark.position];
                
                FIRVisionFaceLandmark *leftEarLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeLeftEar];
                
                CGPoint leftEarPosition = [self pointFromVisionPoint:leftEarLandmark.position];
                
                FIRVisionFaceLandmark *rightEarLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeRightEar];
                
                CGPoint rightEarPosition = [self pointFromVisionPoint:rightEarLandmark.position];
                
                FIRVisionFaceLandmark *noseBaseLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeLeftEar];
                
                CGPoint noseBasePosition = [self pointFromVisionPoint:noseBaseLandmark.position];
                
                
                self->countNoNose = 0;
                
                
                /*
                 - Get poits position at screen.
                 */
                
                CGFloat scale = 2;// [UIScreen mainScreen].scale;
                
                
                // In the Firebase library, the position X left is the rightEyePosition object and vice versa.
                // Olhos
                CGFloat X_LEFT_EYE_POINT = SCREEN_WIDTH - (rightEyePosition.x/scale);
                CGFloat Y_LEFT_EYE_POINT = leftEyePosition.y/scale;
                
                CGFloat X_RIGHT_EYE_POINT = SCREEN_WIDTH - (leftEyePosition.x/scale);
                CGFloat Y_RIGHT_EYE_POINT = rightEyePosition.y/scale;
                
                // Orelhas
                CGFloat X_LEFT_EAR_POINT = SCREEN_WIDTH - (rightEarPosition.x/scale);
                CGFloat Y_LEFT_EAR_POINT = leftEarPosition.y/scale;
                
                CGFloat X_RIGHT_EAR_POINT = SCREEN_WIDTH - (leftEarPosition.x/scale);
                CGFloat Y_RIGHT_EAR_POINT = rightEarPosition.y/scale;
                
                // Nariz
                CGFloat X_NOSEBASEPOSITION_POINT = SCREEN_WIDTH - (noseBasePosition.x/scale);
                CGFloat Y_NOSEBASEPOSITION_POINT = noseBasePosition.y/scale;
                
                //Angulo
                CGFloat ANGLE_HORIZONTAL = faceFeature.headEulerAngleY;
                CGFloat ANGLE_VERTICAL = faceFeature.headEulerAngleZ;
                
                
                /*
                 ------
                 */
                
                /*
                 - Plot points to visually with color on the screen.
                 */
                
                
                if(self.debug){
                    
                    [self->cameraDebug addCircleToPoint:CGPointMake(X_LEFT_EYE_POINT, Y_LEFT_EYE_POINT) color:[UIColor redColor]];
                    
                    [self->cameraDebug addCircleToPoint:CGPointMake(X_RIGHT_EAR_POINT, Y_RIGHT_EAR_POINT) color:[UIColor yellowColor]];
                    [self->cameraDebug addCircleToPoint:CGPointMake(X_LEFT_EAR_POINT, Y_LEFT_EAR_POINT) color:[UIColor yellowColor]];
                    
                    [self->cameraDebug addCircleToPoint:CGPointMake(X_RIGHT_EYE_POINT, Y_RIGHT_EYE_POINT) color:[UIColor blueColor]];
                    
                    [self->cameraDebug addCircleToPoint:CGPointMake(X_NOSEBASEPOSITION_POINT, Y_NOSEBASEPOSITION_POINT) color:[UIColor greenColor]];
                    
                    
                    [self->cameraDebug addLabelToLog:CGPointMake(X_LEFT_EYE_POINT, Y_LEFT_EYE_POINT) type:@"left_eye"];
                    [self->cameraDebug addLabelToLog:CGPointMake(X_RIGHT_EYE_POINT, Y_RIGHT_EYE_POINT) type:@"right_eye"];
                    
                    [self->cameraDebug addLabelToLog:CGPointMake(X_LEFT_EAR_POINT, Y_LEFT_EAR_POINT) type:@"left_ear"];
                    [self->cameraDebug addLabelToLog:CGPointMake(X_RIGHT_EAR_POINT, Y_RIGHT_EAR_POINT) type:@"right_ear"];
                    
                    [self->cameraDebug addLabelToLog:CGPointMake(X_NOSEBASEPOSITION_POINT, Y_NOSEBASEPOSITION_POINT) type:@"nose_base"];
                    
                    [self->cameraDebug addLabelToLog:CGPointMake((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2, 0) type:@"space-eye"];
                    
                }
                
                
                /*
                 ------
                 */
                
                
                BOOL hasError = NO;
                NSMutableString *strError = [NSMutableString new];
                
                /*
                 - Verify wether face is centralized.
                 */
                //if((Y_NOSEBASEPOSITION_POINT > 250  && Y_NOSEBASEPOSITION_POINT < 400) &&
                
                
                if(IS_IPHONE_5) {
                    
                    if(!(((Y_LEFT_EYE_POINT > [self->cameraFrame getOffsetTopPercent] &&
                           Y_LEFT_EYE_POINT < [self->cameraFrame getSizePercentBetweenTopAndBottom]) || (Y_RIGHT_EYE_POINT > [cameraFrame getOffsetTopPercent] &&
                                                                                                         Y_RIGHT_EYE_POINT < [self->cameraFrame getSizePercentBetweenTopAndBottom])) &&
                         (X_LEFT_EAR_POINT > (SCREEN_WIDTH / 6)  &&
                          X_RIGHT_EAR_POINT < ((SCREEN_WIDTH / 6) * 5)))) {
                        
                        
                        hasError = YES;
                        // [self showRed];
                        self->countTimeAlert ++;
                        [strError appendString:@"Center your face"];
                        
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
                        self->countTimeAlert ++;
                        [strError appendString:@"Center your face"];
                    }
                    
                }else{
                    
                    if(!(((Y_LEFT_EYE_POINT > [self->cameraFrame getOffsetTopPercent] &&
                           Y_LEFT_EYE_POINT < [self->cameraFrame getSizePercentBetweenTopAndBottom]) ||
                          (Y_RIGHT_EYE_POINT > [self->cameraFrame getOffsetTopPercent] &&
                           Y_RIGHT_EYE_POINT < [self->cameraFrame getSizePercentBetweenTopAndBottom])) &&
                         (X_LEFT_EAR_POINT > [self->cameraFrame getMarginOfSides] &&
                          X_RIGHT_EAR_POINT < SCREEN_WIDTH - [self->cameraFrame getMarginOfSides]))) {
                        
                        hasError = YES;
                        // [self showRed];
                        self->countTimeAlert ++;
                        [strError appendString:@"Center your face"];
                    }
                    
                }
                
                
                
                NSLog(@"Y_LEFT_EYE_POINT: %.2f - Y_RIGHT_EYE_POINT %.2f", Y_LEFT_EYE_POINT, Y_RIGHT_EYE_POINT);
                NSLog(@"DIFERENCA ENTRE OLHOS Y: %.2f",fabs(Y_LEFT_EYE_POINT -  rightEyePosition.y));
                NSLog(@"DIFERENCA ENTRE OLHOS X: %.2f",fabs(leftEyePosition.x -  Y_RIGHT_EYE_POINT));
                
                
                if(((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2) > 220) {
                    self->countTimeAlert ++;
                    // [self showRed];
                    if(hasError){
                        [strError appendString:@" / Put your face away"];
                    }else{
                        [strError appendString:@"Put your face away"];
                    }
                    hasError = YES;
                    
                }else if(((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2) < 120) {
                    self->countTimeAlert ++;
                    // [self showRed];
                    if(hasError){
                        [strError appendString:@" / Bring the face closer"];
                    }else{
                        [strError appendString:@"Bring the face closer"];
                    }
                    hasError = YES;
                    
                }else if((fabs(Y_LEFT_EYE_POINT - Y_RIGHT_EYE_POINT) > 20) || (fabs(Y_RIGHT_EYE_POINT - Y_LEFT_EYE_POINT) > 20)){
                    self->countTimeAlert ++;
                    if(hasError){
                        [strError appendString:@" / Inclined face"];
                    }else{
                        [strError appendString:@"Inclined face"];
                    }
                    hasError = YES;
                    
                }
                
                
                
                [self->cameraDebug addLabelToLog:CGPointMake(ANGLE_HORIZONTAL , ANGLE_VERTICAL) type:@"euler"];
                
                if(ANGLE_HORIZONTAL > 20 || ANGLE_HORIZONTAL < -20) {
                    self->countTimeAlert ++;
                    //[self showRed];
                    if(hasError){
                        if(ANGLE_HORIZONTAL > 20) {
                            [strError appendString:@" / Turn slightly left"];
                        }else if(ANGLE_HORIZONTAL < -20){
                            [strError appendString:@" / Turn slightly right"];
                        }
                    }else{
                        if(ANGLE_HORIZONTAL > 20) {
                            [strError appendString:@"Turn slightly left"];
                        }else if(ANGLE_HORIZONTAL < -20){
                            [strError appendString:@"Turn slightly right"];
                        }
                    }
                    hasError = YES;
                    
                }
                
                if(hasError) {
                    [self showAlert:strError];
                    hasError = NO;
                }else{
                    [self->cameraFrame showGreen]; // Face is centralized.
                }
                
            }else{
                
                //  countNoNose++;
                //if(countNoNose >= 10)
                [self->cameraFrame showGray];
                
            }
            
        }else{
            
            self->countNoFace++;
            if(self->countNoFace >= 20)
                [self->cameraFrame showGray];
            
        }}];
    
}

- (void)actionAfterTakePicture : (NSString *)base64 {
    
    if(self.cam != nil){
        [self.cam onSuccesCaptureFaceInsert:base64];
    }
    
}

@end
