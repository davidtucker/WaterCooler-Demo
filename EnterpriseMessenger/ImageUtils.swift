//
//  UIImageMasking.swift
//  M13ExtensionsSuite
//
/*
MIT License

Copyright (c) 2014 Brandon McQuilkin

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import UIKit
import CoreImage

extension UIImage {
    
    /**Masks an image with the given mask image. The mask image can be an alpha mask, or black and white mask. If the image has an alpha channel, it will be treated as an alpha mask.
    @param image The background image that will be masked.
    @param mask The mask image.
    @return The image masked by the mask image.*/
    class func maskedImage(#image: UIImage, withMask mask: UIImage) -> UIImage {
        //Get the alpha info
        let alphaInfo: CGImageAlphaInfo = CGImageGetAlphaInfo(mask.CGImage)
        
        //Do we have an alpha channel?
        if alphaInfo == CGImageAlphaInfo.First || alphaInfo == CGImageAlphaInfo.Last || alphaInfo == CGImageAlphaInfo.PremultipliedFirst || alphaInfo == CGImageAlphaInfo.PremultipliedLast {
            //Yes
            return UIImage.maskedImage(image, withAlphaMask: mask)
        } else {
            //No
            return UIImage.maskedImage(image, withNonAlphaMask: mask)
        }
    }
    
    /**Creates an icon of the given color, masked by the mask image. The mask image can be an alpha mask, or black and white mask. If the image has an alpha channel, it will be treated as an alpha mask.
    @param color The color of the new image.
    @param mask The mask image.
    @return An icon of the given color masked by the mask image.*/
    class func maskedImage(#color: UIColor, withMask mask: UIImage) -> UIImage {
        //Get the alpha info
        let alphaInfo: CGImageAlphaInfo = CGImageGetAlphaInfo(mask.CGImage)
        
        //Do we have an alpha channel?
        if alphaInfo == CGImageAlphaInfo.First || alphaInfo == CGImageAlphaInfo.Last || alphaInfo == CGImageAlphaInfo.PremultipliedFirst || alphaInfo == CGImageAlphaInfo.PremultipliedLast {
            //Yes
            return UIImage.maskedImage(color, withAlphaMask: mask)
        } else {
            //No
            return UIImage.maskedImage(color, withNonAlphaMask: mask)
        }
    }
    
    private class func maskedImage(image: UIImage, withAlphaMask mask: UIImage) -> UIImage {
        //First draw the background centered on an image the same size as the mask. This helps solve problems if the images are different sizes. Ususally the background is larger than the mask.
        UIGraphicsBeginImageContextWithOptions(mask.size, false, mask.scale)
        image.drawInRect(CGRectMake((mask.size.width - image.size.width) / 2.0, (mask.size.height - image.size.height) / 2.0, image.size.width, image.size.height))
        let iconBackground: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Create the mask
        let context = CGBitmapContextCreate(nil, CGImageGetWidth(mask.CGImage), CGImageGetHeight(mask.CGImage), 8, 0, nil, CGBitmapInfo(rawValue: CGImageAlphaInfo.Only.rawValue))
        CGContextDrawImage(context, CGRectMake(0, 0, mask.size.width * mask.scale, mask.size.height * mask.scale), mask.CGImage)
        let maskRef: CGImageRef = CGBitmapContextCreateImage(context)
        
        //Mask the image
        let masked: CGImageRef = CGImageCreateWithMask(iconBackground.CGImage, maskRef)
        
        //Finished
        return UIImage(CGImage: masked, scale: mask.scale, orientation: mask.imageOrientation)!
    }
    
    private class func maskedImage(image: UIImage, withNonAlphaMask mask: UIImage) -> UIImage {
        //First draw the background centered on an image the same size as the mask. This helps solve problems if the images are different sizes. Ususally the background is larger than the mask.
        UIGraphicsBeginImageContextWithOptions(mask.size, false, mask.scale)
        image.drawInRect(CGRectMake((mask.size.width - image.size.width) / 2.0, (mask.size.height - image.size.height) / 2.0, image.size.width, image.size.height))
        let iconBackground: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Create the mask
        let maskRef: CGImageRef = CGImageMaskCreate(CGImageGetWidth(mask.CGImage), CGImageGetHeight(mask.CGImage), CGImageGetBitsPerComponent(mask.CGImage), CGImageGetBitsPerPixel(mask.CGImage), CGImageGetBytesPerRow(mask.CGImage), CGImageGetDataProvider(mask.CGImage), nil, false)
        
        //Mask the image
        let masked: CGImageRef = CGImageCreateWithMask(iconBackground.CGImage, maskRef)
        
        //Finished
        return UIImage(CGImage: masked, scale: mask.scale, orientation: mask.imageOrientation)!
    }
    
    private class func maskedImage(color: UIColor, withAlphaMask mask: UIImage) -> UIImage {
        //First draw the background color into an image
        UIGraphicsBeginImageContextWithOptions(mask.size, false, mask.scale)
        color.setFill()
        UIRectFill(CGRectMake(0, 0, mask.size.width, mask.size.height))
        let iconBackground: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Create the mask
        let context = CGBitmapContextCreate(nil, CGImageGetWidth(mask.CGImage), CGImageGetHeight(mask.CGImage), 8, 0, nil, CGBitmapInfo(rawValue: CGImageAlphaInfo.Only.rawValue))
        CGContextDrawImage(context, CGRectMake(0, 0, mask.size.width * mask.scale, mask.size.height * mask.scale), mask.CGImage)
        let maskRef: CGImageRef = CGBitmapContextCreateImage(context)
        
        //Mask the image
        let masked: CGImageRef = CGImageCreateWithMask(iconBackground.CGImage, maskRef)
        
        //Finished
        return UIImage(CGImage: masked, scale: mask.scale, orientation: mask.imageOrientation)!
    }
    
    private class func maskedImage(color: UIColor, withNonAlphaMask mask: UIImage) -> UIImage {
        //First draw the background color into an image
        UIGraphicsBeginImageContextWithOptions(mask.size, false, mask.scale)
        color.setFill()
        UIRectFill(CGRectMake(0, 0, mask.size.width, mask.size.height))
        let iconBackground: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Create the mask
        let maskRef: CGImageRef = CGImageMaskCreate(CGImageGetWidth(mask.CGImage), CGImageGetHeight(mask.CGImage), CGImageGetBitsPerComponent(mask.CGImage), CGImageGetBitsPerPixel(mask.CGImage), CGImageGetBytesPerRow(mask.CGImage), CGImageGetDataProvider(mask.CGImage), nil, false)
        
        //Mask the image
        let masked: CGImageRef = CGImageCreateWithMask(iconBackground.CGImage, maskRef)
        
        //Finished
        return UIImage(CGImage: masked, scale: mask.scale, orientation: mask.imageOrientation)!
    }
}

extension UIImage {

    public func squareCroppedImage(length:CGFloat) -> UIImage {
        
        // input size comes from image
        let inputSize = self.size;
        
        // round up side length to avoid fractional output size
        let adjustedLength = ceil(length);
        
        // output size has sideLength for both dimensions
        let outputSize = CGSizeMake(adjustedLength, adjustedLength);
        
        // calculate scale so that smaller dimension fits sideLength
        let scale = max(adjustedLength / inputSize.width,
            adjustedLength / inputSize.height);
        
        // scaling the image with this scale results in this output size
        let scaledInputSize = CGSizeMake(inputSize.width * scale,
            inputSize.height * scale);
        
        // determine point in center of "canvas"
        let center = CGPointMake(outputSize.width/2.0,
            outputSize.height/2.0);
        
        // calculate drawing rect relative to output Size
        let outputRect = CGRectMake(center.x - scaledInputSize.width/2.0,
            center.y - scaledInputSize.height/2.0,
            scaledInputSize.width,
            scaledInputSize.height);
        
        UIGraphicsBeginImageContextWithOptions(outputSize, true, 0);
        let ctx = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
        
        self.drawInRect(outputRect);
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return outputImage;
    }
    
}