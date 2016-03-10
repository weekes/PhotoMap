//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var originalImage: UIImage?
    var targetImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
            MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
        
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressButton(sender: UIButton) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)

    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "fullImageSegue" {
            let fullImageVC = segue.destinationViewController as! FullImageViewController
            fullImageVC.imageFromButton = originalImage
        } else if segue.identifier == "tagSegue" {
            let locationsVC = segue.destinationViewController as! LocationsViewController
            locationsVC.delegate = self
        }
        
    }
    
    func seeFullView(sender: PhotoButton) {
        targetImage = sender.photo!
        self.performSegueWithIdentifier("fullImageSegue", sender: self)
    }

}

extension PhotoMapViewController:UIImagePickerControllerDelegate {

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Do something with the images (based on your use case)
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: { (originalImage) -> () in
            self.performSegueWithIdentifier("tagSegue", sender: self)
        })
    }

}

extension PhotoMapViewController : LocationsViewControllerDelegate {
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
        let coordinate = CLLocationCoordinate2DMake(Double(latitude), Double(longitude))
        
        let annotation = PhotoAnnotation()
        annotation.coordinate = coordinate
        
        let resizeRenderImageView = UIImageView(frame: CGRectMake(0, 0, 45, 45))
        resizeRenderImageView.layer.borderColor = UIColor.whiteColor().CGColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeRenderImageView.image = originalImage
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        var thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        annotation.photo = thumbnail
        mapView.addAnnotation(annotation)
        
        self.navigationController?.popToViewController(self, animated: true)
    }
}

extension PhotoMapViewController:UINavigationControllerDelegate {
    
}

extension PhotoMapViewController:MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        if (annotationView == nil) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))

            let imageView = annotationView!.leftCalloutAccessoryView as! UIImageView
            imageView.image = (annotation as! PhotoAnnotation).photo
            
            let annotationButton = PhotoButton(type: UIButtonType.DetailDisclosure)
            annotationButton.photo = imageView.image
            annotationButton.addTarget(self, action: "seeFullView:", forControlEvents: UIControlEvents.TouchUpInside)
            annotationButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            annotationView!.rightCalloutAccessoryView = annotationButton
        }
        
        
        
        return annotationView
    }
}
