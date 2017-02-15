//
//  ViewController.swift
//  FaucetDemo
//
//  Created by Paresh Thakor on 13/02/17.
//  Copyright © 2017 Paresh Thakor. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imgView: UIImageView?
    @IBOutlet weak var imgViewBack: UIImageView?
    @IBOutlet weak var colorView: UIView?
    @IBOutlet weak var textureView: UIImageView?
    
    private var previousPoint1:CGPoint?
    private var previousPoint2:CGPoint?
    private var lastPoint: CGPoint?
    private var isErase: Bool = false
    
    private var mainImage:UIImage?
    private var maskImage:UIImage?
    private var textureImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mainImage = UIImage(named: "eraser.png")
        imgView?.image = mainImage
        imgView?.contentMode = .ScaleAspectFit
        
        imgViewBack?.opaque = true
        colorView?.layer.borderWidth = 2.0
        colorView?.layer.borderColor = UIColor.blackColor().CGColor
        colorView?.layer.cornerRadius = 10.0
        
        textureView?.layer.borderWidth = 2.0
        textureView?.layer.borderColor = UIColor.blackColor().CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func maskImageWithCoreImage(image: UIImage, maskImage: UIImage?) -> UIImage {
        guard maskImage != nil else {
            return image
        }
        
//        let maskRef = maskImage!.CGImage
//        let mask = CGImageMaskCreate(CGImageGetWidth(maskRef), CGImageGetHeight(maskRef), CGImageGetBitsPerComponent(maskRef), CGImageGetBitsPerPixel(maskRef), CGImageGetBytesPerRow(maskRef), CGImageGetDataProvider(maskRef), nil, false)
//        let masked = CGImageCreateWithMask(image.CGImage, mask)
        
        let context = CIContext(options: nil)
        let inputImage = CIImage(CGImage: image.CGImage!)
        
//        var textureImg = UIImage(CGImage: CGImageCreateWithImageInRect(textureImage?.CGImage, CGRect(origin: CGPointZero, size: CGSizeMake(400, 400)))!)
        
//        let trans = CGAffineTransform()
//        let filterTex = CIFilter(name: "CIAffineTile")
//        filterTex?.setValue(CIImage(CGImage: (textureImage?.CGImage)!), forKey: kCIInputImageKey)
//        textureImg = UIImage(CIImage: (filterTex?.outputImage)!)
        
        var textureImg = UIImage(color: UIColor(patternImage: textureImage!), size: CGSizeMake(3000, 3000))!
        UIImageWriteToSavedPhotosAlbum(textureImg, nil, nil, nil)
        
        let bgImage = CIImage(CGImage: (textureImg.CGImage)!)
        let maskCIImage = CIImage(CGImage: (maskImage?.CGImage)!)
        
        NSLog(String(image.size))
        NSLog(String(maskImage?.size))
        NSLog(String(textureImg.size))
        
        
        if let filter = CIFilter(name: "CIBlendWithAlphaMask") {
            filter.setValue(bgImage, forKey: kCIInputImageKey)
            filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
            filter.setValue(maskCIImage, forKey: kCIInputMaskImageKey)
            
            if let result = filter.outputImage {
                let cgImg = context.createCGImage(result, fromRect: result.extent)      // Time consuming task
                return UIImage(CGImage: cgImg)
            }
        }
        
        return image
    }
    
    func maskImage(image: UIImage, maskImage:UIImage?) -> UIImage {
        guard maskImage != nil else {
            return image
        }
        
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue).rawValue
//        let colorSpace = CGColorSpaceCreateDeviceRGB()!
//        let context = CGBitmapContextCreate(nil, CGImageGetWidth(maskImage!.CGImage), CGImageGetHeight(maskImage!.CGImage), 8, 0, colorSpace, bitmapInfo)
//        
//        CGContextDrawImage(context, CGRectMake(0, 0, (maskImage?.size.width)!, (maskImage?.size.height)!), maskImage?.CGImage)
//        
//        let maskRef: CGImageRef = CGBitmapContextCreateImage(context)!
//        let masked: CGImageRef = CGImageCreateWithMask(image.CGImage, maskRef)!
//        
//        let icon: UIImage = UIImage(CGImage: masked)
//        
//        return icon
        
        let maskRef = maskImage!.CGImage
        let mask = CGImageMaskCreate(CGImageGetWidth(maskRef), CGImageGetHeight(maskRef), CGImageGetBitsPerComponent(maskRef), CGImageGetBitsPerPixel(maskRef), CGImageGetBytesPerRow(maskRef), CGImageGetDataProvider(maskRef), nil, false)
        let masked = CGImageCreateWithMask(image.CGImage, mask)
        
        guard masked != nil else {
            return image
        }
        
        return UIImage(CGImage: masked!)
    }

    
    @IBAction func maskImageClicked(sender: AnyObject?) {
        imgView?.image = maskImageWithCoreImage(mainImage!, maskImage: maskImage)
        //imgView?.image = maskImage(maskImage!, maskImage: mainImage!)
        //imgView?.image = mainImage!.withInvertedMaskFrom(maskImage!, position: CGPointZero)
        //imgView?.image = UIImage.maskedImage(image: maskImage!, withMask: mainImage!)
        imgViewBack?.image = nil
        //maskImage = nil
    }
    
    @IBAction func replaceImage(sender: AnyObject?) {
        imgViewBack?.alpha = 1.0
        UIGraphicsBeginImageContextWithOptions(imgViewBack!.bounds.size, false, 0.0)
        imgViewBack?.layer.renderInContext( UIGraphicsGetCurrentContext()! )
        maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imgView?.image = maskImage
        imgViewBack?.image = nil
    }

    @IBAction func loadGallery(sender: AnyObject?) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            picker.sourceType = .Camera
        } else {
            picker.sourceType = .PhotoLibrary
        }
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
//        if let photoRefUrl = info[UIImagePickerControllerReferenceURL] as? NSURL {
//            let assets = PHAsset.fetchAssetsWithALAssetURLs([photoRefUrl], options: nil)
//            let asset = assets.firstObject
//            
//            
//        } else {
//            // Handle photo picking from Camera
//            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//            
//        }
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgView?.contentMode = .ScaleAspectFit
            imgView?.image = pickedImage
            
            imgViewBack?.contentMode = .ScaleAspectFit
            //imgViewBack?.image = pickedImage
            
            //let view = UIView(frame: CGRectMake(0, 0, (imgViewBack?.frame.width)!, (imgViewBack?.frame.height)!))
            //view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
            //imgViewBack?.addSubview(view)
            
            //imgView?.backgroundColor = UIColor(patternImage:  (imgView?.image)!)
            
            UIGraphicsBeginImageContextWithOptions(imgView!.bounds.size, false, 0.0)
            imgView?.layer.renderInContext( UIGraphicsGetCurrentContext()! )
            mainImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            imgViewBack?.alpha = 0.5
            imgViewBack?.image = nil
            maskImage = nil
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first as UITouch? {
            previousPoint1 = touch.previousLocationInView(imgView)
            previousPoint2 = touch.previousLocationInView(imgView)
            lastPoint = touch.locationInView(imgView)
        }
    }
//
//    // Black spotty overlay on image
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first as UITouch? {
            let currentPoint = touch.locationInView(imgViewBack)
            previousPoint2 = previousPoint1
            previousPoint1 = touch.previousLocationInView(imgViewBack)
            
            UIGraphicsBeginImageContext((imgViewBack?.frame.size)!)
            let context = UIGraphicsGetCurrentContext()
            imgViewBack?.image?.drawInRect(CGRectMake(0, 0, (imgViewBack?.frame.size.width)!, (imgViewBack?.frame.size.height)!))
            
//            let mid1 = CGPointMake(((previousPoint1?.x)! + (previousPoint2?.x)!) * 0.5, ((previousPoint1?.y)! + (previousPoint2?.y)!) * 0.5)
//            let mid2 = CGPointMake((currentPoint.x + (previousPoint1?.x)!) * 0.5, (currentPoint.y + (previousPoint1?.y)!) * 0.5)
//            
//            CGContextMoveToPoint(context, mid1.x, mid1.y)
//            CGContextAddQuadCurveToPoint(context, (previousPoint1?.x)!, (previousPoint1?.y)!, mid2.x, mid2.y)
            
            CGContextSetLineCap(context, CGLineCap.Round)
            CGContextSetLineWidth(context, 20.0)
            CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0)
            
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, (lastPoint?.x)!, (lastPoint?.y)!)
            CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y)
            
            //CGContextSetBlendMode(context, CGBlendMode.Clear)
            
            CGContextStrokePath(context)
            
            imgViewBack?.image = UIGraphicsGetImageFromCurrentImageContext()
            //imgView?.alpha = 1.0
            UIGraphicsEndImageContext()
            
            lastPoint = currentPoint
        }
    }

//    // Shape layer with Bezier
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if let touch = touches.first as UITouch? {
//            let currentPoint = touch.locationInView(imgView)
//            let path = UIBezierPath()
//            path.moveToPoint(currentPoint)
//            path.addLineToPoint(previousPoint1!)
//            previousPoint1 = currentPoint
//            
//            let shapeLayer = CAShapeLayer()
//            shapeLayer.path = path.CGPath
//            shapeLayer.strokeColor = UIColor.blueColor().CGColor
//            shapeLayer.opacity = 0.5
//            shapeLayer.lineWidth = 10.0
//            shapeLayer.fillColor = UIColor.redColor().CGColor
//            
//            imgView?.layer.addSublayer( shapeLayer)
//        }
//    }
    
//    // Draw image brush
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if let touch = touches.first as UITouch? {
//            let currentPoint = touch.locationInView(imgView)
//            
//            UIGraphicsBeginImageContext((imgView?.frame.size)!)
//            let context = UIGraphicsGetCurrentContext()
//            imgView?.image?.drawInRect(CGRectMake(0, 0, (imgView?.frame.size.width)!, (imgView?.frame.size.height)!))
//            
//            let img = UIImage(named: "eraser2")
//            let location = CGPointMake(currentPoint.x - ((img?.size.width)!/2), currentPoint.y - ((img?.size.height)!/2))
//            img?.drawAtPoint(location, blendMode: CGBlendMode.Color, alpha: 1.0)
//            
//            
//            imgView?.image = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//        }
//    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        UIGraphicsBeginImageContext(imgView!.frame.size)
//        
//        imgView!.image?.drawInRect(CGRect(x: 0, y: 0, width: imgView!.frame.size.width, height: imgView!.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1.0)
//        
//        imgView!.image = UIGraphicsGetImageFromCurrentImageContext()
//        
//        UIGraphicsEndImageContext()
        
        if let touch = touches.first as UITouch? {
            let currentPoint = touch.locationInView(imgViewBack)
            
            UIGraphicsBeginImageContext((imgViewBack?.frame.size)!)
            let context = UIGraphicsGetCurrentContext()
            imgViewBack?.image?.drawInRect(CGRectMake(0, 0, (imgViewBack?.frame.size.width)!, (imgViewBack?.frame.size.height)!))
            
            CGContextSetLineCap(context, CGLineCap.Round)
            CGContextSetLineWidth(context, 20.0)
            CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0)
            
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, (lastPoint?.x)!, (lastPoint?.y)!)
            CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y)
            
            //CGContextSetBlendMode(context, CGBlendMode.Clear)
            
            CGContextStrokePath(context)
            
            imgViewBack?.image = UIGraphicsGetImageFromCurrentImageContext()
            //imgView?.alpha = 1.0
            UIGraphicsEndImageContext()
            
            let loc = touch.locationInView(imgView)
            let perX = loc.x / (mainImage?.size.width)!
            let perY = loc.y / (mainImage?.size.height)!
            //let imgPoint = CGPointMake((imgView?.image?.size.width)! * perX, (imgView?.image?.size.height)! * perY)
            let imgPoint = CGPointMake((mainImage?.size.width)! * perX * (mainImage?.scale)!, (mainImage?.size.height)! * perY * (mainImage?.scale)!)
            let color:UIColor = (mainImage?.getPixelColor(imgPoint))!
            colorView?.backgroundColor = color
            
            var texSize = (textureView?.frame.size)
            texSize?.height *= (mainImage?.scale)!
            texSize?.width *= (mainImage?.scale)!
            
            var areaPoint = imgPoint
            areaPoint.x -= ((texSize?.width)! / (mainImage?.scale)!)/2.0
            areaPoint.y -= ((texSize?.height)! / (mainImage?.scale)!)/2.0
            textureImage = (mainImage?.croppedImage(CGRect(origin: areaPoint, size: texSize!)))
            textureView?.image = textureImage
            lastPoint = currentPoint
        }
    }
}

