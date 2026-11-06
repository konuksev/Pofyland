# Pofyland

Claude Code oturumlarını Mac'te ve telefonda canlı izlediğin, bekleyen izinlere uzaktan cevap verdiğin menü çubuğu uygulaması.

Bu depo yalnızca **indirilecek sürümleri** tutar. Kaynak kod ayrı bir depoda.

## Kurulum

**Gerekenler:** macOS 13+, Apple Silicon (M1 ve sonrası), [Claude Code](https://claude.com/claude-code) kurulu (`claude` komutu çalışıyor olmalı).

1. [Son sürümden](https://github.com/konuksev/Pofyland/releases/latest) `Pofyland-…-arm64.dmg` dosyasını indir.
2. Aç, **Pofyland**'ı **Applications** klasörüne sürükle.
3. Uygulama henüz Apple imzalı değil, bu yüzden ilk açılışta macOS onu engeller:
   - Pofyland'ı aç. "Apple doğrulayamadı" uyarısında **Bitti**'ye bas.
   - **Sistem Ayarları → Gizlilik ve Güvenlik**'e git, en alttaki *"Pofyland engellendi"* satırında **Yine de Aç**'a bas, parolanı gir.
   - Ya da Terminal'de tek komut: `xattr -dr com.apple.quarantine /Applications/Pofyland.app`
4. İlk açılış sihirbazı bildirim izni ister ve Claude eklentisini kurar.

Yeni sürüm çıkınca uygulama günde bir kez buraya bakar ve haber verir.

## Kaldırma
Pofyland menüsü → **Kaldır**.

## Sorun / öneri
Bir sorun ya da önerin varsa bu depoda [Issue](https://github.com/konuksev/Pofyland/issues) aç.
