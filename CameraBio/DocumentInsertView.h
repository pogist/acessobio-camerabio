//
//  DocumentInsertView.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 20/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import "CameraMain.h"

@class CameraBio;


NS_ASSUME_NONNULL_BEGIN

@interface DocumentInsertView : CameraMain

@property (assign, nonatomic)NSInteger type; 
@property (strong, nonatomic) CameraBio *cam;

@end

NS_ASSUME_NONNULL_END
