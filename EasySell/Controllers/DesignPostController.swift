//
//  DesignPostController.swift
//  EasySell
//
//  Created by Almas Adilbek on 12/1/17.
//  Copyright © 2017 Good App. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DynamicColor
import SnapKit
import Fusuma

class DesignPostController: UIViewController {

    private let viewModel = DesignPostViewModel()
    private let bag = DisposeBag()

    fileprivate let postView = DesignPostView()
    private let urgentSwitch = TitleSwitchView()
    private let giveFreeSwitch = TitleSwitchView()
    private let previewSwitch = TitleSwitchView()


    override func viewDidLoad() {
        super.viewDidLoad()

        configUI()
        configEvents()
    }

    private func configEvents() {
        previewSwitch.switchControl.rx.isOn.bind(to:postView.viewModel.isPreview)

        urgentSwitch.switchControl.rx.isOn.bind(to:postView.viewModel.isUrgent)
        giveFreeSwitch.switchControl.rx.isOn.bind(to:postView.viewModel.isGiveFree)

        postView.viewModel.hasAtLeastOnePhoto.asObservable().distinctUntilChanged().subscribe(onNext: { [weak self] (hasPhoto:Bool) in
            print("hasPhoto:\(hasPhoto)")
            self?.previewSwitch.switchControl.isEnabled = hasPhoto
        }).addDisposableTo(bag)
    }

    // MARK: Actions

    @objc private func tapPay() {

    }

    // MARK: UI


    private func configUI() {
        self.view.backgroundColor = viewModel.noPhotoBackgroundColor

        // Pay Button
        let payButton = UIButton(type: .custom)
        payButton.addTarget(self, action: #selector(tapPay), for: .touchUpInside)
        payButton.setTitle("Создать ✓".uppercased(), for: .normal)
        payButton.titleLabel?.font = .boldSystemFont(ofSize: 13)
        payButton.titleLabel?.setLetter(spacing: 1)
        payButton.backgroundColor = .appBlue
        self.view.addSubview(payButton)
        payButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // Scroll View
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        self.view.addSubview(sv)
        sv.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(payButton.snp.top)
        }

        let contentView = UIView()
        sv.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(self.view)
            make.edges.equalToSuperview()
        }

        // Title
        let titleLabel = UILabel.base().color(.flatBlack).font(.boldSystemFont(ofSize: 26)).text("Create & Sell")
        titleLabel.setLetter(spacing: -1)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(20)
        }

        // Post
        postView.delegate = self
        contentView.addSubview(postView)
        postView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(postView.viewModel.margin)
            make.trailing.equalToSuperview().offset(-postView.viewModel.margin)
            make.height.equalTo(postView.snp.width)
        }

        // Controls
        let controlsPadding = 5
        urgentSwitch.setTitle("Срочно".uppercased())
        contentView.addSubview(urgentSwitch)
        urgentSwitch.snp.makeConstraints { make in
            make.top.equalTo(postView.snp.bottom).offset(25)
            make.leading.equalTo(postView).offset(controlsPadding)
            make.bottom.equalToSuperview()
        }

        giveFreeSwitch.setTitle("Отдам даром".uppercased())
        contentView.addSubview(giveFreeSwitch)
        giveFreeSwitch.snp.makeConstraints { make in
            make.top.equalTo(urgentSwitch)
            make.leading.equalTo(urgentSwitch.snp.trailing).offset(20)
        }

        previewSwitch.setTitle("Preview".uppercased())
        previewSwitch.switchControl.onTintColor = .appBlue
        contentView.addSubview(previewSwitch)
        previewSwitch.snp.makeConstraints { make in
            make.top.equalTo(urgentSwitch)
            make.trailing.equalTo(postView.snp.trailing).offset(-controlsPadding)
        }
    }

}

// MARK: PostView

extension DesignPostController : DesignPostViewDelegate {

    func designPostViewAddPhotoTapped() {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.cropHeightRatio = 1.0
        fusuma.allowMultipleSelection = true
        self.present(fusuma, animated: true)
    }

}

// MARK: Fusuma (Take photo, choose photo from photo gallery)

extension DesignPostController : FusumaDelegate {
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        photosSelected(photos: [image])
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        photosSelected(photos: images)
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        print("Creating ads with video content is not available")
    }
    
    func fusumaCameraRollUnauthorized() {
        //
    }

    // MARK: Helper

    private func photosSelected(photos:[UIImage]) {
        postView.viewModel.photos.value.append(contentsOf: photos)
    }

}
