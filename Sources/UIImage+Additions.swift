//
//  UIImage+Additions.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 01/03/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation

extension UIImage {

  static func image(fromLayer layer: CALayer) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, layer.isOpaque, UIScreen.main.scale)

    defer {
      UIGraphicsEndImageContext()
    }

    guard let context = UIGraphicsGetCurrentContext() else {
      return nil
    }
    layer.render(in: context)

    return UIGraphicsGetImageFromCurrentImageContext()
  }

  static func smallThumbImage() -> UIImage? {
    let layer = CAShapeLayer()
    layer.isOpaque = false
    layer.frame = CGRect(x: 0, y: 0, width: 9, height: 9)
    layer.path = UIBezierPath(ovalIn: layer.frame).cgPath
    layer.fillColor = UIColor.white.cgColor

    return image(fromLayer: layer)
  }

  static func playImage() -> UIImage? {
    let layer = CAShapeLayer()
    layer.isOpaque = false
    layer.frame = CGRect(x: 0, y: 0, width: 11, height: 13)
    layer.fillColor = UIColor(white: 0.9, alpha: 1.0).cgColor

    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: 0))
    path.addLine(to: CGPoint(x: 11, y: 6.5))
    path.addLine(to: CGPoint(x: 0, y: 13))
    path.close()

    layer.path = path.cgPath

    return image(fromLayer: layer)
  }

  static func pauseImage() -> UIImage? {
    let layer = CAShapeLayer()
    layer.isOpaque = false
    layer.frame = CGRect(x: 0, y: 0, width: 11, height: 13)
    layer.fillColor = UIColor(white: 0.9, alpha: 1.0).cgColor

    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: 0))
    path.addLine(to: CGPoint(x: 4, y: 0))
    path.addLine(to: CGPoint(x: 4, y: 13))
    path.addLine(to: CGPoint(x: 0, y: 13))
    path.close()

    path.move(to: CGPoint(x: 7, y: 0))
    path.addLine(to: CGPoint(x: 13, y: 0))
    path.addLine(to: CGPoint(x: 13, y: 13))
    path.addLine(to: CGPoint(x: 7, y: 13))
    path.close()

    layer.path = path.cgPath

    return image(fromLayer: layer)
  }

}
