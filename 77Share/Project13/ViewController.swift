
//
//  ViewController.swift
//  Project25
//
//  Created by Shelby and Laura on 11/12/2015.
//  Copyright (c) 2015 Shelby Larson and Laura Hailey. All rights reserved.
//

import MultipeerConnectivity
import Social
import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCBrowserViewControllerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensity: UISlider!
    
    var images = [UIImage]()
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    var filter: CIFilter!
    var beginImage: CIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "77Share"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "importPicture")
  
        context = CIContext(options: nil)
        currentFilter = CIFilter(name: "CIVignetteEffect")

        self.logAllFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageView", forIndexPath: indexPath) as! UICollectionViewCell
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
    func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
        images.insert(newImage, atIndex: 0)
        
        currentImage = newImage
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys() as! [NSString]
        
        if contains(inputKeys, kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey) }
        if contains(inputKeys, kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey) }
        if contains(inputKeys, kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey) }
        if contains(inputKeys, kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }
        
        if contains(inputKeys, kCIInputEVKey) { currentFilter.setValue(intensity.value, forKey: kCIInputEVKey) }
        if contains(inputKeys, kCIInputAngleKey) { currentFilter.setValue(intensity.value, forKey: kCIInputAngleKey) }
        if contains(inputKeys, kCIInputSaturationKey) { currentFilter.setValue(intensity.value, forKey: kCIInputSaturationKey) }
        if contains(inputKeys, kCIInputSharpnessKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputSharpnessKey) }
        
        let cgimg = context.createCGImage(currentFilter.outputImage, fromRect: currentFilter.outputImage.extent())
        let processedImage = UIImage(CGImage: cgimg)
        
        imageView.image = processedImage
    }
    
    @IBAction func intensityChanged(sender: AnyObject) {
        applyProcessing()
    }
    
    func setFilters(action: UIAlertAction!) {
        currentFilter = CIFilter(name: action.title)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    func logAllFilters() {
        
        let properties = CIFilter.filterNamesInCategory(
            kCICategoryBuiltIn)
        println(properties)
        
        for filterName: AnyObject in properties {
            let fltr = CIFilter(name:filterName as! String)
            println(fltr.attributes())
        }
        
    }
    
    @IBAction func changeFilter(sender: AnyObject) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .ActionSheet)
        
        ac.addAction(UIAlertAction(title: "CIVignetteEffect", style: .Default, handler: setFilters))
        ac.addAction(UIAlertAction(title: "CIColorMonochrome", style: .Default, handler: setFilters))
        ac.addAction(UIAlertAction(title: "CIExposureAdjust", style: .Default, handler: setFilters))
        ac.addAction(UIAlertAction(title: "CISharpenLuminance", style: .Default, handler: setFilters))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .Default, handler: setFilters))
        ac.addAction(UIAlertAction(title: "CIHueAdjust", style: .Default, handler: setFilters))
        ac.addAction(UIAlertAction(title: "CIColorControls", style: .Default, handler: setFilters))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)

        self.logAllFilters()
    }
    
    @IBAction func save(sender: AnyObject) {
        let vc = UIActivityViewController(activityItems: [self.imageView.image!], applicationActivities: [])
        presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    

    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

