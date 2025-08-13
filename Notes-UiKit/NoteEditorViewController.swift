//
//  NoteEditorViewController.swift
//  Notes-UiKit
//
//  Created by Ferhat Taşlı on 12.08.2025.
//



import UIKit


enum EditorMode {
    case create
    case edit(Note)
}


class NoteEditorViewController: UIViewController {

    // MARK: - Properties
    private let mode: EditorMode
    private let repository = NotesRepository.shared
    private var hasChanges = false

    // MARK: - Initializer
    init(mode: EditorMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private lazy var scrollView : UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.keyboardDismissMode = .interactive
        return scroll
    }()

    private lazy var contentView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("title_placeholder", comment: "Title Placeholder")
        textField.font = .systemFont(ofSize: 20, weight: .medium)
        textField.borderStyle = .none
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return textField
    }()
    private lazy var separatorView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()

    private lazy var contentTextView : UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 17)
        textView.isScrollEnabled = true
        textView.delegate = self
        return textView
    }()
    private lazy var placeholderLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("content_placeholder", comment: "Content Placeholder")
        label.font = .systemFont(ofSize: 17)
        label.textColor = .placeholderText
        return label
    }()


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadInitialData()
        setupKeyboardObservers()
    }

    // Mark : Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        switch mode {
            case .create:
                title = NSLocalizedString("new_note_title", comment: "New Note Title")
            case .edit:
                title = NSLocalizedString("edit_note_title", comment: "Edit Note Title")
        }

        //navigation bar button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem : .cancel,
            target : self,
            action : #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem?.accessibilityLabel = NSLocalizedString("cancel", comment: "Cancel Button Label")
        navigationItem.leftBarButtonItem?.accessibilityHint = NSLocalizedString("cancel_hint", comment: "Cancel Button Hint")

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem : .save,
            target : self,
            action : #selector(saveTapped)
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = NSLocalizedString("save", comment: "Save Button Label")
        navigationItem.rightBarButtonItem?.accessibilityHint = NSLocalizedString("save_hint", comment: "Save Button Hint")

        // Layout Setup
        setupLayout()

    }

   private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleTextField)
        contentView.addSubview(separatorView)
        contentView.addSubview(contentTextView)
        contentView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title TextField
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Separator
            separatorView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            // Content TextView
            contentTextView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentTextView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            
            // Placeholder Label
            placeholderLabel.topAnchor.constraint(equalTo: contentTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor, constant: 4),
            placeholderLabel.trailingAnchor.constraint(equalTo: contentTextView.trailingAnchor, constant: -4)
        ])

        titleTextField.accessibilityLabel = NSLocalizedString("note_title_field", comment: "Note Title Field")
        titleTextField.accessibilityHint = NSLocalizedString("enter_title_hint", comment: "Enter Title Hint")

        contentTextView.accessibilityLabel = NSLocalizedString("note_content_field", comment: "Note Content Field")
        contentTextView.accessibilityHint = NSLocalizedString("enter_content_hint", comment: "Enter Content Hint")
        contentTextView.isAccessibilityElement = true
    }

    private func loadInitialData() {
        switch mode {
            case .create:
                // Yeni not için boş başla
                titleTextField.becomeFirstResponder() // Klavye Aç
            case .edit(let note):
                // Mevcut not verilerini yükle
                titleTextField.text = note.title
                contentTextView.text = note.content
                updatePlaceholderVisibility()
        }
    }

    // Mark : - Actions
    @objc private func cancelTapped() {
        if hasChanges {
            showCancelAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    @objc private func saveTapped() {
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
            showAlert(title: NSLocalizedString("title_empty_error", comment: "Title Empty Error"), message: NSLocalizedString("title_empty_error_message", comment: "Title Empty Error Message"))
            return
        }
        let content = contentTextView.text ?? ""

        switch mode {
            case .create:
            //Yeni not oluştur
            repository.create(title: title, body: content)
            case .edit(let note):
            // Mevcut notu güncelle
            var updatedNote = note
            updatedNote.title = title
            updatedNote.content = content
            repository.update(note: updatedNote)
        }

        // Geri Dön
        navigationController?.popViewController(animated: true)
    }

    @objc private func textDidChange() {
        hasChanges = true
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !contentTextView.text.isEmpty
    }
    private func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "OK Button Label"), style: .default))
        present(alert, animated: true)
    }


    private func showCancelAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("unsaved_changes_title", comment: "Unsaved Changes Title"),
            message: NSLocalizedString("unsaved_changes_message", comment: "Unsaved Changes Message"),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("discard_changes", comment: "Discard Changes"), style:.destructive){ _ in
            self.navigationController?.popViewController(animated: true)
        })

        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel Button Label"), style: .cancel))

        present(alert, animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



// Mark : - UITextFieldDelegate
extension NoteEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Return tuşuna basıldığında TextView'a geç
        contentTextView.becomeFirstResponder()
        return true
    }
}


// Mark : - UITextViewDelegate
extension NoteEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        hasChanges = true
        updatePlaceholderVisibility()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
}

