//
//  Objects.swift
//  mickey
//
//  Created by Varun Iyer on 5/12/19.
//  Copyright © 2019 Michelle Friedman. All rights reserved.
//

import Foundation
import UIKit

class Monument: NSObject {
    var name: String!
    var artist: String!
    var thumbnail: UIImageView!
    var latitude: Double!
    var longitude: Double!
    var photos: [UIImage]!
}

class User: NSObject {
    var firstName: String = ""
    var lastName: String = ""
    
    var latitude: Double = 0
    var longitude: Double = 0
    
    var imageView: UIImageView!
}
