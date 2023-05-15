//
//  OpenCVWrapper.m
//  BeerUp
//
//  Created by Maciek  Surowiec on 13/10/2022.
//
#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.hh"

#import <opencv2/features2d.hpp>

static void UIImageToMat(UIImage *image, cv::Mat &mat) {
    assert(image.size.width > 0 && image.size.height > 0);
    assert(image.CGImage != nil || image.CIImage != nil);

    // Create a pixel buffer.
    NSInteger width = image.size.width;
    NSInteger height = image.size.height;
    cv::Mat mat8uc4 = cv::Mat((int)height, (int)width, CV_8UC4);

    // Draw all pixels to the buffer.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (image.CGImage) {
        // Render with using Core Graphics.
        CGContextRef contextRef = CGBitmapContextCreate(mat8uc4.data, mat8uc4.cols, mat8uc4.rows, 8, mat8uc4.step, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
        CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), image.CGImage);
        CGContextRelease(contextRef);
    } else {
        // Render with using Core Image.
        static CIContext* context = nil; // I do not like this declaration contains 'static'. But it is for performance.
        if (!context) {
            context = [CIContext contextWithOptions:@{ kCIContextUseSoftwareRenderer: @NO }];
        }
        CGRect bounds = CGRectMake(0, 0, width, height);
        [context render:image.CIImage toBitmap:mat8uc4.data rowBytes:mat8uc4.step bounds:bounds format:kCIFormatRGBA8 colorSpace:colorSpace];
    }
    CGColorSpaceRelease(colorSpace);

    // Adjust byte order of pixel.
    cv::Mat mat8uc3 = cv::Mat((int)width, (int)height, CV_8UC3);
    cv::cvtColor(mat8uc4, mat8uc3, cv::COLOR_RGBA2BGR);

    mat = mat8uc3;
}

/// Converts a Mat to UIImage.
static UIImage *MatToUIImage(cv::Mat &mat) {

    // Create a pixel buffer.
    assert(mat.elemSize() == 1 || mat.elemSize() == 3);
    cv::Mat matrgb;
    if (mat.elemSize() == 1) {
        cv::cvtColor(mat, matrgb, cv::COLOR_GRAY2RGB);
    } else if (mat.elemSize() == 3) {
        cv::cvtColor(mat, matrgb, cv::COLOR_BGR2RGB);
    }

    // Change a image format.
    NSData *data = [NSData dataWithBytes:matrgb.data length:(matrgb.elemSize() * matrgb.total())];
    CGColorSpaceRef colorSpace;
    if (matrgb.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(matrgb.cols, matrgb.rows, 8, 8 * matrgb.elemSize(), matrgb.step.p[0], colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return image;
}

static UIImage *RestoreUIImageOrientation(UIImage *processed, UIImage *original) {
    if (processed.imageOrientation == original.imageOrientation) {
        return processed;
    }
    return [UIImage imageWithCGImage:processed.CGImage scale:1.0 orientation:original.imageOrientation];
}

static NSMutableArray* PCA(cv::Mat data) {
    
    cv::Mat datac;
    data.convertTo(datac, CV_32FC1);
    cv::PCA pca(data,cv::noArray(),cv::PCA::DATA_AS_ROW, 1);
    cv::Mat fv = pca.eigenvectors;
    cv::Mat m = pca.mean;
    
    for(int i=0; i<data.rows;i++) {
        for(int j=0;j<data.cols;j++){
            datac.at<float>(i, j) = data.at<uchar>(i, j) - m.at<float>(j);
        }
    }
    
    cv::Mat fv2;
    cv::Mat_<float> n;
    cv::transpose(fv,n);
    cv::Mat outputMat = datac * n;
    
    NSMutableArray *output = [[NSMutableArray alloc] init];
    
    //for(int i=0; i<outputMat.cols;i++) {
        for(int j=0;j<outputMat.rows;j++) {
            float f = outputMat.at<float>(j);
            NSNumber *num = [NSNumber numberWithFloat: f];
            //[output insertObject:num atIndex:i + j * outputMat.cols];
            [output insertObject:num atIndex:j];
        }
  //  }
    
    return output;
}


@implementation OpenCVWrapper
+ (NSString *)openCVVersionString {
return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}


+ (NSMutableArray *)getImageFeatures:(nonnull UIImage *)image width:(int)width height:(int)height x:(int)x y:(int)y{
    cv::Mat imgMat;
    UIImageToMat(image, imgMat);
    
    int minx = x - width/2 > 0 ? x - width/2: 1;
    int maxx = x + width/2 < imgMat.rows ? x + width/2: imgMat.rows-1;
    
    int miny = y - height/2 > 0 ? y - height/2: 1;
    int maxy = y + height/2 < imgMat.cols ? y + height/2: imgMat.cols-1;
    
    cv::Mat cropped_image = imgMat(cv::Range(minx, maxx),cv::Range(miny, maxy));
    //cv::Point center(y, x);
    //cv::circle(imgMat, center, 40, (0, 0, 255), 40);
    cv::Mat resizedImage;
    cv::resize(cropped_image, resizedImage, cv::Size(800, 800));
    
    //return RestoreUIImageOrientation(MatToUIImage(resizedImage), image);
    
    cv::SIFT sift;
    sift.create(0, 3, 0.1, 10, 1.6, 0);
    cv::Ptr<cv::Feature2D> f2d = cv::SIFT::create(0, 3, 0.1, 10, 1.6, 0);
    std::vector<cv::KeyPoint> keypoints;
    cv::Mat descriptors;
    f2d->detect(resizedImage, keypoints);
    f2d->compute(resizedImage, keypoints, descriptors);
    cv::Mat transposed;
    cv::transpose(descriptors, transposed);
    
    return PCA(transposed);
     
}
@end
