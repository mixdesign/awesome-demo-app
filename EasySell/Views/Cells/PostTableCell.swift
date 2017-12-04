//
// Created by Almas Adilbek on 12/3/17.
// Copyright (c) 2017 Good App. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class PostTableCell : UITableViewCell {

    static let cellHeight:CGFloat = 90

    private let titleLabel:UILabel = {
        return UILabel.base().font(.boldSystemFont(ofSize: 18)).color(.flatBlack).multiline(lines: 2, lineBreakMode: .byTruncatingTail)
    }()

    private let priceLabel:UILabel = {
        return UILabel.base().font(.systemFont(ofSize: 12)).color(.appGray)
    }()

    private let thumbnailView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }

    func setPost(_ post:Post) {
        titleLabel.text = post.title
        titleLabel.setLetter(spacing: -0.5)
        priceLabel.text = post.formattedPrice()

        if post.photos.count > 0 {
            self.thumbnailView.image = UIImage(data: post.photos.first!.photoData) // TODO: Optimize the performance
        } else {
            thumbnailView.image = nil
        }

    }

    private func configUI() {

        let selectionView = UIView()
        selectionView.backgroundColor = UIColor(hexString:"eeeeee")
        self.selectedBackgroundView = selectionView

        let padding:CGFloat = 15

        // Thumbnail
        self.contentView.addSubview(thumbnailView)
        thumbnailView.snp.makeConstraints { make in
            make.width.height.equalTo(PostTableCell.cellHeight - 2 * padding)
            make.top.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
        }

        // Title
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(padding)
            make.trailing.equalTo(thumbnailView.snp.leading).offset(-padding)
        }

        // Price
        self.contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
    }

}
