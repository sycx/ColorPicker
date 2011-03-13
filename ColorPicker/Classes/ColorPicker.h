//
//  ColorPicker.h
//  ColorPicker
//
//  Created by Claus Bönnhoff on 01.03.11.
//  Copyright 2011 CBC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef unsigned char UBYTE; // color component

@class ColorPicker;

// my color struct
struct rgbhsvColor 
{
	UBYTE red,green,blue;				// 0-255 keep rgb in format for raw image data
	float hue,saturation,vvalue,alpha;  // hue 0.0-360.0°; saturation,vvalue and alpha 0.0-1.0
	float cyan,magenta,yellow,key;      // all 0-100%
};

// delegate functions
@protocol ColorPickerDelegate <NSObject>

// delegate function which is called on ok button.
- (void)colorPicker:(ColorPicker *)colorPicker didSelectColorWithTag:(NSInteger)usertag Red:(NSUInteger)red Green:(NSUInteger)green Blue:(NSUInteger)blue Alpha:(NSUInteger)alpha;
// delegate function which is called on cancel button
- (void)colorPicker:(ColorPicker *)colorPicker didCancelWithTag:(NSInteger)usertag;

@end

@interface ColorPicker : UIViewController <UITextFieldDelegate>
{
    id<ColorPickerDelegate> delegate;
	UIPopoverController *popOver;                           // for iPad
	NSInteger userTag;                                      // identify in delegate method

	UIImageView *previewView,*previewBorderView;			// view for the color preview
	UISegmentedControl *rgbhsvButton;                           

    // all color text fields
	UITextField *firstComponentField,*secondComponentField,*thirdComponentField,*webcolorField,*alphaField;
	UITextField *hueField,*saturationField,*valueField,*cyanField,*magentaField,*yellowField,*keyField;
	UILabel *webcolorLabel,*alphaLabel;
	
	UIImageView *twoComponentView,*oneComponentView;		// the two color picker views
	UILabel *twoComponentViewBorder,*oneComponentBorder;	// the two color picker views
	UIImageView *arrowParentView;							// view to position the select arrows on the one component view

	UISlider *alphaSlider;                                  // slider for alpha value
	UIButton *okButton,*cancelButton;                       // ok and cancel buttons

	UIImageView *circleView,*arrowView;                     // view for the two selctor images circle and arrows	
	CGContextRef twoComponentContext,oneComponentContext;	// ImageContext to draw directly into images
	
	struct rgbhsvColor actualColor;                         // actual set color
}

@property (nonatomic, retain) UIPopoverController *popOver;
@property (nonatomic, assign) id<ColorPickerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIImageView *previewView;
@property (nonatomic, retain) IBOutlet UIImageView *previewBorderView;

@property (nonatomic, retain) IBOutlet UISegmentedControl *rgbhsvButton;

@property (nonatomic, retain) IBOutlet UITextField *firstComponentField;
@property (nonatomic, retain) IBOutlet UITextField *secondComponentField;
@property (nonatomic, retain) IBOutlet UITextField *thirdComponentField;
@property (nonatomic, retain) IBOutlet UITextField *webcolorField;
@property (nonatomic, retain) IBOutlet UITextField *alphaField;

@property (nonatomic, retain) IBOutlet UITextField *hueField;
@property (nonatomic, retain) IBOutlet UITextField *saturationField;
@property (nonatomic, retain) IBOutlet UITextField *valueField;
@property (nonatomic, retain) IBOutlet UITextField *cyanField;
@property (nonatomic, retain) IBOutlet UITextField *magentaField;
@property (nonatomic, retain) IBOutlet UITextField *yellowField;
@property (nonatomic, retain) IBOutlet UITextField *keyField;

@property (nonatomic, retain) IBOutlet UILabel *alphaLabel;
@property (nonatomic, retain) IBOutlet UILabel *webcolorLabel;

@property (nonatomic, retain) IBOutlet UIImageView *twoComponentView;
@property (nonatomic, retain) IBOutlet UIImageView *oneComponentView;
@property (nonatomic, retain) IBOutlet UILabel *oneComponentBorder;
@property (nonatomic, retain) IBOutlet UILabel *twoComponentBorder;
@property (nonatomic, retain) IBOutlet UIImageView *arrowParentView;

@property (nonatomic, retain) IBOutlet UISlider *alphaSlider;
@property (nonatomic, retain) IBOutlet UIButton *okButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;

@property (nonatomic, retain) IBOutlet UIImageView *circleView;
@property (nonatomic, retain) IBOutlet UIImageView *arrowView;

// init with NibName, Color an Tag
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil Tag:(NSInteger)tag Color:(UIColor*)newColor;

-(BOOL)deviceIsiPad;         
-(void)resignAllResponder;

// color conversion functions
-(void)rgbToHSV:(struct rgbhsvColor*)color;
-(void)hsvToRGB:(struct rgbhsvColor*)color;
-(void)rgbToCMYK:(struct rgbhsvColor *)color;
-(void)cmykToRGB:(struct rgbhsvColor *)color;
-(void)changeColor;

// IBActions
-(IBAction)cancel:(id)sender;
-(IBAction)done:(id)sender;
-(IBAction)editTextField:(UITextField*)textField;
-(IBAction)rgbhsvButton:(id)sender;
-(IBAction)changeAlphaSlider:(id)sender;

@end
