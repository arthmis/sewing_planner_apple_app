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
    let newSize = scaleDimensions(maxDimension: UIImage.maxDimension)
    return resizeImageTo(size: newSize)
  }

  func scaleDimensions(maxDimension: Double) -> CGSize {
    if size.width >= size.height {
      if size.width < maxDimension {
        return CGSize(width: size.width, height: size.height)
      }

      let scale = maxDimension / size.width
      return CGSize(width: size.width * scale, height: size.height * scale)
    } else {
      if size.height < maxDimension {
        return CGSize(width: size.width, height: size.height)
      }

      let scale = maxDimension / size.height
      return CGSize(width: size.width * scale, height: size.height * scale)
    }
  }
}
