//
//  File.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 01/03/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation

internal class KMVideoPlayerPlayPauseButton: UIButton {
  private let playImage = UIImage.playImage()
  private let pauseImage = UIImage.pauseImage()

  public var isPlaying = false {
    didSet {
      setImage(isPlaying ? pauseImage : playImage, for: .normal)
    }
  }

  convenience init() {
    self.init(type: .custom)

    self.contentHorizontalAlignment = .center
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: 21, height: super.intrinsicContentSize.height)
  }

}
