//
//  KMVideoPlayerPlayPauseButton+Rx.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 01/03/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: KMVideoPlayerPlayPauseButton {
  var isPlaying: Binder<Bool> {
    return Binder(self.base) { (button, isPlaying) in
      button.isPlaying = isPlaying
    }
  }
}
