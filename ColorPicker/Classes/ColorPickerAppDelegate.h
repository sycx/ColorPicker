//
//  ColorPickerAppDelegate.h
//  ColorPicker
//
//  Created by Claus Bönnhoff on 13.03.11.
//  Copyright 2011 CBC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColorPickerViewController;

@interface ColorPickerAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet ColorPickerViewController *viewController;

@end
