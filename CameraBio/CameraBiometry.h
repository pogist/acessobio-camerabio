//
//  CameraBio.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 13/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class FaceInsertView;
@class DocumentInsertView;


typedef NS_ENUM(NSInteger, DocumentType) {
    DocumentNone,
    DocumentCNH,
    DocumentRG,
    DocumentRGFrente,
    DocumentRGVerso
};

@protocol CameraBioDelegate <NSObject>

@optional
- (BOOL)cameraBioShouldAutoCapture;
- (BOOL)cameraBioShouldCountdow;

@required
- (void)onSuccessCaptureDocument:(NSString *)base64;
- (void)onSuccessCaptureFaceInsert:(NSString *)base64;

@end

@interface CameraBio : NSObject  <CameraBioDelegate>{
    UIViewController *viewController;
    FaceInsertView *fView;
    DocumentInsertView *dView;
}


@property (nonatomic, weak) id <CameraBioDelegate> delegate;
@property (assign, nonatomic) BOOL isDebug;

- (void)startCamera;
- (void)startCamera: (BOOL)modeDebug;
- (void)startCameraDocuments : (DocumentType) documentType;
- (void)restartCamera;
- (void)stopCamera;


- (id)initWithViewController:(id)view;
- (void)onSuccesCaptureFaceInsert: (NSString *)base64;

@end

