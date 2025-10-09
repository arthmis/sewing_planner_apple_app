//
//  UIImageExtension.swift
//  Sewing Planner
//
//  Created by Art on 10/9/25.
//

import Foundation
import UIKit

extension UIImage {
    static let maxDimension: Double = 1000
    
    func resizeImageTo(size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image {_ in}
    }
    
    // TODO write a test for this or resizeImageTo
    func scaleToAppImageMaxDimension() -> UIImage {
        let (newWidth, newHeight) = self.scaleDimensions(maxDimension: UIImage.maxDimension)
        return resizeImageTo(size: CGSize(width: newWidth, height: newHeight))
    }
    
    fileprivate func scaleDimensions(maxDimension: Double) -> (Double, Double) {
        if self.size.width >= self.size.height {
            if (self.size.width < maxDimension) {
                return (self.size.width, self.size.height)
            }
            
            let scale = maxDimension / self.size.width
            return (self.size.width * scale, self.size.height * scale)
        } else {
            if (self.size.height < maxDimension) {
                return (self.size.width, self.size.height)
            }
            
            let scale = maxDimension / self.size.height
            return (self.size.width * scale, self.size.height * scale)
        }
    }
}

