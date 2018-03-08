//
//  UIView+AutoLayout.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 08/03/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation

internal extension UIView {

  enum Edge {
    case top
    case bottom
    case left
    case right
  }

  func pin(to edge: Edge, margin: CGFloat = 0.0) {
    pin(to: [edge], margin: margin)
  }

  func pin(to edges: Set<Edge>, margin: CGFloat = 0.0) {
    guard let superview = superview else {
      fatalError("Can't apply layout when there is no superview")
    }
    translatesAutoresizingMaskIntoConstraints = false
    for edge in edges {
      switch edge {
      case .top:
        topAnchor.constraint(equalTo: superview.topAnchor, constant: margin).isActive = true
      case .bottom:
        bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -margin).isActive = true
      case .left:
        leftAnchor.constraint(equalTo: superview.leftAnchor, constant: margin).isActive = true
      case .right:
        rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -margin).isActive = true
      }
    }
  }

  func fit(verticalMargin: CGFloat = 0.0, horizontalMargin: CGFloat = 0.0) {
    pin(to: [.top, .bottom], margin: verticalMargin)
    pin(to: [.left, .right], margin: horizontalMargin)
  }

  func centerVertically() {
    guard let superview = superview else { return }
    translatesAutoresizingMaskIntoConstraints = false
    centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
  }

  func center() {
    guard let superview = superview else { return }
    translatesAutoresizingMaskIntoConstraints = false
    centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
    centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
  }

}
