//
//  KMVideoPlayerFullscreenButton+Rx.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 08/03/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: KMVideoPlayerFullscreenButton {
  var isFullscreen: Binder<Bool> {
    return Binder(self.base) { (button, isFullscreen) in
      button.isFullscreen = isFullscreen
    }
  }
}
