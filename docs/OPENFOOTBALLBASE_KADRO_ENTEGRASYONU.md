# OpenFootballBase kadro entegrasyonu

## Kaynak ve lisans
- Kaynak: https://github.com/florentfougeres/OpenFootballBase-Data
- Veri lisansı: CC BY-SA 4.0
- Kadro verisi Wikipedia'dan (CC BY-SA 4.0), kulüp ve doğum metaverisi Wikidata'dan (CC0) derlenir.
- Her kadro kaydında kaynak dil, Wikipedia sayfa başlığı, revizyon numarası ve doğrudan kaynak bağlantısı korunur.
- Uyarlanmış/yeniden dağıtılan kadro verisi CC BY-SA 4.0 koşullarını korumalıdır.
- Lisans: https://creativecommons.org/licenses/by-sa/4.0/

## Mevcut veri kapsamı
- Depoda bulunan paket: `data/openfootballbase/turkey_squads.json`.
- Paket içinde Türkiye Süper Lig için 2024/25: 559, 2025/26: 121, 2026/27: 516 kadro kaydı var.
- Bu pakette Türkiye 1. Lig için kayıt çıkmadı.
- Diğer ülke ve liglerin kadroları henüz depoya eklenmedi.
- Fikstür kaynağı OpenFootball ile kadro kaynağı OpenFootballBase birbirinden bağımsızdır. Fikstür bulunması oyuncu kadrosu bulunduğunu göstermez.

## Genel mimari
- `OpenFootballBaseRepository.load_squads(dataset_path, season, competition)` ülke/lig bağımsız JSON yükler.
- `FootballDataCatalog` kayıtları `ClubData` ve `PlayerData` modellerine dönüştürür.
- `CareerDatabase` autoload servisi, kariyer/klüp seçimi ekranlarının kullanacağı ortak veri erişim noktasıdır.
- Türkiye örneği: `CareerDatabase.load_turkey_super_league("2026/27")`.
- Başka bir lig için aynı şema ile veri paketi eklendiğinde: `CareerDatabase.load_career_data("res://data/...", "2026/27", "LEAGUE-CODE", "Country")`.
- Oyuncu mevkileri ortak oyun formatına çevrilir: GK, DEF, MID, FWD. Kaynaktaki özgün mevki ayrıca korunur.
- Kaynakta eksik olan oyuncu/klüp kaydı uydurulmaz. Kaynak yetenek puanı vermediği için oyuncu yetenekleri bu entegrasyonda boş kalır.

## Veri güncelleme
GitHub Actions > Refresh open football data > Run workflow ile ücretsiz kaynak arşivi indirilip Türkiye Süper Lig verisi JSON'a çevrilir. İş akışı elle başlatılır; ücretli servis kullanmaz.

## Kaynak gösterme
Oyun içindeki Kaynaklar/Lisanslar ekranında OpenFootballBase bağlantısı, CC BY-SA 4.0 lisansı ve JSON kayıtlarındaki Wikipedia kaynak sayfaları/revizyonları gösterilmelidir.
