//
//  KMVideoPlayerSlider.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 28/02/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import UIKit

internal class KMVideoPlayerSlider: UISlider {

  convenience init() {
    self.init(frame: .zero)

    self.setThumbImage(UIImage.smallThumbImage(), for: .normal)
  }

  override func trackRect(forBounds bounds: CGRect) -> CGRect {
    var bounds = super.trackRect(forBounds: bounds)
    bounds.origin.y -= (5.0 - bounds.size.height) / 2.0
    bounds.size.height = 5.0
    return bounds
  }

}
