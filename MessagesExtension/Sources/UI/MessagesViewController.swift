import UIKit
import Messages

final class MessagesViewController: MSMessagesAppViewController {
    private enum Section {
        case main
    }

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search hamsters or moods"
        searchBar.autocapitalizationType = .none
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.6))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            return NSCollectionLayoutSection(group: group)
        }
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(HamsterCollectionViewCell.self, forCellWithReuseIdentifier: HamsterCollectionViewCell.reuseIdentifier)
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, HamsterItem> = {
        UICollectionViewDiffableDataSource<Section, HamsterItem>(collectionView: collectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HamsterCollectionViewCell.reuseIdentifier, for: indexPath) as? HamsterCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: item)
            return cell
        }
    }()

    private let repository = ManifestRepository()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    private var manifestItems: [HamsterItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        searchBar.delegate = self
        updateStatus("Loading hamsters…")
        bootstrap()
    }

    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        requestPresentationStyle(.expanded)
    }

    private func configureHierarchy() {
        view.backgroundColor = .systemBackground
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(statusLabel)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),

            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            statusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4)
        ])
    }

    private func bootstrap() {
        activityIndicator.startAnimating()
        if let manifest = repository.bootstrapManifest() {
            manifestItems = manifest.items
            applySnapshot(filtered: manifestItems)
            updateStatus("Loaded \(manifest.items.count) hamsters")
        } else {
            updateStatus("No manifest seed bundled")
        }
        repository.refreshManifest { [weak self] result in
            guard let self else { return }
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let manifest):
                self.manifestItems = manifest.items
                self.applySnapshot(filtered: self.currentFilteredItems())
                self.updateStatus("Synced \(manifest.items.count) hamsters")
            case .failure(let error):
                self.updateStatus("Offline mode: \(MessagesViewController.format(error: error))")
            }
        }
    }

    private func applySnapshot(filtered items: [HamsterItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, HamsterItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func currentFilteredItems() -> [HamsterItem] {
        guard let text = searchBar.text, !text.isEmpty else {
            return manifestItems
        }
        return manifestItems.filter { $0.matches(query: text) }
    }

    private func updateStatus(_ message: String?) {
        statusLabel.text = message
        statusLabel.isHidden = message == nil
    }

    private func insertIntoConversation(item: HamsterItem) {
        guard let conversation = activeConversation else {
            updateStatus("Open a chat to send hamsters")
            return
        }
        updateStatus("Preparing hamster…")
        ImageLoader.shared.load(url: item.imageUrl) { [weak self] image in
            guard let self else { return }
            guard let image = image else {
                self.updateStatus("Failed to load image")
                return
            }
            let layout = MSMessageTemplateLayout()
            layout.image = image
            layout.caption = item.tags.prefix(2).joined(separator: " · ")
            let message = MSMessage(session: MSSession())
            message.layout = layout
            conversation.insert(message) { error in
                if let error = error {
                    self.updateStatus("Insert failed: \(error.localizedDescription)")
                } else {
                    self.updateStatus("Hamster sent")
                }
            }
        }
    }

    private static func format(error: ManifestError) -> String {
        switch error {
        case .networkError(let err):
            return err.localizedDescription
        case .validationFailed(let reason):
            return reason
        case .decodingFailed:
            return "Invalid manifest"
        case .notFound:
            return "No manifest returned"
        }
    }
}

extension MessagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        insertIntoConversation(item: item)
    }
}

extension MessagesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySnapshot(filtered: currentFilteredItems())
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
