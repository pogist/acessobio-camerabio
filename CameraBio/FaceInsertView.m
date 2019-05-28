
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
    
    NSLog(@"brightnessValue: %.2f", brightnessValue);
    

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
            
            
            if(self.debug){
                
                [cameraDebug addCircleToPoint:CGPointMake(X_LEFT_EYE_POINT, Y_LEFT_EYE_POINT) color:[UIColor redColor]];
                
                [cameraDebug addCircleToPoint:CGPointMake(X_RIGHT_EAR_POINT, Y_RIGHT_EAR_POINT) color:[UIColor yellowColor]];
                [cameraDebug addCircleToPoint:CGPointMake(X_LEFT_EAR_POINT, Y_LEFT_EAR_POINT) color:[UIColor yellowColor]];
                
                [cameraDebug addCircleToPoint:CGPointMake(X_RIGHT_EYE_POINT, Y_RIGHT_EYE_POINT) color:[UIColor blueColor]];
                
                [cameraDebug addCircleToPoint:CGPointMake(X_NOSEBASEPOSITION_POINT, Y_NOSEBASEPOSITION_POINT) color:[UIColor greenColor]];
                
                
                [cameraDebug addLabelToLog:CGPointMake(X_LEFT_EYE_POINT, Y_LEFT_EYE_POINT) type:@"left_eye"];
                [cameraDebug addLabelToLog:CGPointMake(X_RIGHT_EYE_POINT, Y_RIGHT_EYE_POINT) type:@"right_eye"];
                
                [cameraDebug addLabelToLog:CGPointMake(X_LEFT_EAR_POINT, Y_LEFT_EAR_POINT) type:@"left_ear"];
                [cameraDebug addLabelToLog:CGPointMake(X_RIGHT_EAR_POINT, Y_RIGHT_EAR_POINT) type:@"right_ear"];
                
                [cameraDebug addLabelToLog:CGPointMake(X_NOSEBASEPOSITION_POINT, Y_NOSEBASEPOSITION_POINT) type:@"nose_base"];
                
                [cameraDebug addLabelToLog:CGPointMake((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2, 0) type:@"space-eye"];
                
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
                
                if(!(((Y_LEFT_EYE_POINT > [cameraFrame getOffsetTopPercent] &&
                       Y_LEFT_EYE_POINT < [cameraFrame getSizePercentBetweenTopAndBottom]) || (Y_RIGHT_EYE_POINT > [cameraFrame getOffsetTopPercent] &&
                                                                              Y_RIGHT_EYE_POINT < [cameraFrame getSizePercentBetweenTopAndBottom])) &&
                     (X_LEFT_EAR_POINT > (SCREEN_WIDTH / 6)  &&
                      X_RIGHT_EAR_POINT < ((SCREEN_WIDTH / 6) * 5)))) {
                         
                         
                         hasError = YES;
                         // [self showRed];
                         countTimeAlert ++;
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
                       countTimeAlert ++;
                       [strError appendString:@"Center your face"];
                   }
                
            }else{
                
                if(!(((Y_LEFT_EYE_POINT > [cameraFrame getOffsetTopPercent] &&
                       Y_LEFT_EYE_POINT < [cameraFrame getSizePercentBetweenTopAndBottom]) ||
                      (Y_RIGHT_EYE_POINT > [cameraFrame getOffsetTopPercent] &&
                       Y_RIGHT_EYE_POINT < [cameraFrame getSizePercentBetweenTopAndBottom])) &&
                     (X_LEFT_EAR_POINT > [cameraFrame getMarginOfSides] &&
                      X_RIGHT_EAR_POINT < SCREEN_WIDTH - [cameraFrame getMarginOfSides]))) {
                         
                         hasError = YES;
                         // [self showRed];
                         countTimeAlert ++;
                         [strError appendString:@"Center your face"];
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
                        [strError appendString:@" / Put your face away"];
                    }else{
                        [strError appendString:@"Put your face away"];
                    }
                    hasError = YES;
                    
                }else if(((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2) < 120) {
                    countTimeAlert ++;
                    // [self showRed];
                    if(hasError){
                        [strError appendString:@" / Bring the face closer"];
                    }else{
                        [strError appendString:@"Bring the face closer"];
                    }
                    hasError = YES;
                    
                }else if((fabs(Y_LEFT_EYE_POINT - Y_RIGHT_EYE_POINT) > 20) || (fabs(Y_RIGHT_EYE_POINT - Y_LEFT_EYE_POINT) > 20)){
                    countTimeAlert ++;
                    if(hasError){
                        [strError appendString:@" / Inclined face"];
                    }else{
                        [strError appendString:@"Inclined face"];
                    }
                    hasError = YES;
                    
                }
                
            }
        
            [cameraDebug addLabelToLog:CGPointMake(ANGLE_HORIZONTAL , ANGLE_VERTICAL) type:@"euler"];
            
            if(ANGLE_HORIZONTAL > 20 || ANGLE_HORIZONTAL < -20) {
                countTimeAlert ++;
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
                [cameraFrame showGreen]; // Face is centralized.
            }
            
        }else{
            
            //  countNoNose++;
            //if(countNoNose >= 10)
            [cameraFrame showGray];
            
        }
    }else{
        
        countNoFace++;
        if(countNoFace >= 20)
            [cameraFrame showGray];
        
    }
    
}

- (void)actionAfterTakePicture : (NSString *)base64 {
    
    if(self.cam != nil){
        [self.cam onSuccesCapture:base64];
    }
    
}

@end
