//
//  DesignPostController.swift
//  Awesome Demo App
//
//  Created by Almas Adilbek on 12/1/17.
//  Copyright © 2017 GOOD/APP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DynamicColor
import SnapKit
import Fusuma
import SVProgressHUD
import RealmSwift

class DesignPostController: UIViewController {

    let viewModel = DesignPostViewModel()
    private let bag = DisposeBag()

    var post:Post? = nil

    fileprivate let postView = DesignPostView()
    private let urgentSwitch = TitleSwitchView()
    private let giveFreeSwitch = TitleSwitchView()
    private let previewSwitch = TitleSwitchView()

    private var actionButton:UIButton!

    fileprivate var isNew:Bool {
        return post == nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configUI()
        configEvents()
    }

    private func configEvents() {

        // Enable Preview switch only if there is at least one photo.
        postView.viewModel.hasAtLeastOnePhoto.asObservable().bind(to:previewSwitch.switchControl.rx.isEnabled).disposed(by: bag)

        // Enable create button if all required form fields filled.
        postView.viewModel.formValidated.asObservable().bind(to:actionButton.rx.isEnabled).disposed(by: bag)

        // If post selected from the list.
        if let post = post {
            postView.setPostTitle(post.title)
            postView.viewModel.price.value = "\(post.price)"

            urgentSwitch.switchControl.isOn = post.isUrgent
            giveFreeSwitch.switchControl.isOn = post.isGiveFree

            // TODO: Optimize the performance
            postView.viewModel.photos.value = post.photos.map { (photo: PostPhoto) -> UIImage in
                return UIImage(data: photo.photoData)!
            }
        }

        // Bind controls
        _ = previewSwitch.switchControl.rx.isOn.bind(to:postView.viewModel.isPreview).disposed(by: bag)
        _ = urgentSwitch.switchControl.rx.isOn.bind(to:postView.viewModel.isUrgent).disposed(by: bag)
        _ = giveFreeSwitch.switchControl.rx.isOn.bind(to:postView.viewModel.isGiveFree).disposed(by: bag)
    }

    // MARK: Actions

    @objc private func tapAction() {
        SVProgressHUD.show(withStatus: "Saving")
        viewModel.createPost(
                postId: post?.postId,
                title: postView.viewModel.postTitle.value,
                price: postView.viewModel.intPrice(),
                currency: postView.viewModel.currencySymbol,
                photos: postView.viewModel.photos.value,
                isUrgent: postView.viewModel.isUrgent.value,
                isGiveFree: postView.viewModel.isGiveFree.value
        ) { [weak self] error in

            if error == nil {
                SVProgressHUD.showSuccess(withStatus: "Saved!")
                self?.navigationController?.popViewController(animated: true)
            } else {
                SVProgressHUD.dismiss()
                UIHelper.alertError(message: error!.localizedDescription)
            }
        }
    }

    @objc private func tapBack() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: UI
    
    private func configUI() {
        self.view.backgroundColor = viewModel.noPhotoBackgroundColor

        let buttonHeight:CGFloat = 44

        // Back button
        let backButton = UIButton(type: .custom)
        backButton.addTarget(self, action: #selector(tapBack), for: .touchUpInside)
        backButton.setTitle("←".uppercased(), for: .normal)
        backButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        backButton.backgroundColor = UIColor.appBlue.darkened(amount: 0.1)
        self.view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(buttonHeight)
            make.leading.bottom.equalToSuperview()
        }

        // Pay Button
        actionButton = UIButton(type: .custom)
        actionButton.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        actionButton.setTitle((isNew ? "Create" : "Save").uppercased(), for: .normal)
        actionButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        actionButton.titleLabel?.setLetter(spacing: 1)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .disabled)
        actionButton.backgroundColor = .appBlue
        self.view.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.height.equalTo(buttonHeight)
            make.leading.equalTo(backButton.snp.trailing)
            make.trailing.bottom.equalToSuperview()
        }

        // Scroll View
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        self.view.addSubview(sv)
        sv.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(actionButton.snp.top)
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
        urgentSwitch.setTitle("Urgent".uppercased())
        contentView.addSubview(urgentSwitch)
        urgentSwitch.snp.makeConstraints { make in
            make.top.equalTo(postView.snp.bottom).offset(25)
            make.leading.equalTo(postView).offset(controlsPadding)
            make.bottom.equalToSuperview()
        }

        giveFreeSwitch.setTitle("Free".uppercased())
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

    deinit {
        print("DesignPostController deinit")
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
        var array = postView.viewModel.photos.value
        array.append(contentsOf: photos)
        postView.viewModel.photos.value = array
    }

}
