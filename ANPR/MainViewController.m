//
//  MainViewController.m
//  ANPR
//
//  Created by Christian Roman on 29/08/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "MainViewController.h"
#import "ImageProcessingImplementation.h"
#import "UIImage+operation.h"

@interface MainViewController ()
{
    id <ImageProcessingProtocol> imageProcessor;
    UIImagePickerController *imagePicker;
    UIImage *takenImage;
    UIImage *processedImage;
}

@property (strong, nonatomic) IBOutlet UIImageView *resultImageView;
@property (strong, nonatomic) IBOutlet UIButton *processButton;
@property (strong, nonatomic) IBOutlet UIButton *readButton;

- (IBAction)takePhoto:(id)sender;
- (IBAction)OCR:(id)sender;
- (IBAction)processImage:(id)sender;

@end

@implementation MainViewController

@synthesize resultImageView;
@synthesize processButton;
@synthesize readButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    imageProcessor = [ImageProcessingImplementation new];
}

- (void)viewDidUnload
{
    [self setResultImageView:nil];
    [self setProcessButton:nil];
    [self setReadButton:nil];
    [super viewDidUnload];
}

- (IBAction)processImage:(id)sender
{
    processedImage = [imageProcessor processImage:processedImage];
    [resultImageView setImage:processedImage];
}

- (IBAction)OCR:(id)sender
{
    NSString *readed = [imageProcessor OCRImage:processedImage];
    [[[UIAlertView alloc] initWithTitle:@"Recognized"
                                message:readed
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (IBAction)takePhoto:(id)sender
{
    imagePicker = [UIImagePickerController new];
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:YES];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Take a photo or choose existing, and use the control to center the announce"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take photo", @"Choose Existing", nil];
        [actionSheet showInView:self.view];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != actionSheet.cancelButtonIndex){
        if (buttonIndex == 0)
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        else if (buttonIndex == 1)
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    CGRect croppedRect=[[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
    UIImage *original=[info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *rotatedCorrectly;
    
    if (original.imageOrientation!=UIImageOrientationUp)
        rotatedCorrectly = [original rotate:original.imageOrientation];
    else
        rotatedCorrectly = original;
    
    CGImageRef ref= CGImageCreateWithImageInRect(rotatedCorrectly.CGImage, croppedRect);
    takenImage= [UIImage imageWithCGImage:ref];
    [self.resultImageView setImage:takenImage];
    processedImage= takenImage;
    [processButton setHidden:NO];
    [readButton setHidden:NO];
}

@end
