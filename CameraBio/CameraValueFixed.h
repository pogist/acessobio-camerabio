//
//  CameraValueFixed.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 24/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#ifndef CameraValueFixed_h
#define CameraValueFixed_h

#define NAME_APPLICATION [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define TAB_HEIGHT self.tabBarController.tabBar.frame.size.height

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

#define PLATAFORM = [[[UIDevice currentDevice] systemVersion] intValue];


#endif /* CameraValueFixed_h */
