# OpenFootball veri entegrasyonu

## Kaynak
- Depo: https://github.com/openfootball/football.json
- Lisans: CC0 1.0 (deponun veri ve şeması için)
- Ham JSON adres şablonu: https://raw.githubusercontent.com/openfootball/football.json/master/{sezon}/{lig_kodu}.json
- Örnek: `2025-26/tr.1.json` (Türkiye Süper Lig dosyası 2025-26 klasöründe listeleniyor)

OpenFootball Avrupa deposu Türkiye Süper Lig ve 1. Lig fikstür/sonuç verilerini kapsadığını belirtiyor. Bununla birlikte, football.json deposunun 2026-27 klasöründeki mevcut dosya listesinde Türkiye dosyası görünmüyor. Bu nedenle 2026-27 Türkiye verisinin yayınlandığı varsayılmamalı; uygulama kaynakta olmayan dosyayı hata olarak göstermelidir.

## Kod
`scripts/data/openfootball_repository.gd` HTTP üzerinden seçilen sezon ve lig JSON dosyasını alır.
- `scripts/models/match_fixture.gd`: maç kaydını çözümler.
- `scripts/models/league_data.gd`: fikstürü, takım listesini ve puan tablosunu üretir.
- `scripts/models/club_data.gd` ve `player_data.gd`: kulüp/oyuncu veri modelleridir.

## Kullanım örneği
Bir Node içinde:
```gdscript
var repository := OpenFootballRepository.new()
add_child(repository)
repository.league_loaded.connect(_on_league_loaded)
repository.load_failed.connect(_on_data_error)
repository.load_league("2025-26", "tr.1")
```

## Sınırlar
Bu entegrasyon fikstür ve sonuç verisidir; oyuncu kadrosu, oyuncu yetenek puanları, armalar ve forma görsellerini sağlamaz. Bunlar ayrı, ücretsiz ve açık kullanım koşulları doğrulanmış kaynaklardan alınmalıdır. CC0 veri lisansı, üçüncü taraf marka/arma/görsel haklarını otomatik olarak kapsamaz.

Android'de canlı indirme için dışa aktarma ayarlarında internet izni etkin olmalıdır. Çevrimdışı oynanabilmesi için indirilen veri daha sonra uygulama içinde yerel olarak önbelleğe alınmalıdır; bu aşamada önbellek özelliği henüz eklenmemiştir.
