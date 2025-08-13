import Foundation


protocol NotesRepositoryType {
    @discardableResult
    func load() -> [Note]
    func allNotes() -> [Note]
    @discardableResult
    func create(title: String, body: String) -> Note
    @discardableResult
    func update(note: Note) -> Note
    func delete(id: String)
}

extension Notification.Name {
    static let notesRepositoryDidChange = Notification.Name("notesRepositoryDidChange")
}

final class NotesRepository : NotesRepositoryType {
    static let shared = NotesRepository()
    
    private let userDefaults : UserDefaults
    private let storageKey = "notes_store"
    private var cache : [Note] = []
    private var queue = DispatchQueue(label: "NotesRepository.serial")

    private init(userDefaults: UserDefaults = .standard) {
        print("🏗️ Repository: Singleton instance oluşturuluyor")
        self.userDefaults = userDefaults
        self.cache = Self.loadFromDisk(userDefaults: userDefaults, key: storageKey)
        sortCache()
    }

    @discardableResult
    func load() -> [Note] {
        let notes = Self.loadFromDisk(userDefaults: userDefaults, key: storageKey)
        queue.sync {
            self.cache = notes
            self.sortCache()
        }
        return allNotes()
    }

    func allNotes() -> [Note] {
        return queue.sync { 
            print("📋 Repository: allNotes() çağrıldı - cache count: \(cache.count)")
            return cache
        }
    }

    @discardableResult
    func create(title:String, body:String) -> Note {
        print("🆕 Repository: create() çağrıldı - title: '\(title)'")
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        var note = Note(title:trimmedTitle, content:body)
        note.updatedAt = Date()
        
        print("📝 Repository: Yeni not oluşturuldu - id: \(note.id)")

        queue.sync {
            let oldCount = cache.count
            cache.append(note)
            sortCache()
            persistCacheLocked()
            print("💾 Repository: Cache güncellendi \(oldCount) → \(cache.count)")
        }
        notifyChange()
        return note
    }
    @discardableResult
    func update(note: Note) -> Note {
        var updated = note
        updated.updatedAt = Date()

        queue.sync {
            if let index = cache.firstIndex(where: { $0.id == note.id }) {
                cache[index] = updated
                sortCache()
                persistCacheLocked()
            }
        }
        notifyChange()
        return updated
    }
    
    func delete(id: String) {
        queue.sync {
            if let index = cache.firstIndex(where: { $0.id == id }) {
                cache.remove(at: index)
                persistCacheLocked()
                
            }
        }
        notifyChange()
    }


    // MARK: - Private

    private func notifyChange() {
        print("🔔 Repository: Bildirim gönderiliyor...")
        NotificationCenter.default.post(name: .notesRepositoryDidChange, object: nil)
        print("✅ Repository: Bildirim gönderildi!")
    }
    private func sortCache() {
        cache.sort { lhs, rhs in 
            lhs.updatedAt > rhs.updatedAt
        }
    }

    private func persistCacheLocked() {
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(cache)
            userDefaults.set(data, forKey: storageKey)
        } catch {
        }
    }

    private static func loadFromDisk(userDefaults: UserDefaults, key: String) -> [Note] {
        let decoder = JSONDecoder()
        // İsternen : decoder.dateDecodingStrategy = .iso8601
        guard let data = userDefaults.data(forKey: key) else {return []}
        do {
            return try decoder.decode([Note].self, from: data)
        } catch {
            return []
        }
    }
}
