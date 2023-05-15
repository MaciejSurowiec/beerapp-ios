#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#import <opencv2/opencv.hpp>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
+ (NSString *)openCVVersionString;
//+ (NSMutableArray* )getImageFeatures:(UIImage *)image width:(int)width height:(int)height x:(int)x y:(int)y;
+ (UIImage* )getImageFeatures:(UIImage *)image width:(int)width height:(int)height x:(int)x y:(int)y;
@end

NS_ASSUME_NONNULL_END
