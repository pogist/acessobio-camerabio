//
//  ViewController.m
//  CameraBioExample
//
//  Created by Murilo Paixão on 09/06/20.
//  Copyright © 2020 Murilo Paixão. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.cameraBio = [[CameraBio alloc] initWithViewController:self];
  self.cameraBio.delegate = self;
}

- (void) setPreviewImageFromBase64:(NSString *)base64
{
  NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];;
  self.previewImageView.image = [[UIImage alloc] initWithData:imageData];
}

- (void) dismissCamera
{
  [self.cameraBio stopCamera];
}

- (IBAction)onPressFace:(id)sender
{
  [self.cameraBio startCamera];
}

- (IBAction)onPressCNH:(id)sender
{
  [self.cameraBio startCameraDocuments:DocumentCNH];
}

- (IBAction)onPressRGFront:(id)sender
{
  [self.cameraBio startCameraDocuments:DocumentRGFrente];
}

- (IBAction)onPressRGBack:(id)sender
{
  [self.cameraBio startCameraDocuments:DocumentRGVerso];
}

- (IBAction)onPressNoMask:(id)sender
{
  [self.cameraBio startCameraDocuments:DocumentNone];
}

- (void)onSuccessCaptureFaceInsert:(NSString *)base64
{
  [self setPreviewImageFromBase64:base64];
  [self dismissCamera];
}

- (void)onSuccessCaptureDocument:(NSString *)base64
{
  [self setPreviewImageFromBase64:base64];
  [self dismissCamera];
}

@end
