//
// Created by Almas Adilbek on 12/1/17.
// Copyright (c) 2017 Good App. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import CHIPageControl
import GrowingTextView
import DynamicColor
import RxSwift
import RxCocoa

final class DesignPostView : UIView {

    let viewModel = DesignPostViewViewModel()
    private let bag = DisposeBag()

    private let containerView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

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
//        button.isHidden = true
        return button
    }()

    fileprivate let titleTextView:GrowingTextView = {
        let field = GrowingTextView()
        field.backgroundColor = .clear
        field.font = .systemFont(ofSize: 20)
        field.textColor = .white
        field.autocorrectionType = .no
        field.keyboardAppearance = .dark
        field.showsHorizontalScrollIndicator = false
        field.showsVerticalScrollIndicator = false
        field.placeHolder = "Введите заголовок"
        field.placeHolderColor = .white
        field.trimWhiteSpaceWhenEndEditing = false
        field.minHeight = 40
        return field
    }()

    fileprivate var titleTextViewHeightConstraint:ConstraintMakerEditable!

    fileprivate let priceTextView:GrowingTextView = {
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
        field.minHeight = 44
        field.maxLength = 15
        field.keyboardType = .numberPad
        return field
    }()

    fileprivate let pageControl = CHIPageControlChimayo()

    private let badgesContainer = UIView()

    private var titleLengthIndicator:BadgeView?

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

        // Title & Price
        titleTextView.rx.text.map{$0!}.bind(to: viewModel.postTitle)
        priceTextView.rx.text.map{$0!}.bind(to: viewModel.price)

        viewModel.postTitle.asObservable().subscribe(onNext: { [weak self] (title:String) in
            guard let _self = self else { return }
            _self.titleLengthIndicator?.text = _self.viewModel.titleLengthIndicatorText
            _self.titleLengthIndicator?.backgroundView.backgroundColor = title.count < _self.viewModel.titleFieldMaxLength ? .black : .red
        }).addDisposableTo(bag)

        // Subscribe to on price text view value change.
        viewModel.price.asObservable().distinctUntilChanged().subscribe(onNext: { [weak self] (price:String) in

            guard let _self = self else { return }

            if price == "" {
                self?.priceTextView.text = ""
            } else {
                // Sanitize the price value
                var newPrice = price.replacingOccurrences(of: " ", with: "")
                        .replacingOccurrences(of: _self.viewModel.currencySymbol, with: "")
                        .trimmingCharacters(in: .whitespaces)

                // Format as thousands separator.
                // This approach also prevents entering the invalid number like "00 ₸", which is automatically converted to "0 ₸"
                guard let intPrice = Int(newPrice) else {
                    self?.priceTextView.text = ""
                    return
                }
                newPrice = intPrice.formattedWithSeparator

                self?.priceTextView.text = "\(newPrice) \(_self.viewModel.currencySymbol)"

                // Calculate the cursor position, two positions back from the end before the " ₸".
                self?.priceFieldPositionCursor()
            }

        }).addDisposableTo(bag)

        // Badges
        viewModel.badgeItems.asObservable().subscribe(onNext: { [weak self] (badges:[BadgeItem]) in
            self?.createBadges(badges)
        }).addDisposableTo(bag)

        // Title length indicator
        viewModel.isTitleEditing.asObservable().subscribe(onNext: { [weak self] (editing:Bool) in
            if editing {
                guard let _self = self else { return }
                self?.titleLengthIndicator = BadgeView(text: _self.viewModel.titleLengthIndicatorText)
                self?.titleLengthIndicator?.horizontalPadding = 4
                _self.containerView.addSubview(_self.titleLengthIndicator!)
                self?.titleLengthIndicator?.snp.makeConstraints { make in
                    make.leading.top.equalToSuperview().offset(_self.viewModel.postPadding)
                }
            } else {
                self?.titleLengthIndicator?.removeFromSuperview()
            }
        }).addDisposableTo(bag)

        // Preview
        viewModel.isPreview.asObservable().subscribe(onNext: { [weak self] (isPreview:Bool) in
            self?.pageControl.isHidden = isPreview
            self?.addNextPhotoButton.isHidden = isPreview
        }).addDisposableTo(bag)
    }

    fileprivate func priceFieldPositionCursor() {
        //
        var position: Int = priceTextView.text.count - 2
        if position >= 0 {
            if position == 0 {
                position = 1
            }
            if let newPosition = priceTextView.position(from: priceTextView.beginningOfDocument, offset: position) {
                priceTextView.selectedTextRange = priceTextView.textRange(from: newPosition, to: newPosition)
            }
        }
    }

    // MARK: Actions

    @objc private func tapAddPhoto() {
        print("tapAddPhoto")
    }

    // MARK: UI

    private func createBadges(_ badges:[BadgeItem]) {

        // Clear previous badges
        for subview in badgesContainer.subviews {
            subview.removeFromSuperview()
        }

        var prevBadge:BadgeView? = nil
        for item in badges {
            let badgeView = BadgeView(text:item.title.uppercased())
            badgeView.backgroundView.backgroundColor = item.backgroundColor
            badgeView.textColor = item.titleColor
            badgesContainer.addSubview(badgeView)

            if prevBadge != nil {
                // Next badge
                badgeView.snp.makeConstraints { make in
                    make.leading.equalTo(prevBadge!.snp.trailing).offset(7)
                }
            } else {
                // First badge
                badgeView.snp.makeConstraints { make in
                    make.leading.equalToSuperview()
                }
            }

            badgeView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }

            prevBadge = badgeView
        }
    }

    private func configUI() {

        // Container view
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
            make.top.equalToSuperview().offset(self.viewModel.postPadding)
            make.trailing.equalToSuperview().offset(-self.viewModel.postPadding)
        }

        // Page control
        pageControl.numberOfPages = 3
        pageControl.tintColor = UIColor.appGray
        pageControl.inactiveTransparency = 0.2
        pageControl.currentPageTintColor = .appBlueLight
        pageControl.radius = 3
        containerView.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.viewModel.postPadding)
            make.centerX.equalToSuperview()
        }

        // Input fields
        let fieldsMargin = 15

        containerView.addSubview(titleTextView)
        containerView.addSubview(priceTextView)

        priceTextView.delegate = self
        priceTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(fieldsMargin)
            make.bottom.equalToSuperview().offset(-7)
            make.trailing.equalToSuperview().offset(-fieldsMargin)
            make.height.equalTo(44)
        }

        titleTextView.delegate = self
        titleTextView.maxLength = viewModel.titleFieldMaxLength
        titleTextView.snp.makeConstraints { make in
            make.leading.equalTo(priceTextView)
            make.bottom.equalTo(priceTextView.snp.top).offset(5)
            make.trailing.equalToSuperview().offset(-20)
            titleTextViewHeightConstraint = make.height.equalTo(40)
        }

        // Badges container
        containerView.addSubview(badgesContainer)
        badgesContainer.isUserInteractionEnabled = false
        badgesContainer.snp.makeConstraints { make in
            make.leading.equalTo(titleTextView).offset(5)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(titleTextView.snp.top).offset(-1)
            make.height.equalTo(25)
        }
    }

}

// MARK: UITextView

extension DesignPostView : GrowingTextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        // Price text view
        if textView == priceTextView {
            delay(0.05) {
                self.priceFieldPositionCursor()
            }
        } else if textView == titleTextView {
            viewModel.isTitleEditing.value = true
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // Price text view
        if textView == titleTextView {
            viewModel.isTitleEditing.value = false
        }
    }

    // MARK: GrowingTextView

    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        // Update title text view height
        titleTextViewHeightConstraint.constraint.update(offset: height)
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
