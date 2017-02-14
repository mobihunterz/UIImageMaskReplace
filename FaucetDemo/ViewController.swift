//
//  ViewController.swift
//  FaucetDemo
//
//  Created by Paresh Thakor on 13/02/17.
//  Copyright © 2017 Paresh Thakor. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imgView: UIImageView?
    @IBOutlet weak var imgViewBack: UIImageView?
    @IBOutlet weak var maskView: UIView?
    
    private var previousPoint1:CGPoint?
    private var previousPoint2:CGPoint?
    private var lastPoint: CGPoint?
    private var isErase: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imgView?.image = UIImage(named: "eraser.png")
        imgView?.contentMode = .ScaleAspectFit
        
        imgViewBack?.opaque = false
        imgViewBack?.alpha = 0.4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            imgViewBack?.image = nil
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
            CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.5)
            
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
}

