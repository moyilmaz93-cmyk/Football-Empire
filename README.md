# Football Empire — Futbol Menajerlik Simülasyonu

Football Empire, FIFA/PES tarzı doğrudan oyuncu kontrolü sunmayan; kulüp yönetimi, taktik, transfer, lig ve kupa organizasyonları üzerine kurulu Android futbol menajerlik oyunudur.

## Temel oyun yaklaşımı
- Kullanıcı sahadaki futbolcuları doğrudan kontrol etmez.
- Pas, şut veya koşu için manuel maç tuşları bulunmaz.
- Maç motoru kararları takım taktiği, diziliş, oyuncu nitelikleri, kondisyon, moral ve maç durumuna göre otomatik üretir.
- 3D maç ekranında futbolcular insan modeli olarak değil; takım rengiyle ayrılan küçük, numaralı işaretler olarak gösterilir.
- Kamera üstten/izometrik maç takibine odaklanır; top ve atak yönü kolayca izlenir.
- Kullanıcı maçı izler, duraklatır ve simülasyon hızını değiştirir.

## Mevcut prototip
- 3D saha ve iki takımda 11'er oyuncu işaretçisi
- 4-3-3 başlangıç dizilişi
- Basit hücum-savunma yerleşimi ve topa sahip olma
- Otomatik pas ve şut kararları
- Basitleştirilmiş top hareketi ve kale alanı gol kontrolü
- Maç saati, duraklatma ve 1x/2x/4x hız kontrolü

Bu bölüm prototip kapsamını anlatır; tam ve gerçekçi bir futbol simülasyonu olduğu anlamına gelmez.

## Gerçek veri entegrasyonu — ilk aşama
- OpenFootball CC0 veri deposu için genel HTTP tabanlı JSON yükleyicisi eklendi; sezon ve lig kodu parametre olarak verilir.
- Maç fikstürü/sonucu, takım listesi ve puan tablosu veri modelleri eklendi.
- OpenFootball'da kaynak dosyası bulunan ligler fikstür katmanına bağlanabilir; dosya yoksa sistem hata döndürür.
- Fikstür verisi ile sezonluk oyuncu kadrosu ayrı veri kaynaklarıdır; bir ligde fikstür bulunması o ligin oyuncu kadrosunun da bulunduğu anlamına gelmez.

## Oyuncu biyografi verisi — OpenFootball Players
- CC0 Türkiye oyuncu biyografi listesi ayrıştırıcısı eklendi.
- İsim, mevki, varsa boy, doğum tarihi ve doğum yeri okunur.
- Bu liste güncel kulüp kadrosu değildir; kulüp ve yetenek puanı uydurulmaz.
- Kod: `scripts/data/openfootball_player_repository.gd`.
- Parser testi: `tests/test_openfootball_player_parser.gd` (Godot üzerinde henüz çalıştırılmadı).

## Sezonluk kulüp kadroları — OpenFootballBase
- OpenFootballBase verisini Türkiye Süper Lig ve 1. Lig için JSON'a dönüştüren ücretsiz veri hattı eklendi.
- Sezon, kulüp, futbolcu, forma numarası, mevki, milliyet ve kaynak revizyonu korunur.
- Veri lisansı CC BY-SA 4.0; kaynak atfı ve ShareAlike koşulları korunmalıdır.
- Eksik kulüp kadroları otomatik doldurulmaz.
- GitHub Actions içinden `Refresh open football data` iş akışı elle çalıştırıldığında veri JSON dosyası oluşturulur.
- Genel lig okuyucusu: `scripts/data/openfootballbase_repository.gd`; ülke/lig bağımsız katalog: `scripts/data/football_data_catalog.gd`.
- Kariyer ekranlarının kullanacağı global servis: `CareerDatabase` (autoload). `CareerDatabase.load_turkey_super_league("2026/27")` mevcut Türkiye paketini açar; diğer ligler `load_career_data(dataset_path, season, competition, country)` ile aynı modele bağlanır.
- Şu an depoda gerçek kadro paketi yalnızca Türkiye Süper Lig için var. 2026/27 kaynağında 516, 2025/26'da 121, 2024/25'te 559 kayıt bulunuyor. 1. Lig için bu pakette kayıt çıkmadı.
- Veri modeli diğer ülkeleri destekleyecek şekilde genelleştirildi; bu, diğer liglerin kadrolarının hazır olduğu anlamına gelmez. Her ülke/lig için lisansı uygun kaynak verisi ayrıca eklenmelidir.

Ayrıntılar: `docs/OPENFOOTBALLBASE_KADRO_ENTEGRASYONU.md` ve `THIRD_PARTY_LICENSES.md`.

## Hedeflenen tam oyun
- Gerçek kulüpler, futbolcular, teknik direktörler, ligler ve kupalar
- Lig fikstürü, puan durumu, kupa turları ve sezon takvimi
- Transfer pazarı, sözleşmeler, maaş bütçesi ve kulüp ekonomisi
- Taktik, diziliş, roller, oyuncu gelişimi, kondisyon ve sakatlıklar
- Maç öncesi planlama, maç içi taktik değişiklikleri ve maç sonrası analiz
- Kariyer başlangıcında mevcut kulüp seçme veya yeni kulüp kurma

## Sıfır maliyet kuralı
- Geliştirme ve oynama için ücretli API, abonelik, veri paketi veya lisans satın alımı yapılmayacak.
- Ücretsiz kaynaklar ve açık lisanslı veriler önceliklidir.
- Bir kaynağın ücretsiz erişilebilir olması, içeriklerinin oyunda kullanılmasına otomatik izin vermez. Kaynağın lisansı ve kullanım koşulları kontrol edilmeden veri veya görsel eklenmez.
- Ücretsiz ve kullanım koşulları uygun kaynak bulunmayan içerikler için ücretli hizmete geçilmez; içerik kapsamı daraltılır veya özgün/temsili içerik kullanılır.
- Hiçbir ücretli servis kullanıcıdan açık onay alınmadan projeye eklenmez.

Veri kaynağı değerlendirme ölçütleri için `docs/VERI_VE_LISANS_POLITIKASI.md` dosyasına bakın.

## Godot'ta açma
Projeyi Godot 4 ile açın ve `scenes/main.tscn` sahnesini çalıştırın.

## Test durumu
GitHub'a yüklenmiş olması, Godot üzerinde derlendiği veya Android cihazda test edildiği anlamına gelmez. Yeni veri sınıfları ve HTTP yükleyicisi Godot editöründe henüz çalıştırılmadı. Android canlı veri isteği için dışa aktarma ayarlarında internet izni gerekir.
