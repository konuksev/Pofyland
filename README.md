# Pofyland

Claude Code oturumlarını Mac'te ve telefonda canlı izlediğin, bekleyen izinlere uzaktan cevap verdiğin menü çubuğu uygulaması.

Bu depo yalnızca **indirilecek sürümleri** ve kurulum betiğini tutar. Kaynak kod ayrı bir depoda.

## Kurulum (tek komut)

**Gerekenler:** macOS 13+ (Apple Silicon ya da Intel), [Claude Code](https://claude.com/claude-code) kurulu (`claude` komutu çalışıyor olmalı).

Terminal'i aç, şunu yapıştır, Enter'a bas:

```sh
curl -fsSL https://raw.githubusercontent.com/konuksev/Pofyland/main/install.sh | sh
```

Betik en son sürümün dmg'sini indirir, **Pofyland**'ı **Applications**'a kopyalar, karantina damgasını kaldırır ve açar.
`sudo` istemez, yalnızca uygulama klasörüne yazar. İlk açılış sihirbazı bildirim izni ister ve Claude eklentisini kurar.

Seçenekler: `POFYLAND_VERSION=v1.0.1` (belirli sürüm), `POFYLAND_DEST=~/Applications`, `POFYLAND_NO_OPEN=1`.

## Elle kurulum

1. [Son sürümden](https://github.com/konuksev/Pofyland/releases/latest) işlemcine uygun dosyayı indir: `Pofyland-…-arm64.dmg` (Apple Silicon) ya da `Pofyland-…-x86_64.dmg` (Intel).
2. Aç, **Pofyland**'ı **Applications** klasörüne sürükle.
3. Uygulama henüz Apple imzalı değil, bu yüzden ilk açılışta macOS onu engeller:
   - Pofyland'ı aç. "Apple doğrulayamadı" uyarısında **Bitti**'ye bas.
   - **Sistem Ayarları → Gizlilik ve Güvenlik**'e git, en alttaki *"Pofyland engellendi"* satırında **Yine de Aç**'a bas, parolanı gir.
   - Ya da Terminal'de tek komut: `xattr -dr com.apple.quarantine /Applications/Pofyland.app`
4. İlk açılış sihirbazı bildirim izni ister ve Claude eklentisini kurar.

Yeni sürüm çıkınca uygulama günde bir kez buraya bakar ve haber verir. Güncellemek için kurulum komutunu yeniden çalıştırmak yeter.

## Kaldırma
Pofyland menüsü → **Kaldır**.

## Sorun / öneri
Bir sorun ya da önerin varsa bu depoda [Issue](https://github.com/konuksev/Pofyland/issues) aç.
