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
    @IBOutlet weak var imgView: UIImageView?    // mainImage Container
    @IBOutlet weak var imgViewBack: UIImageView?    // Mask container, on top of mainImage
    @IBOutlet weak var colorView: UIView?       // Dummy pixel color on last touch
    @IBOutlet weak var textureView: UIImageView? // Texture view showing texture which generates textureImage
    
    fileprivate var lastPoint: CGPoint?
    
    fileprivate var mainImage:UIImage?      // The image on which mask to be applied
    fileprivate var maskImage:UIImage?      // The mask which is applied to erase content on mainImage
    fileprivate var textureImage: UIImage?  // The texture which replaces mask on mainImage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Loading Default image, temporarily
        mainImage = UIImage(named: "eraser.png")
        imgView?.image = mainImage
        imgView?.contentMode = .scaleAspectFit
        imgViewBack?.contentMode = .scaleAspectFit
        
        imgViewBack?.alpha = 0.5    // Making mask view a bit transparent
        
        // Setting up bottom views
        colorView?.layer.borderWidth = 2.0
        colorView?.layer.borderColor = UIColor.black.cgColor
        colorView?.layer.cornerRadius = 10.0
        
        textureView?.layer.borderWidth = 2.0
        textureView?.layer.borderColor = UIColor.black.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createTiledImage(inputImage:UIImage, size: CGSize) -> UIImage {
        let filter = CIFilter(name: "CIAffineTile")
        filter!.setValue(CIImage(image: inputImage), forKey: "inputImage")
        let outputImage = filter?.outputImage?.applyingFilter("CIAffineTile", withInputParameters: nil).cropping(to: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let ciCtx = CIContext(options: nil)
        let cgimg = ciCtx.createCGImage(outputImage!, from: (outputImage?.extent)!)
        return UIImage(cgImage: cgimg!)
    }
    
    func maskImage(_ image: UIImage, maskImage:UIImage?) -> UIImage {
        guard maskImage != nil else {
            return image
        }
        
        let maskRef = maskImage!.cgImage
        let mask = CGImage(maskWidth: (maskRef?.width)!, height: (maskRef?.height)!, bitsPerComponent: (maskRef?.bitsPerComponent)!, bitsPerPixel: (maskRef?.bitsPerPixel)!, bytesPerRow: (maskRef?.bytesPerRow)!, provider: (maskRef?.dataProvider!)!, decode: nil, shouldInterpolate: false)
        let masked = image.cgImage?.masking(mask!)
        
        guard masked != nil else {
            return image
        }
        
        return UIImage(cgImage: masked!)
    }

    
    @IBAction func maskImageClicked(_ sender: AnyObject?) {
        imgViewBack?.alpha = 1.0        // Setting mask view fully visible to make solid mask
        
        maskImage = prepareImage(imageView: imgViewBack!)   // Preparing mask from the mask imageview itself
        
        // Calculate texture image size same as the main image with proper resolution
        var targetImgSize = (mainImage?.size)!
        targetImgSize.width *= UIScreen.main.scale
        targetImgSize.height *= UIScreen.main.scale
        
        // Create tiled image from the texture
        let textureImg = createTiledImage(inputImage: textureImage!, size: targetImgSize)
        
        // Mask and Replace with texture
        imgView?.image = mainImage?.maskAndReplaceImage(maskImage, textureImage: textureImg)
        imgViewBack?.alpha = 0.5        // Once mask image is create, set opacity again
        imgViewBack?.image = nil
    }
    
    @IBAction func replaceImage(_ sender: AnyObject?) {
//        imgViewBack?.alpha = 1.0        // Setting mask view fully visible to make solid mask
//        
//        maskImage = prepareImage(imageView: imgViewBack!)   // Preparing mask from the mask imageview itself
//        
//        imgView?.image = maskImage
//        imgViewBack?.alpha = 0.5        // Once mask image is create, set opacity again
//        imgViewBack?.image = nil
    }

    @IBAction func loadGallery(_ sender: AnyObject?) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func prepareImage(imageView: UIImageView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0.0)
        imageView.layer.render( in: UIGraphicsGetCurrentContext()! )
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imgView?.image = pickedImage    // Load image into main imageview
            mainImage = prepareImage(imageView: imgView!)   // Create a device size image from imageview itself
            
            // Set mask imageview to be transparent and clear mask image
            imgViewBack?.alpha = 0.5
            imgViewBack?.image = nil
            maskImage = nil
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func drawStrokeOnImageView(_ imageView: UIImageView?, fromPoint: CGPoint, toPoint: CGPoint, withColor strokeColor: UIColor, andSize brushSize: CGFloat ) {
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1
        strokeColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        UIGraphicsBeginImageContext((imageView?.frame.size)!)
        
        let context = UIGraphicsGetCurrentContext()
        imageView?.image?.draw(in: CGRect(x: 0, y: 0, width: (imageView?.frame.size.width)!, height: (imageView?.frame.size.height)!))
        
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushSize)
        context?.setStrokeColor(red: r, green: g, blue: b, alpha: a)
        
        context?.beginPath()
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        
        //CGContextSetBlendMode(context, CGBlendMode.Clear)
        context?.strokePath()
        
        imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch? {
            lastPoint = touch.location(in: imgView)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch? {
            let currentPoint = touch.location(in: imgViewBack)
            
            // Drawing the stroke as mask into mask imageview
            drawStrokeOnImageView(imgViewBack, fromPoint: lastPoint!, toPoint: currentPoint, withColor: UIColor.black, andSize: 20.0)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch? {
            let currentPoint = touch.location(in: imgViewBack)
            
            // Drawing the stroke as mask into mask imageview
            drawStrokeOnImageView(imgViewBack, fromPoint: lastPoint!, toPoint: currentPoint, withColor: UIColor.black, andSize: 20.0)   // Assign you own mask color and brush size
            
            // Get Pixel color on last touch
            let loc = touch.location(in: imgView)
            let perX = loc.x / (mainImage?.size.width)!
            let perY = loc.y / (mainImage?.size.height)!
            //let imgPoint = CGPointMake((imgView?.image?.size.width)! * perX, (imgView?.image?.size.height)! * perY)
            let imgPoint = CGPoint(x: (mainImage?.size.width)! * perX * (mainImage?.scale)!, y: (mainImage?.size.height)! * perY * (mainImage?.scale)!)
            let color:UIColor = (mainImage?.getPixelColor(imgPoint))!
            colorView?.backgroundColor = color
            
            // Get tile at last touch
            var texSize = CGSize(width: (textureView?.frame.size.width)!, height: (textureView?.frame.size.height)!) // Assign your own texture size as 5x5, 20x20; current is 40x40
            texSize.height *= (mainImage?.scale)!
            texSize.width *= (mainImage?.scale)!
            
            var areaPoint = imgPoint
            areaPoint.x -= (texSize.width / (mainImage?.scale)!)/2.0
            areaPoint.y -= (texSize.height / (mainImage?.scale)!)/2.0
            textureImage = (mainImage?.croppedImage(CGRect(origin: areaPoint, size: texSize)))
            textureView?.image = textureImage
            lastPoint = currentPoint
        }
    }
}

