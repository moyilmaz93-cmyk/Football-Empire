# Football Empire — Godot 4 Android prototipi

Bu depo, Android hedefli 3D futbol menajerlik oyununun erken geliştirme prototipidir.

## Şu anki prototipte bulunanlar
- Godot 4 tabanlı 3D futbol sahası ve iki adet 11 kişilik takım
- 4-3-3 başlangıç dizilişi
- Basit takım davranışı: hücum yerleşimi, rakip baskısı ve topa yaklaşma
- Topa sahip olma ve oyuncular arasında otomatik pas
- Kaleye şut ve basitleştirilmiş top fiziği
- Kalecinin topun konumuna göre yatay hareketi
- Topun kale alanından geçmesi şartına bağlı gol kontrolü
- 90 dakikalık maç saati (prototipte 1 gerçek saniye = 1 maç dakikası)
- Dokunmatik PAS, ŞUT ve DURAKLAT/DEVAM ET kontrolleri

## Godot'ta açma
1. Godot 4 Android Editor uygulamasını aç.
2. GitHub deposunu ZIP olarak indir veya dosyaları projeye aktar.
3. project.godot dosyasını proje olarak içe aktar.
4. scenes/main.tscn ana sahnesini çalıştır.

## Bilinen sınırlar
Bu hâlâ erken aşama bir oynanış prototipidir; tam futbol simülasyonu değildir.
- Top ve oyuncular için gerçek fizik çarpışmaları henüz yok.
- Faul, ofsayt, taç, korner, penaltı, kart ve oyuncu değişikliği kuralları yok.
- Kaleci animasyonu/kurtarış sistemi ve gerçekçi şut çeşitleri henüz yok.
- Takım taktikleri ve oyuncu özellikleri henüz temel seviyede.
- Kulüp/lig/kariyer, transfer, ekonomi, kayıt sistemi ve gerçek futbolcu veri tabanı henüz eklenmedi.
- Gerçek futbolcu isimleri, kulüp armaları ve lig verileri eklenmeden önce lisans ve veri kaynağı kontrolü yapılmalı.

## Test durumu
Kod GitHub'a kaydedildi ve dosya GitHub üzerinden tekrar okunarak doğrulandı. Bu çalışma ortamında Godot 4 çalıştırılabilir motoru bulunmadığından sahne derleme/çalıştırma testi henüz yapılamadı. Android cihazda Godot 4 Editor ile ilk açılış testi gereklidir.