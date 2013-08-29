//
//  ImageProcessingImplementation.m
//  ANPR
//
//  Created by Christian Roman on 29/08/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "ImageProcessingImplementation.h"
#import "ImageProcessor.h"
#import "UIImage+OpenCV.h"

#define kWhiteList @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-"

@implementation ImageProcessingImplementation

- (NSString*)pathToLanguageFile
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([documentPaths count] > 0) ? [documentPaths objectAtIndex:0] : nil;
    NSString *dataPath = [documentPath stringByAppendingPathComponent:@"tessdata"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dataPath]) {
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
        if (tessdataPath) {
            [fileManager copyItemAtPath:tessdataPath toPath:dataPath error:NULL];
        }
    }
    setenv("TESSDATA_PREFIX", [[documentPath stringByAppendingString:@"/"] UTF8String], 1);
    return dataPath;
}

- (NSString*)OCRImage:(UIImage*)src
{
    tesseract::TessBaseAPI *tesseract = new tesseract::TessBaseAPI();
    tesseract->Init([[self pathToLanguageFile] cStringUsingEncoding:NSUTF8StringEncoding], "eng");
    NSString *whiteList = kWhiteList;
    tesseract->SetVariable("tessedit_char_whitelist", [whiteList UTF8String]);
    tesseract->SetPageSegMode(tesseract::PSM_SINGLE_WORD);
    cv::Mat toOCR=[src CVGrayscaleMat];
    tesseract->SetImage((uchar*)toOCR.data, toOCR.size().width, toOCR.size().height, toOCR.channels(), toOCR.step1());
    tesseract->Recognize(NULL);
    char *utf8Text = tesseract->GetUTF8Text();
    return [NSString stringWithUTF8String:utf8Text];
}

- (UIImage*)processImage:(UIImage*)src
{
    ImageProcessor processor;
    cv::Mat source = [src CVMat];
    cv::Mat output = processor.filterMedianSmoot(source);
    
    //threshold(output, output, 230, 255, CV_THRESH_OTSU+CV_THRESH_BINARY);
    //threshold( output, output, 150, 255, CV_THRESH_BINARY );
    //GaussianBlur(output, output, cv::Size(5, 5), 0, 0);
    //adaptiveThreshold(output, output, 255, CV_ADAPTIVE_THRESH_MEAN_C, CV_THRESH_BINARY, 75, 10);
    
    /* Pre-processing */
    
    cv::Mat img_gray;
    cv::cvtColor(source, img_gray, CV_BGR2GRAY);
    blur(img_gray, img_gray, cv::Size(5,5));
    //medianBlur(img_gray, img_gray, 9);
    cv::Mat img_sobel;
    cv::Sobel(img_gray, img_sobel, CV_8U, 1, 0, 3, 1, 0, cv::BORDER_DEFAULT);
    cv::Mat img_threshold;
    threshold(img_gray, img_threshold, 0, 255, CV_THRESH_OTSU+CV_THRESH_BINARY);
    cv::Mat element = getStructuringElement(cv::MORPH_RECT, cv::Size(3, 3) );
    morphologyEx(img_threshold, img_threshold, CV_MOP_CLOSE, element);
    
    /* Search for contours */
    
    std::vector<std::vector<cv::Point> > contours;
    cv::Mat contourOutput = img_threshold.clone();
    cv::findContours( contourOutput, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE );
    
    std::vector<cv::Vec4i> hierarchy;
    
    /* Get the largest contour (Possible license plate) */
    
    int largestArea = -1;
    std::vector<std::vector<cv::Point> > largestContour;
    
    std::vector<std::vector<cv::Point> > polyContours( contours.size() );
    
    //std::vector<cv::Point> approx;
    for( int i = 0; i < contours.size(); i++ ){
        approxPolyDP( cv::Mat(contours[i]), polyContours[i], arcLength(cv::Mat(contours[i]), true)*0.02, true );
        
        if (polyContours[i].size() == 4 && fabs(contourArea(cv::Mat(polyContours[i]))) > 1000 && isContourConvex(cv::Mat(polyContours[i]))){
            double maxCosine = 0;
            
            for (int j = 2; j < 5; j++){
                double cosine = fabs(::angle(polyContours[i][j%4], polyContours[i][j-2], polyContours[i][j-1]));
                
                maxCosine = MAX(maxCosine, cosine);
            }
            
            if (maxCosine < 0.3)
                NSLog(@"Square detected");
        }
        
    }
    
    for( int i = 0; i< polyContours.size(); i++ ){
        
        int area = fabs(contourArea(polyContours[i],false));
        if(area > largestArea){
            largestArea = area;
            largestContour.clear();
            largestContour.push_back(polyContours[i]);
        }
        
    }
    
    // Contour drawing debug
    cv::Mat drawing = cv::Mat::zeros( contourOutput.size(), CV_8UC3 );
    if(largestContour.size()>=1){
        
        cv::drawContours(source, largestContour, -1, cv::Scalar(0, 255, 0), 0);
        
    }
    
    /* Get RotatedRect for the largest contour */
    
    std::vector<cv::RotatedRect> minRect( largestContour.size() );
    for( int i = 0; i < largestContour.size(); i++ )
        minRect[i] = minAreaRect( cv::Mat(largestContour[i]) );
    
    cv::Mat drawing2 = cv::Mat::zeros( img_threshold.size(), CV_8UC3 );
    for( int i = 0; i< largestContour.size(); i++ ){
        
        cv::Point2f rect_points[4]; minRect[i].points( rect_points );
        for( int j = 0; j < 4; j++ ){
            line( drawing2, rect_points[j], rect_points[(j+1)%4], cv::Scalar(0,255,0), 1, 8 );
            
        }
        
    }
    
    /* Get Region Of Interest ROI */
    
    cv::RotatedRect box = minAreaRect( cv::Mat(largestContour[0]));
    cv::Rect box2 = cv::RotatedRect(box.center, box.size, box.angle).boundingRect();
    
    box2.x += box2.width * 0.04;
    box2.width -= box2.width * 0.05;
    box2.y += box2.height * 0.305;
    box2.height -= box2.height * 0.55;
    
    cv::Mat cvMat = img_threshold(box2).clone();
    
    /* Experimental
    
    cv::Point2f pts[4];
    
    std::vector<cv::Point> shape;
    
    shape.push_back(largestContour[0][3]);
    shape.push_back(largestContour[0][2]);
    shape.push_back(largestContour[0][1]);
    shape.push_back(largestContour[0][0]);
    
    cv::RotatedRect boxx = minAreaRect(cv::Mat(shape));
    
    box.points(pts);
    
    cv::Point2f src_vertices[3];
    src_vertices[0] = shape[0];
    src_vertices[1] = shape[1];
    src_vertices[2] = shape[3];
    
    cv::Point2f dst_vertices[3];
    dst_vertices[0] = cv::Point(0, 0);
    dst_vertices[1] = cv::Point(boxx.boundingRect().width-1, 0);
    dst_vertices[2] = cv::Point(0, boxx.boundingRect().height-1);
    
    cv::Mat warpAffineMatrix = getAffineTransform(src_vertices, dst_vertices);
    
    cv::Mat rotated;
    cv::Size size(boxx.boundingRect().width, boxx.boundingRect().height);
    cv::warpAffine(source, rotated, warpAffineMatrix, size, cv::INTER_LINEAR, cv::BORDER_CONSTANT);
     
    */
     
    UIImage *filtered=[UIImage imageWithCVMat:cvMat];
    return filtered;
}

double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 )
{
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1 * dx2 + dy1 * dy2)/sqrt((dx1 * dx1 + dy1 * dy1) * (dx2 * dx2 + dy2 * dy2) + 1e-10);
}

@end
