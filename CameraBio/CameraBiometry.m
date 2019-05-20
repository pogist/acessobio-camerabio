//
//  CameraBio.m
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 13/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import "CameraBio.h"
#import "FaceInsertView.h"

@implementation CameraBio

- (id)initWithViewController:(id)view
{
    self = [super init];
    if(self) {
        viewController = view;
    }
    
    return self;
}

- (void)startCamera {
    
    [self startCamera:NO];

}

- (void)startCamera: (BOOL)modeDebug {
    
    fView = [FaceInsertView new];
    [fView setCam:self];
    [fView setIsDebug:modeDebug];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:fView];
    [nav setNavigationBarHidden:YES animated:NO];
    [viewController presentViewController:nav animated:YES completion:nil];

}

- (void)onSuccesCapture: (NSString *)base64 {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSuccessCapture:)]) {
        [self.delegate onSuccessCapture:base64];
    }

}

- (BOOL)cameraBioShouldAutoCapture {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraBioShouldAutoCapture)]) {
       [fView setIsAutoCapture:[self.delegate cameraBioShouldAutoCapture]];
    }
 
    return fView.isAutoCapture;
    
}

- (BOOL)cameraBioShouldCountdow{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraBioShouldCountdow)]) {
        [fView setIsAutoCapture:[self.delegate cameraBioShouldCountdow]];
    }
    
    return fView.isCountdown;

}



@end
