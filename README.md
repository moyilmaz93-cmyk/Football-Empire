# Football Empire — Futbol Menajerlik Simülasyonu

Football Empire, FIFA/PES tarzı doğrudan oyuncu kontrolü sunmayan; kulüp yönetimi, taktik, transfer, lig ve kupa organizasyonları üzerine kurulu Android futbol menajerlik oyunudur.

## Maç sunumu ve oynanış hedefi
- Kullanıcı sahadaki futbolcuları doğrudan kontrol etmez.
- Pas, şut veya koşu için manuel maç tuşları bulunmaz.
- Maç motoru kararları takım taktiği, diziliş, oyuncu nitelikleri, kondisyon, moral ve maç durumuna göre otomatik üretir.
- 3D maç ekranında futbolcular insan modeli olarak değil; takım rengiyle ayrılan küçük, numaralı işaretler olarak gösterilir.
- Kamera üstten/izometrik maç takibine odaklanır; top ve atak yönü kolayca izlenir.
- Kullanıcı maçı izler, duraklatır ve simülasyon hızını değiştirir.

## Mevcut prototipte bulunanlar
- 3D saha ve iki takımda 11'er oyuncu işaretçisi
- 4-3-3 başlangıç dizilişi
- Basit hücum-savunma yerleşimi ve topa sahip olma
- Otomatik pas ve şut kararları
- Basitleştirilmiş top hareketi ve kale alanı gol kontrolü
- Maç saati, duraklatma ve 1x/2x/4x hız kontrolü

## Hedeflenen tam oyun
- Gerçek kulüpler, futbolcular, teknik direktörler, ligler ve kupalar
- Lig fikstürü, puan durumu, kupa turları ve sezon takvimi
- Transfer pazarı, sözleşmeler, maaş bütçesi ve kulüp ekonomisi
- Taktik, diziliş, roller, oyuncu gelişimi, kondisyon ve sakatlıklar
- Maç öncesi planlama, maç içi taktik değişiklikleri ve maç sonrası analiz
- Kariyer başlangıcında mevcut kulüp seçme veya yeni kulüp kurma

## Gerçek veri ve lisans notu
Gerçek futbolcu/kulüp/lig verileri tek bir kaynaktan varsayılarak eklenmeyecek. Veri sağlayıcısının kullanım şartları, ticari kullanım izni, logo/arma ve görsel hakları kontrol edilmelidir. Lisanssız gerçek veri veya armalar oyuna gömülmeyecek.

## Godot'ta açma
Godot 4.x ile `project.godot` dosyasını içe aktarın ve ana sahneyi çalıştırın. Android hedefi için arayüz ve performans ayrıca cihaz üzerinde test edilmelidir.

## Test durumu
Maç prototipi kodu GitHub'a kaydedildi ve GitHub üzerinden tekrar okundu. Bu çalışma ortamında Godot çalıştırılabilir motoru bulunmadığından sahne derleme/çalıştırma testi yapılamadı. Android cihazda Godot 4 Editor ile test edilmesi gerekir.