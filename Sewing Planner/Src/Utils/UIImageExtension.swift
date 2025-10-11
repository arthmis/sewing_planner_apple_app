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
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    // TODO: write a test for this or resizeImageTo
    func scaleToAppImageMaxDimension() -> UIImage {
        let newSize = self.scaleDimensions(maxDimension: UIImage.maxDimension)
        return self.resizeImageTo(size: newSize)
    }
    
    func scaleDimensions(maxDimension: Double) -> CGSize {
        if self.size.width >= self.size.height {
            if self.size.width < maxDimension {
                return CGSize(width: self.size.width, height: self.size.height)
            }
            
            let scale = maxDimension / self.size.width
            return CGSize(width: self.size.width * scale, height: self.size.height * scale)
        } else {
            if self.size.height < maxDimension {
                return CGSize(width: self.size.width, height: self.size.height)
            }
            
            let scale = maxDimension / self.size.height
            return CGSize(width: self.size.width * scale, height: self.size.height * scale)
        }
    }
}
