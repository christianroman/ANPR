//
//  ImageProcessingImplementation.h
//  ANPR
//
//  Created by Christian Roman on 29/08/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageProcessingProtocol.h"

@interface ImageProcessingImplementation : NSObject <ImageProcessingProtocol>

- (UIImage*)processImage:(UIImage*) src;
- (NSString*)OCRImage:(UIImage*) src;
- (NSString*)pathToLanguageFile;

@end
