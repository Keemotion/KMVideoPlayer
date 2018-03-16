//
//  KMVideoPlayerFullscreenButton.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 08/03/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation

internal class KMVideoPlayerFullscreenButton: UIButton {
  private let enterFullscreenImage = UIImage.enterFullscreenImage()
  private let leaveFullscreenImage = UIImage.leaveFullscreenImage()

  public var isFullscreen = false {
    didSet {
      setImage(isFullscreen ? leaveFullscreenImage : enterFullscreenImage, for: .normal)
    }
  }

  convenience init() {
    self.init(type: .custom)

    self.contentHorizontalAlignment = .center
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: 44, height: super.intrinsicContentSize.height)
  }

}
