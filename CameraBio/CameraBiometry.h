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


@protocol CameraBioDelegate <NSObject>

@optional
- (BOOL)cameraBioShouldAutoCapture;
- (BOOL)cameraBioShouldCountdow;

@required
- (void)onSuccessCapture: (NSString *)base64;

@end

@interface CameraBio : NSObject  <CameraBioDelegate>{
    UIViewController *viewController;
    FaceInsertView *fView;
}


@property (nonatomic, weak) id <CameraBioDelegate> delegate;
@property (assign, nonatomic) BOOL isDebug;

- (void)startCamera;
- (id)initWithViewController:(id)view;
- (void)onSuccesCapture: (NSString *)base64;

@end

