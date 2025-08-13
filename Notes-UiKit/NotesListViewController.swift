//
//  ViewController.swift
//  Notes-UiKit
//
//  Created by Ferhat Taşlı on 12.08.2025.
//

import UIKit

class NotesListViewController: UIViewController {
    private let repository = NotesRepository.shared
    private var allNotes: [Note] = []
    private var filteredNotes: [Note] = []
    private var isSearchActive = false

    override func viewDidLoad() {
        super.viewDidLoad()
        print("NotesListViewController yüklendi")
        repository.load()
        setupUI()
        loadNotes()
        setupNotificationObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("📱 viewWillAppear - Liste yenileniyor")
        loadNotes()
    }

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        return table
    }()

    // Mark : - UI Components
    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = NSLocalizedString("search_placeholder", comment: "Search Placeholder")
        return search
    }()



private func setupUI() {
    title = NSLocalizedString("notes_title", comment: "Main List Title")
    view.backgroundColor = .systemBackground

    // Navigation bar setup
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false

    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewNote))
    navigationItem.rightBarButtonItem = addButton
    addButton.accessibilityLabel = NSLocalizedString("add_note", comment: "Add Note Button Label")
    addButton.accessibilityHint = NSLocalizedString("double_tap_to_edit", comment: "Add Note Button Hint")


    // Table View 'i Ekleme
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    }

    private func loadNotes() {
        print("🔄 loadNotes çağrıldı")
        
        // İlk açılıştışta test verisi ekleyelim
        if repository.allNotes().isEmpty {
            repository.create(title: "Test Notu 1", body: "Bu bir test notudur. İçeriği görüntülemek için tıklayın.")
            repository.create(title: "Test Notu 2", body: "Bu da bir test notudur. İçeriği görüntülemek için tıklayın.")
            repository.create(title: "Test Notu 3", body: "Bu da bir test notudur. İçeriği görüntülemek için tıklayın.")
        }

        let oldCount = filteredNotes.count
        allNotes = repository.allNotes()
        updateFilteredNotes()
        let newCount = filteredNotes.count
        
        print("📊 Not sayısı: \(oldCount) → \(newCount)")
        tableView.reloadData()
        print("✅ TableView.reloadData() çağrıldı")
    }
    private func updateFilteredNotes() {
        if isSearchActive, let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredNotes = allNotes.filter { note in note.title.lowercased().contains(searchText.lowercased())
             }
        } else {
            filteredNotes = allNotes
        }
    }

    @objc private func createNewNote() {
        let editorVC = NoteEditorViewController(mode: .create)
        navigationController?.pushViewController(editorVC, animated: true)
    }



    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notesDidChange),
            name: .notesRepositoryDidChange,
            object: nil
        )
    }
    @objc private func notesDidChange() {
        print("📱 Liste: Bildirim alındı!")
        DispatchQueue.main.async {
            print("📱 Liste: UI güncelleniyor...")
            self.loadNotes()
            print("📱 Liste: Tablo yenilendi!")
        }
    }
}

 

// MARK: - UITableViewDataSource
extension NotesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "NoteCell")
        let note = filteredNotes[indexPath.row]

        // Title
        cell.textLabel?.text = note.title
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.textLabel?.numberOfLines = 0

        // Preview (body'nin ilk 80 karakteri)
        let preview = note.content.prefix(80)
        let previewText = preview.isEmpty ? NSLocalizedString("no_content", comment: "No Content") : String(preview)
        cell.detailTextLabel?.text = previewText
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        cell.detailTextLabel?.adjustsFontForContentSizeCategory = true
        cell.detailTextLabel?.numberOfLines = 0

        // VoiceOver erişilebilirlik
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "tr_TR")

        let formattedDate = dateFormatter.string(from: note.updatedAt)

         cell.accessibilityLabel = "\(note.title). \(NSLocalizedString("last_updated", comment: "Last updated")): \(formattedDate)"
        cell.accessibilityHint = NSLocalizedString("double_tap_to_edit", comment: "Edit Note Hint")
        cell.accessibilityTraits = .button

        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = filteredNotes[indexPath.row]
        
        let editorVC = NoteEditorViewController(mode: .edit(note))
        navigationController?.pushViewController(editorVC, animated: true)

    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = filteredNotes[indexPath.row]
            repository.delete(id: note.id)
            
            // Silinen notu filtrelenmiş listeden kaldır
            filteredNotes.remove(at: indexPath.row)

            // Table view'i güncelle
            tableView.deleteRows(at: [indexPath], with: .fade)

            // allNote'u da güncelle
            allNotes = repository.allNotes()

            }

    }
}

// MARK: - UISearchResultsUpdating
extension NotesListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }

        isSearchActive = !searchText.isEmpty
        updateFilteredNotes()
        tableView.reloadData()
    }
}
