//
//  ImageProcessor.h
//  ANPR
//
//  Created by Christian Roman on 29/08/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#ifndef ANPR_ImageProcessor_h
#define ANPR_ImageProcessor_h

class ImageProcessor {
    typedef struct{
        int contador;
        double media;
    } cuadrante;
    
public:
    cv::Mat processImage(cv::Mat source, float height);
    cv::Mat filterMedianSmoot(const cv::Mat &source);
    cv::Mat filterGaussian(const cv::Mat&source);
    cv::Mat equalize(const cv::Mat&source);
    cv::Mat binarize(const cv::Mat&source);
    int correctRotation (cv::Mat &image, cv::Mat &output, float height);
    cv::Mat rotateImage(const cv::Mat& source, double angle);
};

#endif
