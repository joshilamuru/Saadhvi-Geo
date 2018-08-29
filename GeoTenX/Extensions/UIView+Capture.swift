//
//  UIImageView+Capture.swift
//  GeoTenX
//
//  Created by saadhvi on 8/29/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func capture() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
}
