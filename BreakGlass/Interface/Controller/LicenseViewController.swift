//
//  LicenseViewController.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import Foundation
import SnapKit
import UIKit

class LicenseViewController: UINavigationController {
    init() {
        let content = LicenseContentViewController()
        super.init(rootViewController: content)
        modalPresentationStyle = .formSheet
        modalTransitionStyle = .coverVertical
        preferredContentSize = .init(width: 555, height: 555)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}

private class LicenseContentViewController: UIViewController, UITableViewDelegate {
    init() {
        super.init(nibName: nil, bundle: nil)
        title = String(localized: "License")
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let tableView = UITableView(frame: .zero, style: .plain)
    var dataSource: UITableViewDiffableDataSource<String, String>!
    private let footerView = UIView()
    private let footerLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = .init(
            systemItem: .done,
            primaryAction: .init { _ in
                self.navigationController?.dismiss(animated: true)
            }
        )

        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.rounded(ofTextStyle: .body, weight: .regular),
        ]

        setupTableView()
        loadLicenses()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateFooterLayout()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LicenseCell")
        dataSource = UITableViewDiffableDataSource<String, String>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "LicenseCell", for: indexPath)
            cell.textLabel?.text = itemIdentifier
            cell.textLabel?.font = .rounded(ofTextStyle: .body, weight: .regular)
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        tableView.dataSource = dataSource
        tableView.delegate = self

        footerLabel.text = String(localized: "Made with 😘 by @Lakr233")
        footerLabel.textAlignment = .center
        footerLabel.font = .rounded(ofTextStyle: .footnote, weight: .regular)
        footerLabel.textColor = .secondaryLabel
        footerLabel.numberOfLines = 0

        if footerLabel.superview == nil {
            footerView.addSubview(footerLabel)
            footerLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
            }
        }

        if footerView.gestureRecognizers?.isEmpty ?? true {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openGitHub))
            footerView.addGestureRecognizer(tapGesture)
        }

        footerView.isUserInteractionEnabled = true

        tableView.tableFooterView = footerView
        updateFooterLayout()
    }

    private func loadLicenses() {
        guard let licensesPath = Bundle.main.resourcePath?.appending("/Licenses") else { return }
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: licensesPath)
            let txtFiles = files.filter { $0.hasSuffix(".txt") && !$0.hasPrefix(".") }
            var snapshot = NSDiffableDataSourceSnapshot<String, String>()
            snapshot.appendSections(["Licenses"])
            snapshot.appendItems(txtFiles.sorted(), toSection: "Licenses")
            dataSource.apply(snapshot, animatingDifferences: true)
        } catch {
            print("Error loading licenses: \(error)")
        }
    }

    private func updateFooterLayout() {
        let targetWidth = tableView.bounds.width
        guard targetWidth > 0 else { return }

        footerView.setNeedsLayout()
        footerView.layoutIfNeeded()

        let targetSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        let calculatedHeight = footerView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        let height = max(calculatedHeight, CGFloat(44))
        if footerView.frame.width != targetWidth || footerView.frame.height != height {
            footerView.frame = CGRect(x: 0, y: 0, width: targetWidth, height: height)
            tableView.tableFooterView = footerView
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let fileName = dataSource.itemIdentifier(for: indexPath) else { return }
        let detailVC = LicenseDetailViewController(fileName: fileName)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    @objc private func openGitHub() {
        if let url = URL(string: "https://github.com/Lakr233") {
            UIApplication.shared.open(url)
        }
    }
}

private class LicenseDetailViewController: UIViewController {
    private let fileName: String
    private let textView = UITextView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    init(fileName: String) {
        self.fileName = fileName
        super.init(nibName: nil, bundle: nil)
        title = fileName
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupViews()
        loadContent()
    }

    private func setupViews() {
        textView.isEditable = false
        textView.font = .rounded(ofTextStyle: .body, weight: .regular)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.addSubview(textView)

        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)

        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func loadContent() {
        loadingIndicator.startAnimating()
        textView.isHidden = true

        DispatchQueue.global(qos: .userInitiated).async {
            guard let path = Bundle.main.path(forResource: self.fileName, ofType: nil, inDirectory: "Licenses"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                  let content = String(data: data, encoding: .utf8)
            else {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.textView.text = String(localized: "Failed to load content.")
                    self.textView.isHidden = false
                }
                return
            }

            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.textView.text = content
                self.textView.isHidden = false
            }
        }
    }
}
