# Not Defteri — Gelişim Adımları

Bu dosya, uygulamayı adım adım geliştirirken yapılacak işleri takip etmek içindir. Her adımı tamamladığınızda ilgili kutucuğu işaretleyin.

## Efsane
- [ ] Yapılacak
- [x] Tamamlandı

---

## Adım 1 — Model ve Repository (Veri Katmanı)
- [x] `Notes-UiKit/Model/` klasörünü oluştur
- [x] `Notes-UiKit/Data/` klasörünü oluştur
- [x] `Model/Note.swift` dosyasını ekle
  - [x] `struct Note: Codable, Equatable`
  - [x] Alanlar: `id: String`, `title: String`, `body: String`, `createdAt: Date`, `updatedAt: Date`
  - [x] Yeni not oluştururken `id = UUID().uuidString`, `createdAt = Date()`, `updatedAt = Date()`
- [x] `Data/NotesRepository.swift` dosyasını ekle
  - [x] `protocol NotesRepositoryType`
    - [x] `func load() -> [Note]`
    - [x] `func allNotes() -> [Note]`
    - [x] `func create(title: String, body: String) -> Note`
    - [x] `func update(note: Note) -> Note`
    - [x] `func delete(id: String)`
    - [x] Değişim bildirimi: `Notification.Name("notesRepositoryDidChange")`
  - [x] `final class NotesRepository: NotesRepositoryType`
    - [x] `UserDefaults.standard` + `storageKey = "notes_store"`
    - [x] `private var cache: [Note] = []`
    - [x] Erişimleri sıraya almak için `DispatchQueue(label: "NotesRepository")`
    - [x] JSON encode/decode ile toplu okuma/yazma
    - [x] Tüm listeleri `updatedAt` azalan sırada döndür
    - [x] Yazımlardan sonra `NotificationCenter` ile değişim bildir
- [ ] (Opsiyonel) `Support/DateFormatting.swift` ile `RelativeDateTimeFormatter`

Tamamlanma ölçütleri:
- [x] Proje derleniyor
- [x] `NotesRepository` ile `load/create/update/delete` akışları çalışıyor
- [x] `allNotes()` sonucu güncel ve sıralı

---

## Adım 2 — Not Listesi Ekranı (Liste + Arama + Silme)
- [x] `ViewController` yerine `NotesListViewController` oluştur ve giriş ekranı yap
- [x] `UITableView` ile notları göster (title, preview, updatedAt)
- [x] `UISearchController` ile title bazlı canlı filtreleme (case-insensitive)
- [x] `updatedAt desc` sıralaması ile veriyi göster
- [ ] Boş durumda `EmptyStateView` (ikon, başlık, açıklama, "Yeni Not Oluştur")
- [x] Swipe-to-delete ile silme ve repository güncelleme
- [x] Repository değişimlerini dinleyip tabloyu yenile

---

## Adım 3 — Not Editör Ekranı (Oluşturma/Düzenleme)
- [x] `NoteEditorViewController` ekle (create/edit modları)
- [x] `UITextField` (Başlık), `UITextView` (İçerik), placeholder davranışı
- [x] Kaydet: create/update çağır, `updatedAt` güncelle, geri dön
- [x] İptal: değişiklik varsa uyarı (Kaydetmeden çıkılsın mı?)
- [x] Klavye açılınca içerik görünürlüğü için `contentInset` ayarı

---

## Adım 4 — Navigasyon ve Akış
- [x] `UINavigationController` kök; Liste → Editör `push`
- [x] Sağ üst `+` ile create modu
- [x] Hücreye dokununca edit modu

---

## Adım 5 — Erişilebilirlik ve Yerelleştirme
- [x] Dynamic Type destekle (`adjustsFontForContentSizeCategory = true`)
- [x] VoiceOver etiketleri (Hücre: "Başlık, Son güncelleme: …")
- [x] TR/EN `.strings` anahtarları

---



## Notlar
- Minimum iOS: 15
- Persistans: `UserDefaults` + `Codable`, key: `"notes_store"`
- Eşzamanlılık: Repository içinde seri `DispatchQueue`
- Arama: yalnızca `title`, case-insensitive, yazdıkça filtre

