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

  // Spacing used between UI elements accross the player
  static let spacing: CGFloat = 8.0

  let stackView: UIStackView = {
    let view = UIStackView()
    view.axis = .horizontal
    view.distribution = .fill
    view.spacing = KMVideoPlayerControlView.spacing
    return view
  }()

  init() {
    super.init(frame: .zero)

    layer.backgroundColor = UIColor(white: 36.0/255.0, alpha: 1.0).cgColor
    layer.cornerRadius = 10.0

    addSubview(stackView)
    stackView.centerVertically()
    stackView.pin(to: [.left, .right], margin: KMVideoPlayerControlView.spacing)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
