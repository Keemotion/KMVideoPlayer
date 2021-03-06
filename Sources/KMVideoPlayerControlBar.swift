//
//  KMVideoPlayerControlBar.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 27/02/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

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

  init() {
    super.init(axis: .horizontal)

    stackView.addArrangedSubview(playPauseButton)
    stackView.addArrangedSubview(currentTimeLabel)
    stackView.addArrangedSubview(timeSlider)
    stackView.addArrangedSubview(durationLabel)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  func bind(_ outputs: KMVideoPlayerViewModel.ControlBarOutputs) -> CompositeDisposable {
    return CompositeDisposable(disposables: [
      outputs.isPlaying
        .drive(playPauseButton.rx.isPlaying),
      outputs.currentTime
        .drive(currentTimeLabel.rx.text),
      outputs.currentProgress
        .drive(timeSlider.rx.value),
      outputs.maximumValue
        .drive(timeSlider.rx.maximumValue),
      outputs.duration
        .drive(durationLabel.rx.text)
    ])
  }

}
