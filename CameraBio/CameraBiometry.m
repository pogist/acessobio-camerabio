//
//  CameraBio.m
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 13/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import "CameraBio.h"
#import "FaceInsertView.h"
#import "DocumentInsertView.h"

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
    [nav setModalPresentationStyle:UIModalPresentationFullScreen];
    [viewController presentViewController:nav animated:YES completion:nil];
    
}

- (void)restartCamera {
    if(fView != nil) {
        [fView restartCamera];
    }else{
        [self startCamera];
    }
}

- (void)stopCamera {

    if(fView == nil) {
        [dView stopCamera];
        [dView dismissViewControllerAnimated:YES completion:nil];
        dView = nil;
    }else{
        [fView stopCamera];
        [fView dismissViewControllerAnimated:YES completion:nil];
        fView = nil;
    }

}

- (void)startCameraDocuments : (DocumentType) documentType {
    
    dView = [DocumentInsertView new];
    
    if(documentType == DocumentCNH) {
        dView.type = CNH;
    }else if(documentType == DocumentRGFrente || documentType == DocumentRG) {
        dView.type = RG_FRENTE;
    }else{
        dView.type = RG_VERSO;
    }
    
    dView.cam = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:dView];
    [nav setNavigationBarHidden:YES animated:NO];
    [nav setModalPresentationStyle:UIModalPresentationFullScreen];
    [viewController presentViewController:nav animated:YES completion:nil];
    
}

- (void)onSuccesCaptureFaceInsert: (NSString *)base64 {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSuccessCaptureFaceInsert:)]) {
        [self.delegate onSuccessCaptureFaceInsert:base64];
    }
    
}

- (void)onSuccessCaptureDocumentBack:(NSString *)base64 {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSuccessCaptureDocumentBack:)]) {
        [self.delegate onSuccessCaptureDocumentBack:base64];
    }
}

- (void)onSuccessCaptureDocumentFront:(NSString *)base64 {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSuccessCaptureDocumentFront:)]) {
        [self.delegate onSuccessCaptureDocumentFront:base64];
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
        [fView setIsCountdown:[self.delegate cameraBioShouldCountdow]];
    }
    
    return fView.isCountdown;
    
}

@end
