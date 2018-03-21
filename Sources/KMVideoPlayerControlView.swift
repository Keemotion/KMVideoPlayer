//
//  KMVideoPlayerControlView.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 08/03/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import UIKit

internal class KMVideoPlayerControlView: UIView {

  typealias Axis = UILayoutConstraintAxis

  // Spacing used between UI elements accross the player
  static let spacing: CGFloat = 8.0

  let stackView: UIStackView = {
    let view = UIStackView()
    view.distribution = .fill
    view.spacing = KMVideoPlayerControlView.spacing
    return view
  }()

  init(axis: Axis) {
    super.init(frame: .zero)

    layer.backgroundColor = UIColor(white: 36.0/255.0, alpha: 0.8).cgColor
    layer.cornerRadius = 8.0

    addSubview(stackView)
    stackView.axis = axis
    stackView.pin(to: [.top, .bottom], margin: axis == .vertical ? KMVideoPlayerControlView.spacing : 0.0)
    stackView.pin(to: [.left, .right], margin: KMVideoPlayerControlView.spacing)
    if axis == .horizontal {
      stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 32.0).isActive = true
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
