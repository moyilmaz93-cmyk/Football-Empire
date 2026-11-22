# OpenFootball veri entegrasyonu

## Lig fikstürleri ve sonuçlar
- Depo: https://github.com/openfootball/football.json
- Lisans: CC0 1.0
- Ham JSON adres şablonu: https://raw.githubusercontent.com/openfootball/football.json/master/{sezon}/{lig_kodu}.json
- Türkiye Süper Lig örneği: `2025-26/tr.1.json`

## Oyuncu biyografi verileri
- Depo: https://github.com/openfootball/players
- Türkiye dosyası: https://github.com/openfootball/players/blob/master/europe/turkey/tr.players.txt
- Lisans: CC0 1.0
- Dosya; oyuncu adı, pozisyon, varsa boy, doğum tarihi ve varsa doğum yerini içerir.
- Kaynak, Türkiye oyuncu listesidir; güncel Süper Lig kulüp kadroları veya oyuncu yetenek puanları değildir.
- Oyuncu kulübü eşleştirmesi yapılmadığı için `club_id` boş bırakılır. Uydurma kulüp bağlantısı kurulmaz.
- Kaynak verisi güncelliğini yitirebilir; canlı kadro doğrulaması olarak kabul edilmemelidir.

## Kod
- `scripts/data/openfootball_repository.gd`: sezon/lig fikstür JSON'unu yükler.
- `scripts/data/openfootball_player_repository.gd`: Türkiye oyuncu metin dosyasını indirir ve satırları çözümler.
- `scripts/models/match_fixture.gd`: maç kaydını çözümler.
- `scripts/models/league_data.gd`: fikstürü, takım listesini ve puan tablosunu üretir.
- `scripts/models/club_data.gd`: kulüp veri modeli.
- `scripts/models/player_data.gd`: oyuncu veri modeli.

## Oyuncu verisini kullanma
Bir Node içinde:
```gdscript
var player_repository := OpenFootballPlayerRepository.new()
add_child(player_repository)
player_repository.players_loaded.connect(_on_players_loaded)
player_repository.load_turkey_players()

func _on_players_loaded(players: Array[PlayerData]) -> void:
	print("Yüklenen oyuncu sayısı: ", players.size())
```

## Parser testleri\n\n- Test dosyası: `tests/test_openfootball_player_parser.gd`\n- Godot 4 kurulu bir ortamda komut: `godot --headless --path . --script tests/test_openfootball_player_parser.gd`\n- Bu test dosyası GitHub'a eklendi ancak bu oturumda Godot motoru bulunmadığından çalıştırılmadı.\n\n## Önemli sınırlar
Bu kaynak gerçek oyuncu biyografisi sağlar; oyuncu yetenek puanı, piyasa değeri, maaş, sözleşme, güncel kulüp veya forma numarası sağlamaz. Bu alanlar başka bir doğrulanmış ücretsiz kaynaktan gelmedikçe boş kalmalıdır. Maç motorunun gerçekçi görünmesi için uydurma puanları gerçek veri gibi göstermeyin.

Android'de canlı indirme için dışa aktarma ayarlarında internet izni etkin olmalıdır. Bu sürümde çevrimdışı önbellek henüz eklenmemiştir.
