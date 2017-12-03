//
// Created by Almas Adilbek on 12/1/17.
// Copyright (c) 2017 Good App. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxRealm
import RxSwift

final class PostsController : UIViewController {

    fileprivate let viewModel = PostsViewModel()
    private var bag = DisposeBag()

    private var list:UITableView!
    private var messageLabel:UILabel? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        configUI()
        configEvents()
    }

    private func configEvents() {
        Observable.collection(from: viewModel.posts).subscribe(onNext: { [weak self] results in

            print("collection:\(results)")
            if results.count > 0 {

                // Remove message if exists.
                self?.messageLabel?.removeFromSuperview()

                self?.list.isHidden = false
                self?.list.reloadData()

            } else {

                // Hide the list
                self?.list.isHidden = true

                // Create message
                if self?.messageLabel == nil {
                    let title = "No Posts!"
                    self?.messageLabel = UILabel.base().font(.systemFont(ofSize: 12)).color(.appGray).multiline().centered()
                    self?.messageLabel?.text = "\(title)\nCreate your first Post tapping on \"+ Create\" button."
                    self?.view.addSubview(self!.messageLabel!)
                    self?.messageLabel?.setFont(font: .boldSystemFont(ofSize: 18), forSubstring: title)
                    self?.messageLabel?.setColor(color: .flatBlack, forSubstring: title)
                    self?.messageLabel?.snp.makeConstraints { make in
                        make.width.equalToSuperview().multipliedBy(0.6)
                        make.centerX.equalToSuperview()
                        make.centerY.equalToSuperview().offset(-44)
                    }
                }
            }
        }).disposed(by: bag)
    }

    // MARK: Actions

    @objc private func tapNew() {
        let controller = DesignPostController()
        self.navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: UI

    private func configUI() {

        self.view.backgroundColor = UIColor(hexString:"EEEEEE")

        list = UITableView(frame: CGRect.zero, style: .plain)
        list.delegate = self
        list.dataSource = self
        list.rowHeight = PostTableCell.cellHeight
        list.separatorInset = .zero
        list.separatorColor = UIColor.black.withAlphaComponent(0.1)
        list.register(PostTableCell.self, forCellReuseIdentifier: "PostTableCell")
        self.view.addSubview(list)

        // Create Button
        let createButton = UIButton(type: .custom)
        createButton.addTarget(self, action: #selector(tapNew), for: .touchUpInside)
        createButton.setTitle("+ Новый".uppercased(), for: .normal)
        createButton.titleLabel?.font = .boldSystemFont(ofSize: 13)
        createButton.titleLabel?.setLetter(spacing: 1)
        createButton.backgroundColor = .appBlue
        self.view.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.leading.trailing.bottom.equalToSuperview()
        }

        list.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(createButton.snp.top)
        }
    }

}

extension PostsController : UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableCell") as! PostTableCell
        cell.setPost(viewModel.posts[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)


    }
}