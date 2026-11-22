# OpenFootballBase kadro entegrasyonu

## Kaynak ve lisans
- Kaynak: https://github.com/florentfougeres/OpenFootballBase-Data
- Veri lisansı: CC BY-SA 4.0
- Kadro verisi Wikipedia'dan (CC BY-SA 4.0), kulüp ve doğum metaverisi Wikidata'dan (CC0) derlenir.
- Her kadro kaydında kaynak dil, Wikipedia sayfa başlığı, revizyon numarası ve doğrudan kaynak bağlantısı korunur.
- Uyarlanmış/yeniden dağıtılan kadro verisi CC BY-SA 4.0 koşullarını korumalıdır.
- Lisans: https://creativecommons.org/licenses/by-sa/4.0/

## Kapsam ve veri uyarıları
- Kaynakta sezonluk kadro, forma numarası, mevki ve milliyet bulunabilir.
- Her sezon ve kulüp için kadro bulunmayabilir. Eksik kadro tahminle doldurulmaz.
- Kadro bir sezonluk Wikipedia sayfası görüntüsüdür; kesin transfer sicili veya canlı kadro garantisi değildir.
- Kariyer istatistikleri Wikipedia infobox'larından derlenir ve kaynak dokümanında doğrulanmamış olarak tanımlanır.
- Kulüp armaları ve fotoğraflar bu entegrasyona dahil edilmez; bazı görseller ücretsiz kullanım iznine sahip değildir.
- Oyuncu yetenek puanları, maaş ve piyasa değerleri bu kaynaktan gelmez. Gerçek veri gibi sunulmaz.

## Veri güncelleme
GitHub Actions > Refresh open football data > Run workflow ile en son ücretsiz veri sürümü indirilip Türkiye Süper Lig ve 1. Lig için 2024/25, 2025/26 ve 2026/27 sezonları JSON'a çevrilir. İş akışı sonucu data/openfootballbase/turkey_squads.json dosyası güncellenir.

İş akışı yalnızca elle başlatılır; otomatik zamanlanmış indirme yoktur. Kaynak release arşivi yaklaşık 40 MB'dır. GitHub Actions ücretsiz kullanım kotası içinde çalışır; kota veya platform limitleri aşılırsa işlem başarısız olabilir. Harici ücretli servis kullanılmaz.

## Oyun içinden yükleme
OpenFootballBaseRepository.load_turkey_squads("2024/25", "TUR-SL") çağrısı yerel JSON içinden sezon kadrosunu okur. Dosya depoda yoksa açık hata döndürür; eksik kadro uydurmaz.

## Kaynak gösterme
Oyun içindeki Kaynaklar/Lisanslar ekranında OpenFootballBase bağlantısı, CC BY-SA 4.0 lisansı ve JSON kayıtlarındaki Wikipedia kaynak sayfaları/revizyonları gösterilmelidir.
