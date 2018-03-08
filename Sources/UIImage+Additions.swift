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

  static func enterFullscreenImage() -> UIImage? {
    let layer = CAShapeLayer()
    layer.isOpaque = false
    layer.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
    layer.fillColor = UIColor(white: 0.8, alpha: 1.0).cgColor
    layer.strokeColor = layer.fillColor
    layer.lineWidth = 2.0
    layer.lineCap = kCALineCapRound
    layer.lineJoin = kCALineJoinRound

    let path = UIBezierPath()
    path.move(to: CGPoint(x: 14, y: 1))
    path.addLine(to: CGPoint(x: 10, y: 1))
    path.addLine(to: CGPoint(x: 14, y: 1))
    path.addLine(to: CGPoint(x: 9, y: 6))
    path.addLine(to: CGPoint(x: 14, y: 1))
    path.addLine(to: CGPoint(x: 14, y: 5))
    path.close()

    path.move(to: CGPoint(x: 1, y: 14))
    path.addLine(to: CGPoint(x: 5, y: 14))
    path.addLine(to: CGPoint(x: 1, y: 14))
    path.addLine(to: CGPoint(x: 6, y: 9))
    path.addLine(to: CGPoint(x: 1, y: 14))
    path.addLine(to: CGPoint(x: 1, y: 10))
    path.close()

    layer.path = path.cgPath

    return image(fromLayer: layer)
  }

  static func leaveFullscreenImage() -> UIImage? {
    let layer = CAShapeLayer()
    layer.isOpaque = false
    layer.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
    layer.fillColor = UIColor(white: 0.8, alpha: 1.0).cgColor
    layer.strokeColor = layer.fillColor
    layer.lineWidth = 2.0
    layer.lineCap = kCALineCapRound
    layer.lineJoin = kCALineJoinRound

    let path = UIBezierPath()
    path.move(to: CGPoint(x: 9, y: 6))
    path.addLine(to: CGPoint(x: 9, y: 2))
    path.addLine(to: CGPoint(x: 9, y: 6))
    path.addLine(to: CGPoint(x: 14, y: 1))
    path.addLine(to: CGPoint(x: 9, y: 6))
    path.addLine(to: CGPoint(x: 13, y: 6))
    path.close()

    path.move(to: CGPoint(x: 6, y: 9))
    path.addLine(to: CGPoint(x: 2, y: 9))
    path.addLine(to: CGPoint(x: 6, y: 9))
    path.addLine(to: CGPoint(x: 1, y: 14))
    path.addLine(to: CGPoint(x: 6, y: 9))
    path.addLine(to: CGPoint(x: 6, y: 13))
    path.close()

    layer.path = path.cgPath

    return image(fromLayer: layer)
  }

}
