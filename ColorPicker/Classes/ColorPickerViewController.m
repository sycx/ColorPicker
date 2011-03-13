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

-(BOOL)deviceIsiPad
{
    NSString *devstr=[[UIDevice currentDevice] model];
    if([devstr isEqualToString:@"iPad"] || [devstr isEqualToString:@"iPad Simulator"])
        return YES;
    return NO;
}

-(IBAction)changeColor:(id)sender
{
    if([self deviceIsiPad])
    {
        ColorPicker *picker=[[ColorPicker alloc] initWithNibName:@"ColorPicker_iPad" bundle:nil Tag:1 Color:color];
        if(picker)
        {
            picker.delegate=self;
			popoverController=[[UIPopoverController alloc] initWithContentViewController:picker];
			popoverController.delegate=self;
			[popoverController setPopoverContentSize:CGSizeMake(430, 435)];
			picker.popOver=popoverController;
			[popoverController presentPopoverFromRect:changeColorButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
        [picker release], picker=nil;
    }
	else
	{
        ColorPicker *picker=[[ColorPicker alloc] initWithNibName:@"ColorPicker" bundle:nil Tag:1 Color:color];
        if(picker)
        {
            picker.delegate=self;
            [self presentModalViewController:picker animated:YES];
        }
        [picker release], picker=nil;
	}
}

#pragma mark -
#pragma mark Color picker delegate methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popController
{
    [popController dismissPopoverAnimated:YES];
	self.popoverController=nil;
}

- (void)colorPicker:(ColorPicker *)colorPicker didCancelWithTag:(NSInteger)userTag 
{
    if([self deviceIsiPad])
    {
        [self popoverControllerDidDismissPopover:popoverController];
    }
    else 
        [self dismissModalViewControllerAnimated:YES];
    
    return;
}


- (void)colorPicker:(ColorPicker *)colorPicker didSelectColorWithTag:(NSInteger)userTag Red:(NSUInteger)red Green:(NSUInteger)green Blue:(NSUInteger)blue Alpha:(NSUInteger)alpha
{
	switch(userTag)
    {
        case 1:
            self.color=[UIColor colorWithRed:(float)red/255.0 green:(float)green/255.0 blue:(float)blue/255.0 alpha:(float)alpha/255.0];
            self.view.backgroundColor=color;
            break;
        default:
            break;
    }
    
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
