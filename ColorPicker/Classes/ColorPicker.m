//
//  ColorPicker.m
//  ColorPicker
//
//  Created by Claus Bönnhoff on 01.03.11.
//  Copyright 2011 CBC. All rights reserved.
//

#import "ColorPicker.h"
@interface ColorPicker()
CGContextRef CreateARGBBitmapContext (int pixelsWide, int pixelsHigh);
@end

@implementation ColorPicker

@synthesize delegate,popOver;
@synthesize previewView,previewBorderView,rgbhsvButton;
@synthesize firstComponentField,secondComponentField,thirdComponentField,webcolorField,alphaField;
@synthesize alphaLabel,webcolorLabel,twoComponentView,oneComponentView,oneComponentBorder,twoComponentBorder,arrowParentView;
@synthesize hueField,saturationField,valueField,cyanField,magentaField,yellowField,keyField;
@synthesize alphaSlider,okButton,cancelButton,arrowView,circleView;

#pragma mark -
#pragma mark Change UI orientation

// on iPhone we have to rearrange the UI for landscape mode
-(void)rotateBackground:(UIInterfaceOrientation)toInterfaceOrientation
{
	if(![self deviceIsiPad])
	{
		if (toInterfaceOrientation==UIInterfaceOrientationLandscapeRight || toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft) 
		{
			[previewBorderView setFrame:CGRectMake(20,96,64,46)];
			[previewView setFrame:CGRectMake(22,98,60,42)];
			[rgbhsvButton setFrame:CGRectMake(20,20,170,29)];
			[firstComponentField setFrame:CGRectMake(20,57,56,31)];
			[secondComponentField setFrame:CGRectMake(76,57,57,31)];
			[thirdComponentField setFrame:CGRectMake(133,57,56,31)];
			[webcolorField setFrame:CGRectMake(132,96,58,31)];
			[webcolorLabel setFrame:CGRectMake(120,101,13,21)];
			[twoComponentBorder setFrame:CGRectMake(200,20,260,260)];
			[twoComponentView setFrame:CGRectMake(202,22,256,256)];
			[oneComponentBorder setFrame:CGRectMake(20,190,170,35)];
			[oneComponentView setFrame:CGRectMake(22,192,166,31)];
			[arrowParentView setFrame:CGRectMake(22,180,166,55)];
			[alphaSlider setFrame:CGRectMake(20,150,127,22)];
			[alphaLabel setFrame:CGRectMake(155,135,35,21)];
			[alphaField setFrame:CGRectMake(155,154,35,18)];
			[okButton setFrame:CGRectMake(148,243,42,37)];
			[cancelButton setFrame:CGRectMake(86,243,56,37)];
		}
		else 
		{
			[previewBorderView setFrame:CGRectMake(30,8,64,64)];
			[previewView setFrame:CGRectMake(32,10,60,60)];
			[rgbhsvButton setFrame:CGRectMake(102,8,188,29)];
			[firstComponentField setFrame:CGRectMake(100,41,38,31)];
			[secondComponentField setFrame:CGRectMake(138,41,38,31)];
			[thirdComponentField setFrame:CGRectMake(176,41,38,31)];
			[webcolorField setFrame:CGRectMake(232,41,58,31)];
			[webcolorLabel setFrame:CGRectMake(219,44,12,21)];
			[twoComponentBorder setFrame:CGRectMake(30,135,260,260)];
			[twoComponentView setFrame:CGRectMake(32,137,256,256)];
			[oneComponentBorder setFrame:CGRectMake(30,86,260,35)];
			[oneComponentView setFrame:CGRectMake(32,88,256,31)];
			[arrowParentView setFrame:CGRectMake(32,76,256,55)];
			[alphaSlider setFrame:CGRectMake(30,418,105,22)];
			[alphaLabel setFrame:CGRectMake(141,403,35,21)];
			[alphaField setFrame:CGRectMake(141,422,35,18)];
			[okButton setFrame:CGRectMake(248,403,42,37)];
			[cancelButton setFrame:CGRectMake(184,403,56,37)];		}		
	}
	[self changeColor];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{
	[self rotateBackground:toInterfaceOrientation];
}

-(void)viewWillAppear:(BOOL)animated
{
	[self rotateBackground:self.interfaceOrientation];
}

#pragma mark -
#pragma mark Handle Touches

// get moves on picker views
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{  
	// oneComponent view
	UITouch *touch = [[event touchesForView:self.arrowParentView] anyObject];
	if(touch.view)
	{
		CGPoint point=[touch locationInView:self.arrowParentView];
		// scale size of picker to 0-255
		point.x=(point.x*255.0/oneComponentView.frame.size.width);
		if(point.x>255)
			point.x=255;
		if(point.x<0)
			point.x=0;
		// r,g,b,h,s,v
		switch (rgbhsvButton.selectedSegmentIndex) 
		{
			case 0:
				actualColor.red=point.x;
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 1:
				actualColor.green=point.x;
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 2:
				actualColor.blue=point.x;
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 3:
				actualColor.hue=point.x*360.0/255.0;
				[self hsvToRGB:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 4:
				actualColor.saturation=point.x/255.0;
				[self hsvToRGB:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 5:
				actualColor.vvalue=point.x/255.0;
				[self hsvToRGB:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			default:
				break;
		}
		[self changeColor];
	}
	// two component view
	touch = [[event touchesForView:self.twoComponentView] anyObject];
	if(touch.view)
	{
		CGPoint point=[touch locationInView:self.twoComponentView];
		// scale size of picker to 0-255
		point.x=(point.x*255.0/twoComponentView.frame.size.width);
		point.y=(point.y*255.0/twoComponentView.frame.size.height);
		if(point.x>255)
			point.x=255;
		if(point.x<0)
			point.x=0;
		if(point.y>255)
			point.y=255;
		if(point.y<0)
			point.y=0;
		switch (rgbhsvButton.selectedSegmentIndex) 
		{
			case 0:
				actualColor.green=255-point.y;
				actualColor.blue=point.x;
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 1:
				actualColor.red=255-point.y;
				actualColor.blue=point.x;
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 2:
				actualColor.green=255-point.y;
				actualColor.red=point.x;
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 3:
				actualColor.vvalue=1.0-point.y/255.0;
				actualColor.saturation=point.x/255.0;
				[self hsvToRGB:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 4:
				actualColor.vvalue=1.0-point.y/255.0;
				actualColor.hue=point.x*360.0/255.0;
				[self hsvToRGB:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 5:
				actualColor.saturation=1.0-point.y/255.0;
				actualColor.hue=point.x*360.0/255.0;
				[self hsvToRGB:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			default:
				break;
		}
		[self changeColor];
	}
}

// get touches on picker views
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	// one component view
	UITouch *touch = [[event touchesForView:self.arrowParentView] anyObject];
	if (touch.tapCount) 
	{
		[self resignAllResponder];
		CGPoint point=[touch locationInView:self.arrowParentView];
		// scale size of picker to 0-255
		point.x=(point.x*255.0/oneComponentView.frame.size.width);
		switch (rgbhsvButton.selectedSegmentIndex) 
		{
			case 0:
				actualColor.red=point.x;
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 1:
				actualColor.green=point.x;
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 2:
				actualColor.blue=point.x;
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 3:
				actualColor.hue=point.x*360.0/255.0;
				[self hsvToRGB:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 4:
				actualColor.saturation=point.x/255.0;
				[self hsvToRGB:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 5:
				actualColor.vvalue=point.x/255.0;
				[self hsvToRGB:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			default:
				break;
		}
		[self changeColor];
	}	
	// two component view
	touch = [[event touchesForView:self.twoComponentView] anyObject];
	if (touch.tapCount) 
	{
		[self resignAllResponder];
		CGPoint point=[touch locationInView:self.twoComponentView];
		// scale size of picker to 0-255
		point.x=(point.x*255.0/twoComponentView.frame.size.width);
		point.y=(point.y*255.0/twoComponentView.frame.size.height);
		switch (rgbhsvButton.selectedSegmentIndex) 
		{
			case 0:
				actualColor.green=255-point.y;
				actualColor.blue=point.x;
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 1:
				actualColor.red=255-point.y;
				actualColor.blue=point.x;
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 2:
				actualColor.green=255-point.y;
				actualColor.red=point.x;
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 3:
				actualColor.vvalue=1.0-point.y/255.0;
				actualColor.saturation=point.x/255.0;
				[self hsvToRGB:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 4:
				actualColor.vvalue=1.0-point.y/255.0;
				actualColor.hue=point.x*360.0/255.0;
				[self hsvToRGB:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			case 5:
				actualColor.saturation=1.0-point.y/255.0;
				actualColor.hue=point.x*360.0/255.0;
				[self hsvToRGB:&actualColor];
				[self rgbToCMYK:&actualColor];
				break;
			default:
				break;
		}
		[self changeColor];
	}
}

#pragma mark -
#pragma mark Convert colors

// calc CMYK values of rgbhsvColor from RGB
-(void)rgbToCMYK:(struct rgbhsvColor *)color
{
	float cyan=1-((float)color->red/255.0);
	float magenta=1-((float)color->green/255.0);
	float yellow=1-((float)color->blue/255.0);
	
	float key=1;
	if(cyan<key)		key=cyan;
	if(magenta<key)		key=magenta;
	if(yellow<key)		key=yellow;
	if(key==1)
		cyan=magenta=yellow=0;
	else 
	{
		cyan=(cyan-key)/(1-key);
		magenta=(magenta-key)/(1-key);
		yellow=(yellow-key)/(1-key);
	}
	color->cyan=cyan;
	color->magenta=magenta;
	color->yellow=yellow;
	color->key=key;
}

// calc RGB values of rgbhsvColor from CMYK values
-(void)cmykToRGB:(struct rgbhsvColor *)color
{
	float cyan=(color->cyan*(1-color->key)+color->key);
	float magenta=(color->magenta*(1-color->key)+color->key);
	float yellow=(color->yellow*(1-color->key)+color->key);
	
	color->red=round((1-cyan)*255.0);
	color->green=round((1-magenta)*255.0);
	color->blue=round((1-yellow)*255.0);
	
}

// calc RGB values of rgbhsvColor from HSV values
-(void)hsvToRGB:(struct rgbhsvColor*)color
{
	if(color->saturation==0.0)
	{
		color->red=round(color->vvalue*255.0);
		color->green=round(color->vvalue*255.0);
		color->blue=round(color->vvalue*255.0);
	}
	else 
	{
		float hTemp=0.0;
		
		if(color->hue==360.0)
			hTemp=0.0;
		else
			hTemp=color->hue/60.0;

		int i=trunc(hTemp);
		float f=hTemp-i;
		
		float p=color->vvalue*(1.0-color->saturation);
		float q=color->vvalue*(1.0-(color->saturation*f));
		float t=color->vvalue*(1.0-(color->saturation*(1.0-f)));
		
		switch (i) 
		{
			default:
			case 0:
			case 6:
				color->red=round(color->vvalue*255.0);
				color->green=round(t*255.0);
				color->blue=round(p*255.0);
				break;
			case 1:
				color->red=round(q*255.0);
				color->green=round(color->vvalue*255.0);
				color->blue=round(p*255.0);
				break;
			case 2:
				color->red=round(p*255.0);
				color->green=round(color->vvalue*255.0);
				color->blue=round(t*255.0);
				break;
			case 3:
				color->red=round(p*255.0);
				color->green=round(q*255.0);
				color->blue=round(color->vvalue*255.0);
				break;
			case 4:
				color->red=round(t*255.0);
				color->green=round(p*255.0);
				color->blue=round(color->vvalue*255.0);
				break;
			case 5:
				color->red=round(color->vvalue*255.0);
				color->green=round(p*255.0);
				color->blue=round(q*255.0);
				break;
		}
		
	}
	return;
}

// calc HSV values of rgbhsvColor from RGB values
-(void)rgbToHSV:(struct rgbhsvColor*)color
{
	UBYTE maxRGBValue=MAX(MAX(color->red,color->green),color->blue);
	float minValue=MIN(MIN(color->red,color->green),color->blue);
	float maxValue=maxRGBValue;
	float hue,saturation,vvalue,delta;

	minValue=minValue/255.0;
	maxValue=maxValue/255.0;

	vvalue=maxValue;
	delta=vvalue-minValue;
	
	if(delta==0)
		saturation=0;
	else 
		saturation=delta/vvalue;
	
	if(saturation==0)
		hue=0;
	else 
	{
		if(color->red==maxRGBValue)
			hue=60.0*(float)(color->green-color->blue)/255.0/delta;
		else 
		{
			if(color->green==maxRGBValue)
				hue=120.0+60.0*(float)(color->blue-color->red)/255.0/delta;
			else 
			{
				if(color->blue==maxRGBValue)
					hue=240.0+60.0*(float)(color->red-color->green)/255.0/delta;
			}
		}
		if(hue<0.0)
			hue+=360.0;
	}
	color->hue=hue;
	color->saturation=saturation;
	color->vvalue=vvalue;
	return;	
}

#pragma mark -
#pragma mark Draw color views

// draw one component picker view
-(void)drawOneComponentImage
{
	// get image size
	int width = self.oneComponentView.frame.size.width;
	int height = self.oneComponentView.frame.size.height;
	int red,green,blue;
	struct rgbhsvColor color;
	float xPos;
	
	// delete old picker image
	oneComponentView.image=nil;
    
    // if view size change, need recreate context
    size_t oldWidth = CGBitmapContextGetWidth(oneComponentContext);
    size_t oldHeight = CGBitmapContextGetHeight(oneComponentContext);
    
    if (oldWidth != width || oldHeight != height) {
        CGContextRelease(oneComponentContext);
        oneComponentContext = CreateARGBBitmapContext(width, height);
    }
    
	//CGContextClearRect(oneComponentContext, oneComponentView.frame);
	// pointer image raw data
	UBYTE *data = CGBitmapContextGetData (oneComponentContext);
	CGRect frame;
	
	// which component must be drawn ?
	switch (rgbhsvButton.selectedSegmentIndex) 
	{
		// red
		case 0:
			red=0; // show from 0 to 255
			for(int x=0;x<width;x++)		// from left to right
			{
				for(int y=0;y<height;y++)	// from top to bottom
				{
					data[x*4+y*width*4]=255;					// alpha
					data[x*4+y*width*4+1]=actualColor.blue;		// blue	
					data[x*4+y*width*4+2]=actualColor.green;	// green
					data[x*4+y*width*4+3]=red;					// red;
				}
				red = round((float)x / (float)width * 255.0);
			}
			xPos=((float)actualColor.red*oneComponentView.frame.size.width/255.0);
			// calc position of selector arrow
			frame=CGRectMake((xPos)-10, 0, arrowView.frame.size.width, arrowView.frame.size.height);
			// and move arrows
			arrowView.frame=frame;
			break;

		//green
		case 1:
			green=0;
			for(int x=0;x<width;x++)
			{
				for(int y=0;y<height;y++)
				{
					data[x*4+y*width*4]=255;
					data[x*4+y*width*4+1]=actualColor.blue;
					data[x*4+y*width*4+2]=green;
					data[x*4+y*width*4+3]=actualColor.red;
				}
				green = round((float)x / (float)width * 255.0);
			}
			xPos=((float)actualColor.green*oneComponentView.frame.size.width/255.0);
			frame=CGRectMake((xPos)-10, 0, arrowView.frame.size.width, arrowView.frame.size.height);
			arrowView.frame=frame;
			break;
			
		// blue
		case 2:
			blue=0;
			for(int x=0;x<width;x++)
			{
				for(int y=0;y<height;y++)
				{
					data[x*4+y*width*4]=255;
					data[x*4+y*width*4+1]=blue;
					data[x*4+y*width*4+2]=actualColor.green;
					data[x*4+y*width*4+3]=actualColor.red;
				}
				blue = round((float)x / (float)width * 255.0);
			}
			xPos=((float)actualColor.blue*oneComponentView.frame.size.width/255.0);
			frame=CGRectMake((xPos)-10, 0, arrowView.frame.size.width, arrowView.frame.size.height);
			arrowView.frame=frame;
			break;

		// hue
		case 3:
			color.hue=0;
			color.saturation=1.0;
			color.vvalue=1.0;
			for(int x=0;x<width;x++)
			{
				[self hsvToRGB:&color];
				for(int y=0;y<height;y++)
				{
					data[x*4+y*width*4]=255;
					data[x*4+y*width*4+1]=color.blue;
					data[x*4+y*width*4+2]=color.green;
					data[x*4+y*width*4+3]=color.red;
				}
				color.hue = (float)x / (float)width * 360.0;
			}
			frame=CGRectMake(((float)actualColor.hue*oneComponentView.frame.size.width/360.0)-10, 0, arrowView.frame.size.width, arrowView.frame.size.height);
			arrowView.frame=frame;
			break;

		// saturation
		case 4:
			color.saturation=0;
			color.hue=actualColor.hue;
			color.vvalue=actualColor.vvalue;
			for(int x=0;x<width;x++)
			{
				[self hsvToRGB:&color];
				for(int y=0;y<height;y++)
				{
					data[x*4+y*width*4]=255;
					data[x*4+y*width*4+1]=color.blue;
					data[x*4+y*width*4+2]=color.green;
					data[x*4+y*width*4+3]=color.red;
				}
				color.saturation = (float)x / (float)width;
			}
			frame=CGRectMake(((float)actualColor.saturation*oneComponentView.frame.size.width)-10, 0, arrowView.frame.size.width, arrowView.frame.size.height);
			arrowView.frame=frame;
			break;

		// value
		case 5:
			color.vvalue=0;
			color.hue=actualColor.hue;
			color.saturation=1.0;
			for(int x=0;x<width;x++)
			{
				[self hsvToRGB:&color];
				for(int y=0;y<height;y++)
				{
					data[x*4+y*width*4]=255;
					data[x*4+y*width*4+1]=color.blue;
					data[x*4+y*width*4+2]=color.green;
					data[x*4+y*width*4+3]=color.red;
				}
				color.vvalue = (float)x / (float)width;
			}
			frame=CGRectMake(((float)actualColor.vvalue*oneComponentView.frame.size.width)-10, 0, arrowView.frame.size.width, arrowView.frame.size.height);
			arrowView.frame=frame;
			break;

		default:
			break;
	}
	
	// create new image
	CGImageRef newimage=CGBitmapContextCreateImage(oneComponentContext);
	// set image
	oneComponentView.image=[UIImage imageWithCGImage:newimage];
	// release CGImage
	CGImageRelease(newimage);
}

// draw two component picker view
-(void)drawTwoComponentImage
{
	// get image size
	int width = self.twoComponentView.frame.size.width;
	int height = self.twoComponentView.frame.size.height;
	
	// delete old picker image
	twoComponentView.image=nil;
	
    // if view size change, need recreate context
    size_t oldWidth = CGBitmapContextGetWidth(twoComponentContext);
    size_t oldHeight = CGBitmapContextGetHeight(twoComponentContext);
    
    if (oldWidth != width || oldHeight != height) {
        CGContextRelease(twoComponentContext);
        twoComponentContext = CreateARGBBitmapContext(width, height);
    }
    
	// image raw data
	UBYTE *data = CGBitmapContextGetData (twoComponentContext);
	int blue,green,red;
	struct rgbhsvColor color;
	CGRect frame = circleView.frame;
    CGFloat xMax = twoComponentView.frame.size.width;
    CGFloat yMax = twoComponentView.frame.size.height;
	
	// which component must be drawn ?
	switch (rgbhsvButton.selectedSegmentIndex)
	{
		// green and blue
		case 0:
			blue=0;					// from 0 to 255
			for(int x=0;x<width;x++)		// from left to right
			{
				green=255;					// reverse green because we draw from top to bottom (origin at left/top)
				for(int y=0;y<height;y++)	// from top to bottom
				{
					data[x*4+y*width*4]=255;					// alpha
					data[x*4+y*width*4+1]=blue;					// blue
					data[x*4+y*width*4+2]=green;				// green
					data[x*4+y*width*4+3]=actualColor.red;		// red	
                    green = round(255.0 - (float)y / (float)height * 255.0);
				}
				blue = round((float)x / (float)width * 255.0);
			}
			// calc position for selector circle
            frame.origin.x = (actualColor.blue / 255.0 * xMax)-10;
            frame.origin.y = (yMax - actualColor.green / 255.0 * yMax)-10;
			// move circle to new position
			circleView.frame=frame;
			break;
			
		// red and blue
		case 1:
			blue=0;
			for(int x=0;x<width;x++)
			{
                red = 255;
				for(int y=0;y<height;y++)
				{
					data[x*4+y*width*4]=255;
					data[x*4+y*width*4+1]=blue;
					data[x*4+y*width*4+2]=actualColor.green;
					data[x*4+y*width*4+3]=red;
					red = round(255.0 - (float)y / (float)height *255.0);
				}
				blue = round((float)x / (float)width *255.0);
			}

            frame.origin.x = (actualColor.blue / 255.0 * xMax) - 10.0;
            frame.origin.y = (yMax - actualColor.red / 255.0 * yMax) - 10.0;
			circleView.frame=frame;
			break;
			
		// red and green
		case 2:
			red=0;
			for(int x=0;x<width;x++)
			{
				green=255;
				for(int y=0;y<height;y++)
				{
					data[x*4+y*width*4]=255;
					data[x*4+y*width*4+1]=actualColor.blue;
					data[x*4+y*width*4+2]=green;
					data[x*4+y*width*4+3]=red;
					green = round(255.0 - (float)y / (float)height *255.0);;
				}
				red = round((float)x / (float)width *255.0);
			}
			
			frame.origin.x = (actualColor.red / 255.0 * xMax) - 10.0;
            frame.origin.y = (yMax - actualColor.green / 255.0 * yMax) -10.0;
			circleView.frame=frame;
			break;

		// saturation and value
		case 3:
			color.hue=actualColor.hue;
			color.saturation=color.vvalue=0.0;
			for(int x=0;x<width;x++)
			{
				color.vvalue=1.0;
				[self hsvToRGB:&color];
				for(int y=0;y<height;y++)
				{
					data[x*4+y*width*4]=255;
					data[x*4+y*width*4+1]=color.blue;
					data[x*4+y*width*4+2]=color.green;
					data[x*4+y*width*4+3]=color.red;
                    color.vvalue = 1.0 - (float)y / (float)height;
                    [self hsvToRGB:&color];
				}
				color.saturation = ((float)x / (float)height);
			}
			
            frame.origin.x = (actualColor.saturation * xMax) - 10.0;
            frame.origin.y = (yMax - actualColor.vvalue * yMax) - 10.0;
			circleView.frame=frame;
			break;

		// hue and vvalue
		case 4:
			color.saturation=1.0;
			color.hue=color.vvalue=0.0;
			for(int x=0;x<width;x++)
			{
				color.vvalue=1.0;
				[self hsvToRGB:&color];
				for(int y=0;y<height;y++)
				{
					data[x*4+y*width*4]=255;
					data[x*4+y*width*4+1]=color.blue;
					data[x*4+y*width*4+2]=color.green;
					data[x*4+y*width*4+3]=color.red;
					color.vvalue = 1.0 - (float)y / (float)height;
                    [self hsvToRGB:&color];
				}
				color.hue = ((float)x / (float)height * 360.0);
			}
			
            frame.origin.x = (actualColor.hue / 360.0 * xMax) - 10.0;
            frame.origin.y = (yMax - actualColor.vvalue * yMax) - 10.0;
			circleView.frame=frame;
			break;

		// hue and saturation
		case 5:
			color.vvalue=1.0;
			color.hue=color.saturation=0.0;
			for(int x=0;x<width;x++)
			{
				color.saturation=1.0;
				[self hsvToRGB:&color];
				for(int y=0;y<height;y++)
				{
					data[x*4+y*width*4]=255;
					data[x*4+y*width*4+1]=color.blue;
					data[x*4+y*width*4+2]=color.green;
					data[x*4+y*width*4+3]=color.red;
					color.saturation = 1.0 - (float)y / (float)height;
                    [self hsvToRGB:&color];
				}
				color.hue = ((float)x / (float)height * 360.0);
			}
			
            frame.origin.x = (actualColor.hue / 360.0 * xMax) - 10.0;
            frame.origin.y = (yMax - actualColor.saturation * yMax) - 10.0;
			circleView.frame=frame;
			break;

		default:
			break;
	}
	
	// create new image
	CGImageRef newimage=CGBitmapContextCreateImage(twoComponentContext);
	// set new picker image
	twoComponentView.image=[UIImage imageWithCGImage:newimage];
	// release CGImage
	CGImageRelease(newimage);
}

// get rgba bitmap of image
CGContextRef CreateARGBBitmapContext (int pixelsWide, int pixelsHigh)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    int             bitmapBytesPerRow;
	
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
	
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
	
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits 
    // per component. Regardless of what the source image format is 
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (NULL,  // pass NULL require iOS4
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedLast);
    if (context == NULL)
    {
        fprintf (stderr, "Context not created!");
    }
	
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
	
    return context;
}

#pragma mark -
#pragma mark Handle textfields

// resign all responder if tap on color view is detected
-(void)resignAllResponder
{
	[firstComponentField resignFirstResponder];
	[secondComponentField resignFirstResponder];
	[thirdComponentField resignFirstResponder];
    
	[hueField resignFirstResponder];
	[saturationField resignFirstResponder];
	[valueField resignFirstResponder];
    
	[cyanField resignFirstResponder];
	[magentaField resignFirstResponder];
	[yellowField resignFirstResponder];
	[keyField resignFirstResponder];
}


// filter not allowed chars from textfield
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 
{
    // allow hexadezimal values
	if(textField==webcolorField)
	{
		static NSCharacterSet *charSet = nil;
		if(!charSet) 
		{
			charSet = [[[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"] invertedSet] retain];
		}
		NSRange location = [string rangeOfCharacterFromSet:charSet];
		return (location.location == NSNotFound);
	}
    // only decimal values
	else 
	{
		static NSCharacterSet *charSet = nil;
		if(!charSet) 
		{
			charSet = [[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet] retain];
		}
		NSRange location = [string rangeOfCharacterFromSet:charSet];
		return (location.location == NSNotFound);
	}
}

// watch textfield edit for max values
-(IBAction)editTextField:(UITextField*)textField
{
    // alpha field 0-100
	if(textField==alphaField)
	{
		if( [textField.text intValue]>100)
		{
			// delete last char
			NSString *text=[textField.text substringToIndex:[textField.text length]-1];
			textField.text=text;
		}
		else 
		{
			actualColor.alpha=(float)[alphaField.text intValue]/100.0;
			[alphaSlider setValue:actualColor.alpha];
			previewView.backgroundColor=[UIColor colorWithRed:(float)actualColor.red/255.0 green:(float)actualColor.green/255.0 blue:(float)actualColor.blue/255.0 alpha:actualColor.alpha];
		}
		return;
	}
	
    // webcolor field hexadecimal value 0x000000-0xFFFFFF
	if(textField==webcolorField)
	{
		// max 6 chars
		if([textField.text length]>6)
		{
			NSString *text=[textField.text substringToIndex:[textField.text length]-1];
			textField.text=text;
		}
		return;
	}
	
	// rgb values
	if([self deviceIsiPad])
	{
		if(textField==firstComponentField || textField==secondComponentField || textField==thirdComponentField)
		{
			// limited to 255
			if( [textField.text intValue]>255)
			{
				// delete last char
				NSString *text=[textField.text substringToIndex:[textField.text length]-1];
				textField.text=text;
			}
			else 
			{
				// set components
				actualColor.red=[firstComponentField.text intValue];
				actualColor.green=[secondComponentField.text intValue];
				actualColor.blue=[thirdComponentField.text intValue];
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				
				// draw preview color
				previewView.backgroundColor=[UIColor colorWithRed:(float)actualColor.red/255.0 green:(float)actualColor.green/255.0 blue:(float)actualColor.blue/255.0 alpha:actualColor.alpha];
				
				// draw picker views
				[self drawOneComponentImage];
				[self drawTwoComponentImage];
			}
		}
		else 
		{
			if(textField==hueField)
			{
				// hue limited to 360
				if( [textField.text intValue]>360)
				{
					// delete last char
					NSString *text=[textField.text substringToIndex:[textField.text length]-1];
					textField.text=text;
				}
				else 
				{
					// set hue value 
					actualColor.hue=[firstComponentField.text intValue];
					[self hsvToRGB:&actualColor];
					[self rgbToCMYK:&actualColor];
					
					// draw preview color
					previewView.backgroundColor=[UIColor colorWithRed:(float)actualColor.red/255.0 green:(float)actualColor.green/255.0 blue:(float)actualColor.blue/255.0 alpha:actualColor.alpha];
					
					// draw picker views
					[self drawOneComponentImage];
					[self drawTwoComponentImage];
				}
			}
			else 
			{
				if(textField==saturationField || textField==valueField)
				{
					if( [textField.text intValue]>100)
					{
						// delete last char
						NSString *text=[textField.text substringToIndex:[textField.text length]-1];
						textField.text=text;
					}
					else 
					{
						// set saturation and value
						actualColor.green=[secondComponentField.text intValue];
						actualColor.blue=[thirdComponentField.text intValue];
						[self hsvToRGB:&actualColor];
						[self rgbToCMYK:&actualColor];
						
						// draw preview color
						previewView.backgroundColor=[UIColor colorWithRed:(float)actualColor.red/255.0 green:(float)actualColor.green/255.0 blue:(float)actualColor.blue/255.0 alpha:actualColor.alpha];
						
						// draw picker views
						[self drawOneComponentImage];
						[self drawTwoComponentImage];
					}
				}
				else 
				{
					if( [textField.text intValue]>100)
					{
						// delete last char
						NSString *text=[textField.text substringToIndex:[textField.text length]-1];
						textField.text=text;
					}
					else 
					{
						// set saturation and value
						actualColor.cyan=[secondComponentField.text intValue];
						actualColor.magenta=[secondComponentField.text intValue];
						actualColor.yellow=[secondComponentField.text intValue];
						actualColor.key=[secondComponentField.text intValue];
						[self cmykToRGB:&actualColor];
						[self rgbToHSV:&actualColor];
						
						// draw preview color
						previewView.backgroundColor=[UIColor colorWithRed:(float)actualColor.red/255.0 green:(float)actualColor.green/255.0 blue:(float)actualColor.blue/255.0 alpha:actualColor.alpha];
						
						// draw picker views
						[self drawOneComponentImage];
						[self drawTwoComponentImage];
					}
				}
			}
		}
	}
	else 
	{
		if(rgbhsvButton.selectedSegmentIndex<3)
		{
			// limited to 255
			if( [textField.text intValue]>255)
			{
				// delete last char
				NSString *text=[textField.text substringToIndex:[textField.text length]-1];
				textField.text=text;
			}
			else 
			{
				// set components
				actualColor.red=[firstComponentField.text intValue];
				actualColor.green=[secondComponentField.text intValue];
				actualColor.blue=[thirdComponentField.text intValue];
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
				
				// draw preview color
				previewView.backgroundColor=[UIColor colorWithRed:(float)actualColor.red/255.0 green:(float)actualColor.green/255.0 blue:(float)actualColor.blue/255.0 alpha:actualColor.alpha];
				
				// draw picker views
				[self drawOneComponentImage];
				[self drawTwoComponentImage];
			}
		}
		else 
		{
			// hue max value is different to saturation and value
			if(textField==firstComponentField)
			{
				// hue limited to 360
				if( [textField.text intValue]>360)
				{
					// delete last char
					NSString *text=[textField.text substringToIndex:[textField.text length]-1];
					textField.text=text;
				}
				else 
				{
					// set hue value 
					actualColor.hue=[firstComponentField.text intValue];
					[self hsvToRGB:&actualColor];
					[self rgbToCMYK:&actualColor];
					
					// draw preview color
					previewView.backgroundColor=[UIColor colorWithRed:(float)actualColor.red/255.0 green:(float)actualColor.green/255.0 blue:(float)actualColor.blue/255.0 alpha:actualColor.alpha];
					
					// draw picker views
					[self drawOneComponentImage];
					[self drawTwoComponentImage];
				}
			}
			else 
			{			
				// saturation and value limited to 100
				if( [textField.text intValue]>100)
				{
					// delete last char
					NSString *text=[textField.text substringToIndex:[textField.text length]-1];
					textField.text=text;
				}
				else 
				{
					// set saturation and value
					actualColor.green=[secondComponentField.text intValue];
					actualColor.blue=[thirdComponentField.text intValue];
					[self hsvToRGB:&actualColor];
					[self rgbToCMYK:&actualColor];
					
					// draw preview color
					previewView.backgroundColor=[UIColor colorWithRed:(float)actualColor.red/255.0 green:(float)actualColor.green/255.0 blue:(float)actualColor.blue/255.0 alpha:actualColor.alpha];
					
					// draw picker views
					[self drawOneComponentImage];
					[self drawTwoComponentImage];
				}
			}
		}
	}
	return;
}

// convert hex value to decimal
-(NSInteger)hexToDec:(NSString *)chr
{
	char c=[chr characterAtIndex:(NSUInteger)0];
	switch (c) 
	{
		case 'a':
			return 10;
			break;
		case 'b':
			return 11;
			break;
		case 'c':
			return 12;
			break;
		case 'd':
			return 13;
			break;
		case 'e':
			return 14;
			break;
		case 'f':
			return 15;
			break;
		default:
			return [chr intValue];
			break;
	}
	return 0;
}

// textfield returned
-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
	[textField resignFirstResponder];
	
    // alpha field just set the value
	if(textField==alphaField)
	{
		[alphaSlider setValue:(float)[alphaField.text intValue]/100.0];
		[self changeColor];
		actualColor.alpha=(float)alphaSlider.value;
		return YES;
	}
	
    // textfield we have to check the number of digits and set the values 
	if(textField==webcolorField)
	{
		NSString *hex=textField.text,*blue,*green,*red;
		actualColor.red=actualColor.green=actualColor.blue=0;
		
		// do we have a blue value? (1 or 2 digits) 
		if([hex length]>0)
		{
            // two digits
			if([hex length]>1)
			{
				blue=[hex substringFromIndex:[hex length]-2];
				hex=[hex substringToIndex:[hex length]-2];

                // remove the used two digits from the string
				actualColor.blue=([self hexToDec:[blue substringToIndex:1]]*16);
				actualColor.blue+=[self hexToDec:[blue substringFromIndex:1]];
			}
            // only one digit. Set and return
			else
			{
				actualColor.blue=[self hexToDec:hex];
                // calc CMYK and HSV Values
				[self rgbToCMYK:&actualColor];
				[self rgbToHSV:&actualColor];
				[self changeColor];
				return YES;
			}

			// do we have a green value? (3-4 digits, but the blue ones are already removed)
			if([hex length]>0)
			{
                // two digits
				if([hex length]>1)
				{
					green=[hex substringFromIndex:[hex length]-2];
					hex=[hex substringToIndex:[hex length]-2];

                    // remove the used two digits from the string
					actualColor.green=([self hexToDec:[green substringToIndex:1]]*16);
					actualColor.green+=([self hexToDec:[green substringFromIndex:1]]);
				}
                // only one digit. Set and return
				else 
				{
					actualColor.green=[self hexToDec:hex];
                    // calc CMYK and HSV Values
					[self rgbToCMYK:&actualColor];
					[self rgbToHSV:&actualColor];
					[self changeColor];
					return YES;
				}

				// do we have a red value? (5-6 digits, but the blue and green are already removed)
				if([hex length]>0)
				{	
                    // two digits
					if([hex length]>1)
					{
						red=[hex substringFromIndex:[hex length]-2];
						actualColor.red=([self hexToDec:[red substringToIndex:1]]*16);
						actualColor.red+=([self hexToDec:[red substringFromIndex:1]]);
					}
                    // one digit
					else 
					{
						actualColor.red=[self hexToDec:hex];
					}
				}
			}
            // calc CMYK and HSV Values
			[self rgbToCMYK:&actualColor];
			[self rgbToHSV:&actualColor];
			[self changeColor];
			return YES;
		}
	}
    // RGB, HSV and CMYK
	else 
	{
        // on iPad we have one textfield for each component
		if([self deviceIsiPad])
		{
            // RGB
			if(textField==firstComponentField || textField==secondComponentField || textField==thirdComponentField)
			{
				actualColor.red=[firstComponentField.text intValue];
				actualColor.green=[secondComponentField.text intValue];
				actualColor.blue=[thirdComponentField.text intValue];
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
			}
			else 
			{
                // HSV
				if(textField==hueField || textField==saturationField || textField==valueField)
				{
					actualColor.hue=[hueField.text intValue];
					actualColor.saturation=(float)[saturationField.text intValue]/100.0;
					actualColor.vvalue=(float)[valueField.text intValue]/100.0;
					[self hsvToRGB:&actualColor];
					[self rgbToCMYK:&actualColor];
				}
                // CMYK
				else 
				{
					actualColor.cyan=[cyanField.text intValue];
					actualColor.magenta=(float)[magentaField.text intValue]/100.0;
					actualColor.yellow=(float)[yellowField.text intValue]/100.0;
					actualColor.key=(float)[keyField.text intValue]/100.0;
					[self cmykToRGB:&actualColor];
					[self rgbToHSV:&actualColor];
				}
			}
		}
        // on iPhone we have textfield values depending on the selected color scheme
		else 
		{
			// rgb
			if(rgbhsvButton.selectedSegmentIndex<3)
			{
				actualColor.red=[firstComponentField.text intValue];
				actualColor.green=[secondComponentField.text intValue];
				actualColor.blue=[thirdComponentField.text intValue];
				[self rgbToHSV:&actualColor];
				[self rgbToCMYK:&actualColor];
			}
			// hsv
			else 
			{
				actualColor.hue=[firstComponentField.text intValue];
				actualColor.saturation=(float)[secondComponentField.text intValue]/100.0;
				actualColor.vvalue=(float)[thirdComponentField.text intValue]/100.0;
				[self hsvToRGB:&actualColor];
				[self rgbToCMYK:&actualColor];
			}
		}
	}
    // set color 
	[self changeColor];
	return YES;
}

// redraw all
-(void)changeColor
{
	// draw preview color
	previewView.backgroundColor=[UIColor colorWithRed:(float)actualColor.red/255.0 green:(float)actualColor.green/255.0 blue:(float)actualColor.blue/255.0 alpha:actualColor.alpha];

	// set TextField values
	// iPad
	if([self deviceIsiPad])
	{
		[firstComponentField setText:[NSString stringWithFormat:@"%d",actualColor.red]];
		[secondComponentField setText:[NSString stringWithFormat:@"%d",actualColor.green]];
		[thirdComponentField setText:[NSString stringWithFormat:@"%d",actualColor.blue]];

		[hueField setText:[NSString stringWithFormat:@"%3.0f",actualColor.hue]];
		[saturationField setText:[NSString stringWithFormat:@"%3.0f",actualColor.saturation*100.0]];
		[valueField setText:[NSString stringWithFormat:@"%3.0f",actualColor.vvalue*100.0]];

		[cyanField setText:[NSString stringWithFormat:@"%3.0f",actualColor.cyan*100.0]];
		[magentaField setText:[NSString stringWithFormat:@"%3.0f",actualColor.magenta*100.0]];
		[yellowField setText:[NSString stringWithFormat:@"%3.0f",actualColor.yellow*100.0]];
		[keyField setText:[NSString stringWithFormat:@"%3.0f",actualColor.key*100.0]];
	}
	// iPhone
	else 
	{
		// rgb
		if(rgbhsvButton.selectedSegmentIndex<3)
		{
			[firstComponentField setText:[NSString stringWithFormat:@"%d",actualColor.red]];
			[secondComponentField setText:[NSString stringWithFormat:@"%d",actualColor.green]];
			[thirdComponentField setText:[NSString stringWithFormat:@"%d",actualColor.blue]];
		}
		// hsv
		else 
		{
			[firstComponentField setText:[NSString stringWithFormat:@"%3.0f",round(actualColor.hue)]];
			[secondComponentField setText:[NSString stringWithFormat:@"%3.0f",round(actualColor.saturation*100.0)]];
			[thirdComponentField setText:[NSString stringWithFormat:@"%3.0f",round(actualColor.vvalue*100.0)]];		
		}
	}
	[webcolorField setText:[NSString stringWithFormat:@"%02x%02x%02x",actualColor.red,actualColor.green,actualColor.blue]];

	// draw two picker views
	[self drawOneComponentImage];
	[self drawTwoComponentImage];
}

// rgbhsvButon changed. redraw all 
-(IBAction)rgbhsvButton:(id)sender
{
	[self changeColor];
}

// change alpha value
-(IBAction)changeAlphaSlider:(id)sender
{
	actualColor.alpha=alphaSlider.value;
	[alphaField setText:[NSString stringWithFormat:@"%3.0f",round(alphaSlider.value*100.0)]];
	// draw preview color
	previewView.backgroundColor=[UIColor colorWithRed:(float)actualColor.red/255.0 green:(float)actualColor.green/255.0 blue:(float)actualColor.blue/255.0 alpha:actualColor.alpha];
}

// cancel button pressed
-(IBAction)cancel:(id)sender
{
    [delegate colorPicker:self didCancelWithTag:userTag];
}

// ok button
-(IBAction)done:(id)sender
{
    [delegate colorPicker:self didSelectColorWithTag:userTag Red:actualColor.red Green:actualColor.green Blue:actualColor.blue Alpha:round(actualColor.alpha*255.0)];
	if([self deviceIsiPad] && popOver)
	{
		[popOver.delegate popoverControllerDidDismissPopover:popOver];
		[popOver dismissPopoverAnimated:YES];
	}
	else 
		[self dismissModalViewControllerAnimated:YES];
}

// check devicetype
-(BOOL)deviceIsiPad
{
	UIDevice *device=[UIDevice currentDevice];
	if([device userInterfaceIdiom]==UIUserInterfaceIdiomPad)
		return YES;
	return NO;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil Tag:(NSInteger)tag Color:(UIColor*)color
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
		userTag=tag;
        // default color is black
		actualColor.red=actualColor.green=actualColor.blue=0;
		actualColor.alpha=255;
		// must suport rgb color
		if(CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor))==kCGColorSpaceModelRGB)
		{
			const CGFloat *c = CGColorGetComponents(color.CGColor);
            // RGBA
			actualColor.red=round(c[0]*255);
			actualColor.green=round(c[1]*255);
			actualColor.blue=round(c[2]*255);
			actualColor.alpha=c[3];
            // calc to HSV and CMYK
			[self rgbToHSV:&actualColor];
			[self rgbToCMYK:&actualColor];
		}
        else
            return nil;
	}
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    twoComponentContext = CreateARGBBitmapContext(self.twoComponentView.frame.size.width,
                                                  self.twoComponentView.frame.size.height);
    oneComponentContext = CreateARGBBitmapContext(self.oneComponentView.frame.size.width,
                                                  self.oneComponentView.frame.size.height);
	
	
	// selector images. circle for two component and arrow for one component
	circleView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle.png"]];
	circleView.contentMode=UIViewContentModeScaleToFill;
	arrowView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrows.png"]];
	
	// add selectors to views
	[twoComponentView addSubview:circleView];
	[arrowParentView addSubview:arrowView];
	
	[alphaSlider setValue:(float)actualColor.alpha];
	[alphaField setText:[NSString stringWithFormat:@"%3.0f",round(alphaSlider.value*100)]];
	
	// draw all
	[self changeColor];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
	
	if(twoComponentContext)
		CGContextRelease(twoComponentContext), twoComponentContext=nil; 
	if(oneComponentContext)
		CGContextRelease(oneComponentContext), oneComponentContext=nil; 
}

- (void)dealloc 
{
	self.okButton=nil;
	self.cancelButton=nil;
	self.alphaSlider=nil;
	
	self.arrowParentView=nil;
	self.oneComponentView=nil;
	self.twoComponentView=nil;
	self.oneComponentBorder=nil;
	self.twoComponentBorder=nil;
	
	self.webcolorLabel=nil;
	self.alphaLabel=nil;
	
	self.keyField=nil;
	self.yellowField=nil;
	self.magentaField=nil;
	self.cyanField=nil;
	
	self.valueField=nil;
	self.saturationField=nil;
	self.hueField=nil;

	self.alphaField=nil;
	self.webcolorField=nil;
	self.thirdComponentField=nil;
	self.secondComponentField=nil;
	self.firstComponentField=nil;
	
	self.rgbhsvButton=nil;
	
	self.previewView=nil;
	self.previewBorderView=nil;
	
	self.arrowView=nil;
	self.circleView=nil;
	
	self.popOver=nil;
	[super dealloc];
}

@end
