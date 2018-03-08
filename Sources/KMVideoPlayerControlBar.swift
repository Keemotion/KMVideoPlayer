//
//  KMVideoPlayerControlBar.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 27/02/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import UIKit

internal class KMVideoPlayerControlBar: KMVideoPlayerControlView {
  let playPauseButton = KMVideoPlayerPlayPauseButton()
  let currentTimeLabel = KMVideoPlayerControlBar.timingLabel()
  let durationLabel = KMVideoPlayerControlBar.timingLabel()
  let timeSlider = KMVideoPlayerSlider()

  private static func timingLabel() -> UILabel {
    let label = UILabel()
    label.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize,
                                                  weight: UIFont.Weight.regular)
    label.textColor = UIColor(white: 224.0/255.0, alpha: 1.0)
    return label
  }

  override init() {
    super.init()

    stackView.addArrangedSubview(playPauseButton)
    stackView.addArrangedSubview(currentTimeLabel)
    stackView.addArrangedSubview(timeSlider)
    stackView.addArrangedSubview(durationLabel)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIViewNoIntrinsicMetric, height: 32)
  }

}
