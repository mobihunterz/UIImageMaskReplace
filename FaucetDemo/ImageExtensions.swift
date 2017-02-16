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

import Foundation
import UIKit
import CoreImage

extension UIImage {
    
    /**Masks an image with the given mask image. The mask image can be an alpha mask, or black and white mask. If the image has an alpha channel, it will be treated as an alpha mask.
    @param image The background image that will be masked.
    @param mask The mask image.
    @return The image masked by the mask image.*/
    class func maskedImage(image: UIImage, withMask mask: UIImage) -> UIImage {
        //Get the alpha info
        let alphaInfo: CGImageAlphaInfo = mask.cgImage!.alphaInfo
        
        //Do we have an alpha channel?
        if alphaInfo == CGImageAlphaInfo.first || alphaInfo == CGImageAlphaInfo.last || alphaInfo == CGImageAlphaInfo.premultipliedFirst || alphaInfo == CGImageAlphaInfo.premultipliedLast {
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
    class func maskedImage(color: UIColor, withMask mask: UIImage) -> UIImage {
        //Get the alpha info
        let alphaInfo: CGImageAlphaInfo = mask.cgImage!.alphaInfo
        
        //Do we have an alpha channel?
        if alphaInfo == CGImageAlphaInfo.first || alphaInfo == CGImageAlphaInfo.last || alphaInfo == CGImageAlphaInfo.premultipliedFirst || alphaInfo == CGImageAlphaInfo.premultipliedLast {
            //Yes
            return UIImage.maskedImage(color, withAlphaMask: mask)
        } else {
            //No
            return UIImage.maskedImage(color, withNonAlphaMask: mask)
        }
    }
    
    fileprivate class func maskedImage(_ image: UIImage, withAlphaMask mask: UIImage) -> UIImage {
        //First draw the background centered on an image the same size as the mask. This helps solve problems if the images are different sizes. Ususally the background is larger than the mask.
        UIGraphicsBeginImageContextWithOptions(mask.size, false, mask.scale)
        image.draw(in: CGRect(x: (mask.size.width - image.size.width) / 2.0, y: (mask.size.height - image.size.height) / 2.0, width: image.size.width, height: image.size.height))
        let iconBackground: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Create the mask
        let context = CGContext(data: nil, width: (mask.cgImage?.width)!, height: (mask.cgImage?.height)!, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.alphaOnly.rawValue).rawValue)
        context?.draw(mask.cgImage!, in: CGRect(x: 0, y: 0, width: mask.size.width * mask.scale, height: mask.size.height * mask.scale))
        let maskRef: CGImage = context!.makeImage()!
        
        //Mask the image
        let masked: CGImage = iconBackground.cgImage!.masking(maskRef)!
        
        //Finished
        return UIImage(cgImage: masked, scale: mask.scale, orientation: mask.imageOrientation)
    }
    
    fileprivate class func maskedImage(_ image: UIImage, withNonAlphaMask mask: UIImage) -> UIImage {
        //First draw the background centered on an image the same size as the mask. This helps solve problems if the images are different sizes. Ususally the background is larger than the mask.
        UIGraphicsBeginImageContextWithOptions(mask.size, false, mask.scale)
        image.draw(in: CGRect(x: (mask.size.width - image.size.width) / 2.0, y: (mask.size.height - image.size.height) / 2.0, width: image.size.width, height: image.size.height))
        let iconBackground: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Create the mask
        let maskRef: CGImage = CGImage(maskWidth: mask.cgImage!.width, height: mask.cgImage!.height, bitsPerComponent: mask.cgImage!.bitsPerComponent, bitsPerPixel: mask.cgImage!.bitsPerPixel, bytesPerRow: mask.cgImage!.bytesPerRow, provider: mask.cgImage!.dataProvider!, decode: nil, shouldInterpolate: false)!
        
        //Mask the image
        let masked: CGImage = iconBackground.cgImage!.masking(maskRef)!
        
        //Finished
        return UIImage(cgImage: masked, scale: mask.scale, orientation: mask.imageOrientation)
    }
    
    fileprivate class func maskedImage(_ color: UIColor, withAlphaMask mask: UIImage) -> UIImage {
        //First draw the background color into an image
        UIGraphicsBeginImageContextWithOptions(mask.size, false, mask.scale)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: mask.size.width, height: mask.size.height))
        let iconBackground: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Create the mask
        let context = CGContext(data: nil, width: (mask.cgImage?.width)!, height: (mask.cgImage?.height)!, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.alphaOnly.rawValue).rawValue)
        context?.draw(mask.cgImage!, in: CGRect(x: 0, y: 0, width: mask.size.width * mask.scale, height: mask.size.height * mask.scale))
        let maskRef: CGImage = context!.makeImage()!
        
        //Mask the image
        let masked: CGImage = iconBackground.cgImage!.masking(maskRef)!
        
        //Finished
        return UIImage(cgImage: masked, scale: mask.scale, orientation: mask.imageOrientation)
    }
    
    fileprivate class func maskedImage(_ color: UIColor, withNonAlphaMask mask: UIImage) -> UIImage {
        //First draw the background color into an image
        UIGraphicsBeginImageContextWithOptions(mask.size, false, mask.scale)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: mask.size.width, height: mask.size.height))
        let iconBackground: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Create the mask
        let maskRef: CGImage = CGImage(maskWidth: mask.cgImage!.width, height: mask.cgImage!.height, bitsPerComponent: mask.cgImage!.bitsPerComponent, bitsPerPixel: mask.cgImage!.bitsPerPixel, bytesPerRow: mask.cgImage!.bytesPerRow, provider: mask.cgImage!.dataProvider!, decode: nil, shouldInterpolate: false)!
        
        //Mask the image
        let masked: CGImage = iconBackground.cgImage!.masking(maskRef)!
        
        //Finished
        return UIImage(cgImage: masked, scale: mask.scale, orientation: mask.imageOrientation)
    }
    
    public func squareCroppedImage(_ length:CGFloat) -> UIImage {
        
        // input size comes from image
        let inputSize = self.size;
        
        // round up side length to avoid fractional output size
        let adjustedLength = ceil(length);
        
        // output size has sideLength for both dimensions
        let outputSize = CGSize(width: adjustedLength, height: adjustedLength);
        
        // calculate scale so that smaller dimension fits sideLength
        let scale = max(adjustedLength / inputSize.width,
            adjustedLength / inputSize.height);
        
        // scaling the image with this scale results in this output size
        let scaledInputSize = CGSize(width: inputSize.width * scale,
            height: inputSize.height * scale);
        
        // determine point in center of "canvas"
        let center = CGPoint(x: outputSize.width/2.0,
            y: outputSize.height/2.0);
        
        // calculate drawing rect relative to output Size
        let outputRect = CGRect(x: center.x - scaledInputSize.width/2.0,
            y: center.y - scaledInputSize.height/2.0,
            width: scaledInputSize.width,
            height: scaledInputSize.height);
        
        UIGraphicsBeginImageContextWithOptions(outputSize, true, 0);
        let ctx = UIGraphicsGetCurrentContext();
        ctx!.interpolationQuality = CGInterpolationQuality.high;
        
        self.draw(in: outputRect);
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return outputImage!;
    }
    
    func invertedImage() -> UIImage? {
        
        let img = CoreImage.CIImage(cgImage: self.cgImage!)
        
        let filter = CIFilter(name: "CIColorInvert")
        filter!.setDefaults()
        
        filter!.setValue(img, forKey: "inputImage")
        
        let context = CIContext(options:nil)
        
        let cgimg = context.createCGImage(filter!.outputImage!, from: filter!.outputImage!.extent)
        
        return UIImage(cgImage: cgimg!)
    }
    
    func withInvertedMaskFrom(_ image:UIImage, position:CGPoint) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        UIGraphicsBeginImageContext(size)
        draw(at: CGPoint.zero)
        image.draw(at: position, blendMode: CGBlendMode.destinationOut, alpha: 1.0)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    func getPixelColor(_ pos: CGPoint) -> UIColor {
        
        let pixelData = self.cgImage?.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func croppedImage(_ area: CGRect) -> UIImage? {
        
        if let imgRef = self.cgImage?.cropping(to: area) {
            let croppedImage = UIImage(cgImage: imgRef)
            
            return croppedImage
        } else {
            return nil
        }
    }
    
    func maskAndReplaceImage(_ maskImage: UIImage?, textureImage: UIImage?) -> UIImage {
        guard maskImage != nil && textureImage != nil else {
            return self
        }
        
        let inputImage = CIImage(cgImage: self.cgImage!)
        let bgImage = CIImage(cgImage: (textureImage?.cgImage)!)
        let maskCIImage = CIImage(cgImage: (maskImage?.cgImage)!)

        
        let context = CIContext(options: nil)
        
//        NSLog(String(describing: self.size))
//        NSLog(String(describing: maskImage?.size))
//        NSLog(String(describing: tex.size))
        
        if let filter = CIFilter(name: "CIBlendWithAlphaMask") {
            filter.setValue(bgImage, forKey: kCIInputImageKey)
            filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
            filter.setValue(maskCIImage, forKey: kCIInputMaskImageKey)
            
            if let result = filter.outputImage {
                // TODO: Time consuming task
                let cgImg = context.createCGImage(result, from: result.extent)
                return UIImage(cgImage: cgImg!)
            }
        }
        
        return self
    }
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
