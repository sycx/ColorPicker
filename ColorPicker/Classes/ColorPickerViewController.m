//
//  ColorPickerViewController.m
//  ColorPicker
//
//  Created by Claus Bönnhoff on 13.03.11.
//  Copyright 2011 CBC. All rights reserved.
//

#import "ColorPickerViewController.h"
#import "ColorPicker.h"

@implementation ColorPickerViewController

@synthesize popoverController,changeColorButton,color;

// take a look on which device we are running
-(BOOL)deviceIsiPad
{
    NSString *devstr=[[UIDevice currentDevice] model];
    if([devstr isEqualToString:@"iPad"] || [devstr isEqualToString:@"iPad Simulator"])
        return YES;
    return NO;
}

// changeColorbutton is pressed
-(IBAction)changeColor:(id)sender
{
    // iPad ?
    if([self deviceIsiPad])
    {
        // create the ColorPicker with iPad layout
        ColorPicker *picker=[[ColorPicker alloc] initWithNibName:@"ColorPicker_iPad" bundle:nil Tag:1 Color:color];
        if(picker)
        {
            // set delegate
            picker.delegate=self;
            // and create PopoverController
			popoverController=[[UIPopoverController alloc] initWithContentViewController:picker];
			popoverController.delegate=self;
			[popoverController setPopoverContentSize:CGSizeMake(430, 435)];
			picker.popOver=popoverController;
            // and show it next to our Button
			[popoverController presentPopoverFromRect:changeColorButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
        [picker release], picker=nil;
    }
    // iPhone
	else
	{
        // create the ColorPicker with iPhone layout
        ColorPicker *picker=[[ColorPicker alloc] initWithNibName:@"ColorPicker" bundle:nil Tag:1 Color:color];
        if(picker)
        {
            // set delegate
            picker.delegate=self;
            // and present it as a modal view
            [self presentModalViewController:picker animated:YES];
        }
        [picker release], picker=nil;
	}
}

#pragma mark -
#pragma mark Color picker delegate methods

// the delegate mehtods

// just to dismiss the PopoverController
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popController
{
    [popController dismissPopoverAnimated:YES];
	self.popoverController=nil;
}

// ColorPicker did cancel
- (void)colorPicker:(ColorPicker *)colorPicker didCancelWithTag:(NSInteger)userTag 
{
    // act on device and clear Popover or Modal controller
    if([self deviceIsiPad])
    {
        [self popoverControllerDidDismissPopover:popoverController];
    }
    else 
        [self dismissModalViewControllerAnimated:YES];
    
    return;
}

// ColorPicker has done with OK Button
- (void)colorPicker:(ColorPicker *)colorPicker didSelectColorWithTag:(NSInteger)userTag Red:(NSUInteger)red Green:(NSUInteger)green Blue:(NSUInteger)blue Alpha:(NSUInteger)alpha
{
    // here we can act different depending on the userTag
	switch(userTag)
    {
        case 1:
            // we just set our Color. Color comes from the ColorPicker in RGBA 0-255 Values
            self.color=[UIColor colorWithRed:(float)red/255.0 green:(float)green/255.0 blue:(float)blue/255.0 alpha:(float)alpha/255.0];
            self.view.backgroundColor=color;
            break;
        default:
            break;
    }
    
    // dismiss the Picker
    if([self deviceIsiPad])
    {
        [self popoverControllerDidDismissPopover:popoverController];
    }
    else 
        [self dismissModalViewControllerAnimated:YES];
    
    return;
}

- (void)dealloc
{
	self.color=nil;
    self.changeColorButton=nil;
    self.popoverController=nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    color=[UIColor blueColor];
    self.view.backgroundColor=color;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
