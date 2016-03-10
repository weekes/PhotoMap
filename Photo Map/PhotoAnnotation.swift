//
//  PhotoAnnotation.swift
//  Photo Map
//
//  Created by Marcel Weekes on 3/9/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import MapKit

class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    var title: String? {
        return "\(coordinate.latitude)"
    }
}
