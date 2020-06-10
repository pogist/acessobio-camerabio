//
//  ViewController.h
//  CameraBioExample
//
//  Created by Murilo Paixão on 09/06/20.
//  Copyright © 2020 Murilo Paixão. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraBio/CameraBio.h>

@interface ViewController : UIViewController <CameraBioDelegate>

@property (strong, nonatomic, nullable) CameraBio *cameraBio;

@end
