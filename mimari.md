UIKit Başlangıç Projesi: “Not Defteri” – Ürün & Teknik Dokümantasyon

1) Proje Özeti

Basit bir not alma uygulaması. Kullanıcı not oluşturur, listeler, düzenler ve siler. Başlangıç seviyesinde UIKit’in temel bileşenleriyle (UITableView, UINavigationController, UITextField/TextView) çalışmayı ve Auto Layout, navigation ve persistans (UserDefaults) konularını öğretir.

2) Hedefler
	•	UIKit komponentlerini pratikte öğrenmek
	•	MVC yaklaşımıyla katmanlı bir yapı kurmak
	•	Basit veri saklama (UserDefaults)
	•	Navigation ve liste detay akışlarını kavramak
	•	Temel hata durumları & boş durum (empty state) yönetimi

3) Kapsam / Kapsam Dışı
	•	Kapsam: Not oluşturma, listeleme, düzenleme, silme; arama; basit sıralama; yerel bildirim yok.
	•	Kapsam Dışı: Çoklu kullanıcı, senkronizasyon, bulut yedekleme, gelişmiş güvenlik/şifreleme, zengin metin.

4) Kullanıcı Hikâyeleri
	•	US-01: Kullanıcı olarak yeni bir not eklemek istiyorum ki fikirlerimi kaydedebileyim.
	•	US-02: Kullanıcı olarak tüm notlarımı listede görmek istiyorum ki hızlıca erişebileyim.
	•	US-03: Kullanıcı olarak bir notu açıp düzenlemek istiyorum ki içeriğini güncelleyebileyim.
	•	US-04: Kullanıcı olarak bir notu listeden silebilmek istiyorum.
	•	US-05: Kullanıcı olarak arama çubuğuyla not başlıklarında arama yapmak istiyorum.
	•	US-06: Kullanıcı olarak notları tarihe göre (yeniden eskiye) sıralı görmek istiyorum.

⸻

5) Mimari

5.1 Yaklaşım
	•	Pattern: Basit MVC (Model–View–Controller)
	•	Katmanlar:
	•	Presentation: NotesListViewController, NoteEditorViewController, yardımcı view’lar (empty state view).
	•	Data (Repository): NotesRepository (UserDefaults ile okuma/yazma).
	•	Model: Note veri modeli.

Not: Başlangıç için MVC yeterli. İleride büyürse Coordinator, Repository arayüzleri, UseCase/Interactor (MVVM/DDD) eklenebilir.

5.2 Veri Modeli
	•	Note
	•	id: String (UUID)
	•	title: String
	•	body: String
	•	createdAt: Date
	•	updatedAt: Date
	•	Saklama: [Note] dizisini UserDefaults içinde JSON olarak tutma (key: "notes_store").

5.3 Veri Akışı
	1.	NotesRepository açılışta UserDefaults’tan notları yükler.
	2.	Liste ekranı repository’den veriyi çeker ve tabloyu yeniler.
	3.	Ekle/Düzenle ekranında Kaydet: Repository’ye yaz → updatedAt güncellenir → Liste ekranı refresh.
	4.	Silme: Liste ekranından swipe-to-delete → Repository güncelle → Liste yenile.

5.4 Navigasyon
	•	Root: UINavigationController
	•	Flow:
	•	NotesListViewController (root)
→ Sağ üst + ile NoteEditorViewController (mode: create)
→ Hücreye dokununca NoteEditorViewController (mode: edit)
	•	Geçişler: push (liste → editör), pop (kaydet/iptal sonrası geri).

⸻

6) Ekranlar & Bileşenler

6.1 Not Listesi (NotesListViewController)

Amaç: Notları başlık + kısa içerik önizlemesiyle göstermek, aramak, silmek.
	•	Header/Navigation
	•	Title: “Notlar”
	•	Right Bar Button: “+” (yeni not)
	•	Optional Left Bar Button: “Düzenle” (tablo edit mode’a geçiş)
	•	İçerik
	•	UITableView (plain)
	•	Hücre:
	•	titleLabel (1 satır, bold)
	•	previewLabel (1–2 satır, gövde kısa özeti)
	•	updatedAtLabel (küçük, ikincil)
	•	UISearchController / UISearchBar: Başlıkta arama (title üzerinden filtre)
	•	Empty State View (hiç not yoksa):
	•	İkon/emoji
	•	“Henüz not yok” başlığı
	•	“+ ile yeni bir not ekleyin” alt metni
	•	Button: “Yeni Not Oluştur”
	•	Etkileşimler
	•	Hücreye dokun: Editör ekranına git (edit mode)
	•	Swipe-to-delete: Not sil
	•	Pull-to-refresh: (Opsiyonel) Liste yenile
	•	Durumlar
	•	Boş durum: Empty state görünür, tablo gizli
	•	Arama aktif: Sadece eşleşen notlar
	•	Hata (yükleme/yazma): Banner/alert

Performans Notları:
	•	Metin kısaltma (preview için body’nin ilk 80–120 karakteri).
	•	Zaman bilgisini “x dakika önce” gibi relative formatla göster (başlangıç için sabit biçim de yeter).

⸻

6.2 Not Düzenleyici / Oluşturucu (NoteEditorViewController)

Amaç: Yeni not oluşturma veya var olanı düzenleme.
	•	Header/Navigation
	•	Title: “Yeni Not” veya “Notu Düzenle”
	•	Right Bar Button: “Kaydet”
	•	Left Bar Button: “İptal” (değişiklik varsa uyarı)
	•	İçerik
	•	UIScrollView içinde dikey yığın
	•	UITextField — Başlık (placeholder: “Başlık”)
	•	UITextView — İçerik (placeholder davranışı için custom label)
	•	Character Count (opsiyonel, alt tarafta küçük)
	•	UpdatedAt etiketi (edit modunda gösterilebilir)
	•	Validasyon
	•	Başlık en az 1 karakter (boşsa uyarı ve kaydetme)
	•	Body boş olabilir (serbest)
	•	Etkileşimler
	•	“Kaydet”: Yeni not oluştur veya mevcut notu güncelle → pop
	•	“İptal”: Değişiklik varsa “Kaydetmeden çıkmak istiyor musunuz?” alert’i
	•	Durumlar
	•	Hata (kaydetme başarısız): Alert
	•	Loading (çok kısa, genelde gerekmez)

Klavye & UX Notları:
	•	Klavye açılınca içerik alanının görünür kalması için contentInset ayarı
	•	Return tuşu başlıktan gövdeye geçirebilir
	•	VoiceOver için alan etiketleri

⸻

7) Durum Yönetimi & Hata Senaryoları

7.1 Durumlar
	•	Loaded: Notlar başarıyla yüklendi.
	•	Empty: Not yok → Empty state.
	•	Filtering: Arama aktif, filtreli liste.
	•	Editing/Creating: Editör ekranı açık.

7.2 Hata Örnekleri & Tepkiler
	•	Persistans Yazma Hatası: “Kaydedilemedi. Lütfen tekrar deneyin.” (Alert)
	•	Veri Bozulması (JSON decode): Uygulama başında tespit edilirse güvenli mod: veriyi sıfırlama teklif et (Alert: “Kayıtlı veriler okunamadı. Sıfırlamak ister misiniz?”)

⸻

8) Persistans Tasarımı
	•	Depolama: UserDefaults.standard
	•	Anahtar: "notes_store"
	•	Format: [Note] → Codable ile JSON Data
	•	Sürümleme: (Basit) Model değişirse migration ihtiyacı—başlangıçta şart değil.

⸻

9) Arama & Sıralama
	•	Arama:
	•	Hedef alan: title (ileride body de eklenebilir)
	•	Case-insensitive contains filtre
	•	Sıralama:
	•	Varsayılan: updatedAt desc (yeniden eskiye)
	•	(Opsiyonel) Ayarlardan “createdAt/updatedAt” tercih seçimi

⸻

10) Erişilebilirlik (A11y)
	•	VoiceOver etiketleri: Hücreler “Başlık, Son güncelleme: …” şeklinde okunur.
	•	Dinamik yazı tipi: adjustsFontForContentSizeCategory = true
	•	Kontrast: Empty state ve butonlar yeterli kontrastta.
	•	Hit area: Küçük simgeler min. 44pt.

⸻

11) Analitik (Opsiyonel)
	•	Event’ler: note_created, note_updated, note_deleted, search_used
	•	Parametre örneği: not uzunluğu, karakter sayıları (Kişisel veri tutma!)

⸻

12) Ayarlar (Opsiyonel)
	•	Liste sıralaması tercihi
	•	Önizleme uzunluğu (kısa/orta/uzun)
	•	Geri bildirim & versiyon bilgisi

⸻

13) Test Senaryoları (Temel)
	•	Create: Boş başlık → uyarı; geçerli veri → kaydet ve listede görünmeli.
	•	Update: Başlık değişir → listede anında güncel başlık.
	•	Delete: Swipe → silindikten sonra listeden düşmeli, boşsa empty state.
	•	Search: Var olan başlıklar içinde doğru filtreleme.
	•	Persistans: Uygulama kapanıp açıldığında veriler aynen kalmalı.
	•	Klavye/Scroll: Editörde klavye açılınca alanlar görünür kalmalı.

⸻

14) Genişletme Yol Haritası
	•	Core Data veya File-based storage
	•	Etiket/Kategori (UICollectionView ile filtre sekmesi)
	•	Paylaşım (UIActivityViewController)
	•	Koyu tema
	•	Fotoğraf/ek dosya ekleme
	•	iCloud senkronizasyonu

⸻

15) Teknik Özellikler (Özet)
	•	Platform: iOS 15+ (öneri)
	•	Dil: Swift
	•	UI: UIKit + Auto Layout
	•	Mimari: MVC (Repository ile sade veri katmanı)
	•	Persistans: UserDefaults + Codable
	•	Yerelleştirme: TR/EN (opsiyonel)
	•	Bağımlılık: Yok (3rd party kütüphane kullanmıyoruz)

⸻

