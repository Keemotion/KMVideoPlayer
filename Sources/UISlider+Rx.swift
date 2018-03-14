//
//  UISlider+Rx.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 28/02/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UISlider {
  var maximumValue: Binder<Float> {
    return Binder(self.base) { (slider, maximumValue) in
      slider.maximumValue = maximumValue
    }
  }
}
