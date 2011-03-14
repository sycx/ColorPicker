//
//  ColorPickerViewController.h
//  ColorPicker
//
//  Created by Claus Bönnhoff on 13.03.11.
//  Copyright 2011 CBC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorPicker.h"

// we need to be Delegate for the ColorPicker as well as for the PopoverController
@interface ColorPickerViewController : UIViewController <UIPopoverControllerDelegate,ColorPickerDelegate>
{
    UIPopoverController *popoverController; // for iPad device
    UIButton *changeColorButton;            // IBOutlet Button
    UIColor *color;                         // our color 
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIButton *changeColorButton;
@property (nonatomic, retain) UIColor *color;

// IBAction for changeColorButton touch up inside
-(IBAction)changeColor:(id)sender;

// the needed delegate methods for the ColorPicker

- (void)colorPicker:(ColorPicker *)colorPicker didSelectColorWithTag:(NSInteger)tag Red: (NSUInteger)red Green:(NSUInteger)green Blue:(NSUInteger)blue Alpha:(NSUInteger)alpha;
- (void)colorPicker:(ColorPicker *)colorPicker didCancelWithTag:(NSInteger)tag;

@end
