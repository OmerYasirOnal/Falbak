# Falbak - iOS Fal Uygulaması

Falbak, yapay zeka destekli bir iOS fal uygulamasıdır. Kullanıcılar farklı fal türleri arasından seçim yapabilir, sorularını sorabilir ve AI tarafından oluşturulan kişiselleştirilmiş yanıtlar alabilirler.

## Özellikler

- **Çoklu Fal Türü**: Kahve falı, tarot, burç yorumu, el falı ve su falı
- **AI Entegrasyonu**: OpenRouter API üzerinden Google Gemini 2.5 Pro modeli ile entegrasyon
- **Fotoğraf Ekleme**: Kahve fincanı, el vb. fotoğraflar ekleyerek daha kişiselleştirilmiş fal yorumları
- **Çevrimdışı Mod**: İnternet bağlantısı olmadığında simülasyon modu
- **Kullanıcı Dostu Arayüz**: SwiftUI ile oluşturulmuş modern ve sezgisel arayüz

## Gereksinimler

- iOS 18.2 veya üzeri
- Xcode 14.0 veya üzeri
- Swift 5.0
- İnternet bağlantısı (çevrimiçi özellikler için)

## Kurulum

1. Repository'yi klonlayın:
```bash
git clone https://github.com/username/Falbak.git
```

2. Xcode'da Falbak.xcodeproj dosyasını açın.

3. Uygulamayı bir simülatör veya gerçek cihazda çalıştırın.

## API Kullanımı

Uygulama, OpenRouter API üzerinden Google'ın Gemini 2.5 Pro modeline bağlanır. API anahtarınızı `AIService.swift` dosyasında güncelleyebilirsiniz:

```swift
private let apiKey = "SİZİN_API_ANAHTARINIZ"
```

## Katkıda Bulunma

1. Bu repository'yi fork edin
2. Yeni bir feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## Lisans

Bu proje MIT Lisansı altında lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakın.

## İletişim

Ömer Yasir Önal - [@omeryasironal](https://twitter.com/omeryasironal)

Proje Linki: [https://github.com/username/Falbak](https://github.com/username/Falbak) 