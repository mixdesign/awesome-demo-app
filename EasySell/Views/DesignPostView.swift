//
// Created by Almas Adilbek on 12/1/17.
// Copyright (c) 2017 Good App. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import CHIPageControl
import GrowingTextView

final class DesignPostView : UIView {

    let viewModel = DesignPostViewViewModel()

    private let cv:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets.zero

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.register(PostPhotoCollectionCell.self, forCellWithReuseIdentifier: "photoCollectionCell")

        return view
    }()

    private let faderView:UIImageView = {
        return UIImageView(image: UIImage(named: "PostFader"))
    }()

    private let addFirstPhotoButton:IconTitleButton = {
        let button = IconTitleButton(iconName: "icon-addphoto-plus", title: "Добавить фото".uppercased())
        button.control.addTarget(self, action: #selector(tapAddPhoto), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private let addNextPhotoButton:UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(tapAddPhoto), for: .touchUpInside)
        button.setImage(UIImage(named: "add-photo-button"), for: .normal)
        button.showsTouchWhenHighlighted = true
        button.isHidden = true
        return button
    }()

    private let titleTextView:GrowingTextView = {
        let field = GrowingTextView()
        field.backgroundColor = .clear
        field.font = .systemFont(ofSize: 20)
        field.textColor = .white
        field.autocorrectionType = .no
        field.keyboardAppearance = .dark
        field.showsHorizontalScrollIndicator = false
        field.showsVerticalScrollIndicator = false
        field.placeHolder = "Enter the title"
        field.placeHolderColor = .white
        field.trimWhiteSpaceWhenEndEditing = false
        field.minHeight = 40
        return field
    }()

    fileprivate var titleTextViewHeightConstraint:ConstraintMakerEditable!

    private let priceTextField:GrowingTextView = {
        let field = GrowingTextView()
        field.backgroundColor = .clear
        field.font = .boldSystemFont(ofSize: 22)
        field.textColor = .white
        field.autocorrectionType = .no
        field.keyboardAppearance = .dark
        field.showsHorizontalScrollIndicator = false
        field.showsVerticalScrollIndicator = false
        field.placeHolder = "0 ₸"
        field.placeHolderColor = .white
        field.trimWhiteSpaceWhenEndEditing = false
        field.minHeight = 40
        field.maxLength = 15
        field.keyboardType = .numberPad
        return field
    }()

    fileprivate let pageControl = CHIPageControlChimayo()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }

    init() {
        super.init(frame:.zero)
        initView()
    }

    private func initView() {
        configUI()
        configEvents()
    }

    private func configEvents() {
        addFirstPhotoButton.isHidden = true // TODO: For testing
    }

    // MARK: Actions

    @objc private func tapAddPhoto() {
        print("tapAddPhoto")
    }

    // MARK: UI

    private func configUI() {

        // Container view
        let padding = 11

        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        self.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Collection View
        containerView.addSubview(cv)
        cv.delegate = self
        cv.dataSource = self
        cv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Set collection view layout item size.
        let width = ScreenSize.SCREEN_WIDTH - 2 * viewModel.margin
        (cv.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: width, height: width)

        // Fader
        containerView.addSubview(faderView)
        faderView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.8)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // Controls ---

        containerView.addSubview(addFirstPhotoButton)
        addFirstPhotoButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        containerView.addSubview(addNextPhotoButton)
        addNextPhotoButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
        }

        // Page control
        pageControl.numberOfPages = 3
        pageControl.tintColor = UIColor.appGray
        pageControl.inactiveTransparency = 0.2
        pageControl.currentPageTintColor = .appBlueLight
        pageControl.radius = 3
        containerView.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(padding)
            make.centerX.equalToSuperview()
        }

        // Input fields
        let fieldsMargin = 15

        containerView.addSubview(titleTextView)
        containerView.addSubview(priceTextField)

        priceTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(fieldsMargin)
            make.bottom.equalToSuperview().offset(-10)
            make.trailing.equalToSuperview().offset(-fieldsMargin)
            make.height.equalTo(40)
        }

        titleTextView.delegate = self
        titleTextView.maxLength = viewModel.titleFieldMaxLength
        titleTextView.snp.makeConstraints { make in
            make.leading.equalTo(priceTextField)
            make.bottom.equalTo(priceTextField.snp.top).offset(5)
            make.trailing.equalToSuperview().offset(-20)
            titleTextViewHeightConstraint = make.height.equalTo(40)
        }
    }

}

// MARK: UITextView

extension DesignPostView : GrowingTextViewDelegate {

    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        titleTextViewHeightConstraint.constraint.update(offset: height)
//        UIView.animate(withDuration: 0.45) { () -> Void in
//            textView.layoutIfNeeded()
//        }
    }

}

// MARK: CollectionView

extension DesignPostView : UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {

    // MARK: UIScrollView

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let total = scrollView.contentSize.width - scrollView.bounds.width
        let offset = scrollView.contentOffset.x
        pageControl.progress = Double(offset / total) * Double(pageControl.numberOfPages - 1)
    }

    // MARK: CollectionView

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionCell", for: indexPath) as! PostPhotoCollectionCell
        cell.setPhoto(UIImage(named: "test-photo"))
        return cell
    }

}