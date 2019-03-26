//
//  File.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 01/03/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation

open class KMVideoPlayerPlayPauseButton: UIButton {
  open var playImage = UIImage.playImage() {
    didSet {
      updateImage()
    }
  }
  open var pauseImage = UIImage.pauseImage() {
    didSet {
      updateImage()
    }
  }

  internal var isPlaying = false {
    didSet {
      updateImage()
    }
  }

  convenience init() {
    self.init(type: .custom)

    self.contentHorizontalAlignment = .center
  }

  override open var intrinsicContentSize: CGSize {
    return CGSize(width: 44, height: super.intrinsicContentSize.height)
  }

  func updateImage() {
    setImage(isPlaying ? pauseImage : playImage, for: .normal)
  }

}
