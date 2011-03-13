//
//  ColorPickerViewController.h
//  ColorPicker
//
//  Created by Claus Bönnhoff on 13.03.11.
//  Copyright 2011 CBC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorPicker.h"

@interface ColorPickerViewController : UIViewController <UIPopoverControllerDelegate,ColorPickerDelegate>
{
    UIPopoverController *popoverController;
    UIButton *changeColorButton;
    UIColor *color;
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIButton *changeColorButton;
@property (nonatomic, retain) UIColor *color;

-(IBAction)changeColor:(id)sender;

- (void)colorPicker:(ColorPicker *)colorPicker didSelectColorWithTag:(NSInteger)tag Red: (NSUInteger)red Green:(NSUInteger)green Blue:(NSUInteger)blue Alpha:(NSUInteger)alpha;
- (void)colorPicker:(ColorPicker *)colorPicker didCancelWithTag:(NSInteger)tag;

@end
