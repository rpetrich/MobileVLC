/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

static UIImage *scaleImage(UIImage *sourceImage, CGSize targetSize)
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;

    CGFloat widthFactor = targetWidth / width;
    CGFloat heightFactor = targetHeight / height;

    CGFloat scaleFactor = 0.0;
    if (widthFactor < heightFactor)
        scaleFactor = widthFactor; // scale to fit height
    else
        scaleFactor = heightFactor; // scale to fit width
    scaledWidth  = width * scaleFactor;
    scaledHeight = height * scaleFactor;

    CGSize size = CGSizeMake(scaledWidth, scaledHeight);

    UIGraphicsBeginImageContext(size); // this will crop

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    //pop the context to get back to the default
    UIGraphicsEndImageContext();

    return newImage;
}

- (void)setOriginalImage:(UIImage *)image forURL:(NSURL *)url
{
    // Now create also a thumbnail.
    CGSize thumbnailSize = [self bounds].size;
    UIImage *scaledImage = scaleImage(image, thumbnailSize);
    NSAssert(scaledImage, @"could not scale");

    NSString *key = [[url absoluteString] stringByAppendingString:NSStringFromCGSize(thumbnailSize)];
    [[SDImageCache sharedImageCache] storeImage:scaledImage forKey:key];

    self.image = scaledImage;
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    if (url) {
        // Check for a correctly sized image first
        CGSize thumbnailSize = [self bounds].size;
        NSString *key = [[url absoluteString] stringByAppendingString:NSStringFromCGSize(thumbnailSize)];
        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromKey:key];
        if (cachedImage) {
            [self setImage:cachedImage];
            return;
        }

        UIImage *cachedOriginalImage = [manager imageWithURL:url];
        if (cachedOriginalImage) {
            [self setOriginalImage:cachedOriginalImage forURL:url];
            return;
        }
    }


    if (placeholder)
        self.image = placeholder;
    else
        self.image = nil;
    if (url)
        [manager downloadWithURL:url delegate:self];

}

- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}


- (void)webImageManagerDidFinishWithImage:(UIImage *)image atURL:(NSURL *)url
{
    if (!image)
        return;
    [self setOriginalImage:image forURL:url];
}

@end
