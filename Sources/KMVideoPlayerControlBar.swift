//
//  KMVideoPlayerControlBar.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 27/02/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import UIKit

internal class KMVideoPlayerControlBar: UIView {
  let playPauseButton = KMVideoPlayerPlayPauseButton()
  let currentTimeLabel = UILabel()
  let durationLabel = UILabel()
  let timeSlider = KMVideoPlayerSlider()

  override init(frame: CGRect) {
    super.init(frame: frame)

    layer.backgroundColor = UIColor(white: 36.0/255.0, alpha: 1.0).cgColor
    layer.cornerRadius = 10.0

    addSubview(playPauseButton)

    playPauseButton.translatesAutoresizingMaskIntoConstraints = false
    playPauseButton.widthAnchor.constraint(equalToConstant: 21.0).isActive = true
    playPauseButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0).isActive = true
    playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

    addSubview(durationLabel)

    durationLabel.translatesAutoresizingMaskIntoConstraints = false
    durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0).isActive = true
    durationLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize,
                                                          weight: UIFont.Weight.regular)
    durationLabel.textColor = UIColor(white: 224.0/255.0, alpha: 1.0)

    addSubview(currentTimeLabel)

    currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
    currentTimeLabel.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 8.0).isActive = true
    currentTimeLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    currentTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize,
                                                             weight: UIFont.Weight.regular)
    currentTimeLabel.textColor = UIColor(white: 224.0/255.0, alpha: 1.0)

    addSubview(timeSlider)

    timeSlider.translatesAutoresizingMaskIntoConstraints = false
    timeSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 8.0).isActive = true
    timeSlider.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -8.0).isActive = true
    timeSlider.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

}
