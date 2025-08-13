# Notes App - UIKit Implementation

A comprehensive note-taking application built with UIKit, demonstrating modern iOS development practices and architectural patterns.

![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)
![UIKit](https://img.shields.io/badge/UIKit-Framework-green.svg)
![Architecture](https://img.shields.io/badge/Architecture-MVC%20%2B%20Repository-purple.svg)

## 🎯 Project Overview

This project showcases a production-ready notes application with full CRUD functionality, real-time synchronization, accessibility features, and internationalization support. Built entirely with UIKit and following iOS best practices.

## ✨ Key Features

### Core Functionality
- ✅ **Full CRUD Operations** - Create, Read, Update, Delete notes
- ✅ **Real-time Synchronization** - Instant updates across screens
- ✅ **Live Search** - Filter notes by title with real-time results
- ✅ **Swipe-to-Delete** - Intuitive gesture-based deletion
- ✅ **Form Validation** - Proper input validation with user feedback
- ✅ **Unsaved Changes Detection** - Alert users before losing data

### User Experience
- ✅ **Empty State Handling** - Elegant empty state with call-to-action
- ✅ **Keyboard Management** - Smart content inset adjustments
- ✅ **Smooth Navigation** - Seamless transitions between screens
- ✅ **Loading States** - Responsive UI feedback

### Accessibility & Localization
- ✅ **Dynamic Type Support** - Respects user's preferred text size
- ✅ **VoiceOver Compatibility** - Full screen reader support
- ✅ **Internationalization** - Turkish/English localization
- ✅ **Accessibility Labels** - Comprehensive accessibility hints

## 🏗️ Technical Architecture

### Design Pattern: MVC + Repository
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Controllers   │    │     Models      │    │   Repository    │
│                 │    │                 │    │                 │
│ • List View     │◄──►│ • Note Struct   │◄──►│ • Data Layer    │
│ • Editor View   │    │ • EditorMode    │    │ • Persistence   │
│ • Navigation    │    │ • Protocols     │    │ • Caching       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Core Components

#### 1. Data Layer
**Repository Pattern Implementation**
```swift
protocol NotesRepositoryType {
    func create(title: String, body: String) -> Note
    func update(note: Note) -> Note
    func delete(id: String)
    func allNotes() -> [Note]
}
```

**Key Technical Decisions:**
- **Singleton Pattern** for data consistency across app lifecycle
- **Thread-Safe Operations** using serial DispatchQueue
- **UserDefaults + Codable** for lightweight persistence
- **Automatic Sorting** by `updatedAt` timestamp
- **Real-time Notifications** using NotificationCenter

#### 2. Model Layer
**Clean Data Structures**
```swift
struct Note: Codable, Equatable {
    let id: String              // UUID for unique identification
    var title: String           // User-editable title
    var content: String         // User-editable content  
    let createdAt: Date         // Immutable creation timestamp
    var updatedAt: Date         // Auto-updated modification timestamp
}
```

#### 3. Presentation Layer

**NotesListViewController**
- UITableView with custom cells
- UISearchController integration
- Swipe-to-delete implementation
- Empty state management
- Real-time data synchronization

**NoteEditorViewController**
- Create/Edit mode handling
- Form validation with user feedback
- Unsaved changes detection
- Keyboard-aware scrolling
- Auto Layout constraints

## 🛠️ Technical Implementations

### Real-Time Data Synchronization
```swift
// Repository broadcasts changes
NotificationCenter.default.post(name: .notesRepositoryDidChange, object: nil)

// Controllers listen and update UI
@objc private func notesDidChange() {
    DispatchQueue.main.async {
        self.loadNotes()
    }
}
```

### Thread-Safe Repository Operations
```swift
private let queue = DispatchQueue(label: "NotesRepository.serial")

func create(title: String, body: String) -> Note {
    queue.sync {
        cache.append(note)
        sortCache()
        persistCacheLocked()
    }
    notifyChange()
    return note
}
```

### Accessibility Implementation
```swift
// Dynamic Type Support
cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
cell.textLabel?.adjustsFontForContentSizeCategory = true

// VoiceOver Support
cell.accessibilityLabel = "\(note.title). Last updated: \(formattedDate)"
cell.accessibilityHint = "Double tap to edit note"
```

### Internationalization
```swift
// Localized strings with context
title = NSLocalizedString("notes_title", comment: "Main screen title")
placeholder = NSLocalizedString("search_placeholder", comment: "Search bar placeholder")
```

## 🎨 UI/UX Features

### Auto Layout & Responsive Design
- **Programmatic Auto Layout** - No Storyboard dependencies for complex layouts
- **Safe Area Compliance** - Proper iPhone X+ support
- **Dynamic Content Sizing** - Self-sizing table view cells
- **Keyboard Handling** - Content inset adjustments for text input

### Visual Polish
- **System Colors** - Automatic dark/light mode support
- **SF Symbols** - Native iOS iconography
- **Smooth Animations** - Native table view animations
- **Loading States** - Responsive user feedback

## 📱 Supported Features

| Feature | Implementation | Status |
|---------|---------------|---------|
| CRUD Operations | Repository Pattern | ✅ Complete |
| Real-time Sync | NotificationCenter | ✅ Complete |
| Search | Live filtering | ✅ Complete |
| Persistence | UserDefaults + Codable | ✅ Complete |
| Accessibility | Dynamic Type + VoiceOver | ✅ Complete |
| Localization | TR/EN with NSLocalizedString | ✅ Complete |
| Form Validation | Input validation + alerts | ✅ Complete |
| Empty States | Custom empty state view | ✅ Complete |

## 🔧 Technical Specifications

- **Minimum iOS Version:** 15.0+
- **Language:** Swift 5.0+
- **Framework:** UIKit
- **Architecture:** MVC + Repository Pattern
- **Persistence:** UserDefaults with Codable
- **Concurrency:** DispatchQueue for thread safety
- **Localization:** NSLocalizedString (TR/EN)
- **Dependencies:** None (Pure UIKit implementation)

## 🚀 Getting Started

### Prerequisites
- Xcode 13.0+
- iOS 15.0+ device/simulator
- Swift 5.0+

### Installation
1. Clone the repository
```bash
git clone https://github.com/ferhatsli/Notes-UiKit.git
cd Notes-UiKit
```

2. Open in Xcode
```bash
open Notes-UiKit.xcodeproj
```

3. Build and run
- Select target device/simulator
- Press `Cmd+R` to build and run

## 🧪 Testing Strategy

### Unit Tests Coverage
- Repository CRUD operations
- Data persistence and retrieval
- Sorting algorithms
- Thread safety validation

### Manual Testing Scenarios
- Create/Edit/Delete workflows
- Search functionality
- Accessibility features (VoiceOver, Dynamic Type)
- Localization switching
- Edge cases (empty states, validation)

## 🎯 Code Quality Highlights

### Best Practices Implemented
- **SOLID Principles** - Single responsibility, dependency injection
- **Protocol-Oriented Programming** - Repository abstraction
- **Memory Management** - Proper retain cycle prevention
- **Error Handling** - Graceful failure recovery
- **Code Documentation** - Comprehensive inline documentation
- **Consistent Naming** - Swift naming conventions throughout

### Performance Optimizations
- **Lazy Loading** - UI components initialized on demand
- **Efficient Data Structures** - Minimal memory footprint
- **Background Processing** - Non-blocking UI operations
- **Caching Strategy** - In-memory cache with disk persistence

## 📈 Scalability Considerations

### Future Enhancements Ready
- **Core Data Migration** - Repository pattern allows easy persistence layer swap
- **Cloud Synchronization** - Repository abstraction supports remote data sources
- **Rich Text Support** - Extensible note content structure
- **Categories/Tags** - Model structure supports metadata expansion
- **Attachments** - File system integration ready

### Architecture Benefits
- **Testable Code** - Dependency injection and protocol abstractions
- **Maintainable Structure** - Clear separation of concerns
- **Extensible Design** - Easy to add new features without breaking existing code
- **Reusable Components** - Repository pattern reusable across projects

## 👨‍💻 Developer Notes

This project demonstrates proficiency in:
- **Modern iOS Development** with UIKit
- **Architectural Patterns** (MVC + Repository)
- **Concurrency & Thread Safety**
- **Accessibility & Inclusivity**
- **Internationalization**
- **Performance Optimization**
- **Code Quality & Best Practices**

---

**Built with ❤️ using UIKit and Swift**

*For questions or collaboration opportunities, feel free to reach out!*
