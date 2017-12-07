//
// Created by Almas Adilbek on 12/1/17.
// Copyright (c) 2017 GOOD/APP. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class PostPhotoCollectionCell : UICollectionViewCell {

    private let imageView = UIImageView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    func setPhoto(_ image:UIImage?) {
        imageView.image = image
    }

    private func configUI() {
        self.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /*let fader = UIView()
        fader.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        contentView.addSubview(fader)
        fader.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }*/
    }

}