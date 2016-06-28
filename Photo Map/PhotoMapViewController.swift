//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import MapKit
import UIKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, LocationsViewControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var originalImage: UIImage?
    var editedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667), MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(sfRegion, animated: false)
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cameraClicked(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        dismissViewControllerAnimated(true, completion: {() -> Void in
            self.performSegueWithIdentifier("tagSegue", sender: self)
        })
    }

    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber, name: String) {
        self.navigationController?.popToViewController(self, animated: false)
        let coords = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
        let annotation = PhotoAnnotation()
        annotation.coordinate = coords
        annotation.title = name
        mapView.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "myAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if(annotationView == nil) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height: 50))
            let button = UIButton(type: UIButtonType.DetailDisclosure)
            annotationView!.rightCalloutAccessoryView = button
        }
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
        imageView.image = editedImage
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier("fullImageSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "tagSegue") {
            let vc = segue.destinationViewController as! LocationsViewController
            vc.delegate = self
        }
        if (segue.identifier == "fullImageSegue") {
            let vc = segue.destinationViewController as! FullImageViewController
            vc.passedImage = originalImage
        }
    }
}
