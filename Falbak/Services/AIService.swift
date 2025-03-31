import Foundation
import SwiftUI

class AIService {
    // OpenRouter API endpoint
    private let apiEndpoint = "https://openrouter.ai/api/v1/chat/completions"
    private let apiKey = "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"
    private let modelName = "google/gemini-2.5-pro-exp-03-25:free"
    
    func getFortuneTelling(type: FortuneTellingType, prompt: String, image: UIImage? = nil) async throws -> String {
        // OpenRouter API implementasyonu
        let url = URL(string: apiEndpoint)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("Falbak iOS Uygulaması", forHTTPHeaderField: "HTTP-Referer")
        request.addValue("Falbak", forHTTPHeaderField: "X-Title")
        
        let promptText = createPromptForType(type, userPrompt: prompt)
        var messages: [[String: Any]] = [
            ["role": "user", "content": promptText]
        ]
        
        // Eğer görüntü varsa, Base64 formatında ekle
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.7) {
            let base64String = imageData.base64EncodedString()
            messages = [
                [
                    "role": "user", 
                    "content": [
                        ["type": "text", "text": promptText],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64String)"]]
                    ]
                ]
            ]
        }
        
        let requestBody: [String: Any] = [
            "model": modelName,
            "messages": messages
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // HTTP yanıt kodunu kontrol et
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let errorData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let errorMessage = errorData?["error"] as? [String: Any]
            let message = errorMessage?["message"] as? String ?? "API hatası: \(httpResponse.statusCode)"
            throw NSError(domain: "OpenRouterAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        let responseJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let choices = responseJSON?["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        } else if let error = responseJSON?["error"] as? [String: Any],
                  let message = error["message"] as? String {
            throw NSError(domain: "OpenRouterAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        throw NSError(domain: "OpenRouterAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Yanıt işlenemedi"])
    }
    
    // Fal tipine göre uygun prompt oluştur
    private func createPromptForType(_ type: FortuneTellingType, userPrompt: String) -> String {
        var basePrompt = ""
        
        switch type {
        case .coffee:
            basePrompt = "Sen bir kahve falı uzmanısın. Yüklenen resim bir kahve fincanı. Bu kahve fincanına bakarak bir fal yorumu yap."
        case .horoscope:
            basePrompt = "Sen bir astrolog uzmanısın. Burç yorumu talep ediliyor."
        case .palm:
            basePrompt = "Sen bir el falı uzmanısın. Yüklenen resim bir el. Bu elin çizgilerine bakarak bir fal yorumu yap."
        case .water:
            basePrompt = "Sen bir su falı uzmanısın. Su falına göre bir yorum yap."
        case .tarot:
            basePrompt = "Sen bir tarot kartı uzmanısın. Tarot kartlarına göre bir yorum yap."
        }
        
        return basePrompt + "\n\nKullanıcı sorusu veya ek bilgi: " + userPrompt + "\n\nLütfen detaylı ve pozitif bir fal yorumu yap. Yanıtını Türkçe olarak ver."
    }
    
    // Yedek olarak simülasyon fonksiyonunu da tutalım
    func simulatedResponse(for type: FortuneTellingType, with prompt: String) async -> String {
        // Gerçek bir API olmadığı için şu an statik yanıtlar kullanıyoruz
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 saniye gecikme ekle
        
        let prompts = ["Aşk", "kariyer", "sağlık", "para", "aile", "gelecek", "eğitim"]
        let promptLower = prompt.lowercased()
        
        var focusArea = prompts.first(where: { promptLower.contains($0.lowercased()) }) ?? "genel"
        focusArea = focusArea.lowercased()
        
        switch type {
        case .coffee:
            switch focusArea {
            case "aşk":
                return "Kahve fincanınızda gördüğüm şekiller, yakın zamanda aşk hayatınızda heyecanlı gelişmeler olacağını gösteriyor. Fincanın kenarındaki kalp şekli, romantik bir buluşma ya da var olan ilişkinizde daha derin bir bağ kurulacağını işaret ediyor. Telvenin dibinde oluşan iz, geçmişteki bir ilişkinin etkisinden tamamen kurtulduğunuzu ve yeni başlangıçlara hazır olduğunuzu gösteriyor."
            case "kariyer":
                return "Fincanınızdaki şekiller, kariyer hayatınızda önemli bir ilerleme kaydedeceğinizi gösteriyor. Yakın zamanda beklenmedik bir iş teklifi alabilir veya uzun süredir beklediğiniz bir terfi gerçekleşebilir. Fincanın ortasındaki merdiven şekli, adım adım yükseleceğinizi simgeliyor. Önümüzdeki üç ay içinde mesleki becerilerinizi gösterme fırsatı bulacaksınız."
            case "para":
                return "Fincanınızda para ve bolluk işaretleri görüyorum. Telvenin yan tarafında oluşan yol şekli, finansal açıdan rahatlamaya doğru ilerlediğinizi gösteriyor. Yakın zamanda beklenmedik bir gelir elde edebilirsiniz. Ancak fincanın alt kısmındaki dağınık şekiller, harcamalarınıza dikkat etmeniz gerektiğini de hatırlatıyor. Akıllı yatırımlar yaparsanız, maddi durumunuz yakın gelecekte önemli ölçüde iyileşecek."
            default:
                return "Kahve fincanınızdaki şekiller genel olarak olumlu enerjilerle dolu. Önünüzdeki dönemde hayatınızda güzel gelişmeler olacak. Fincanın sağ tarafındaki yıldız şekli, yakında alacağınız güzel bir haberi işaret ediyor. Fincanın ortasındaki yol ise, yeni bir başlangıcı simgeliyor. Önümüzdeki haftalarda karşınıza çıkacak fırsatları değerlendirmeniz, hayatınızda önemli değişiklikler yaratabilir. Ayrıca yakın çevrenizden biriyle olan ilişkiniz daha da güçlenecek."
            }
        case .horoscope:
            switch focusArea {
            case "aşk":
                return "Bu ay aşk hayatınızda Venüs'ün etkisiyle beklenmedik gelişmeler yaşayabilirsiniz. Yalnızsanız, sosyal ortamlarda tanışacağınız biri hayatınızı değiştirebilir. İlişkiniz varsa, partnerinizle aranızdaki bağ daha da güçlenecek. Ay ortasında yaşanabilecek küçük anlaşmazlıkları iletişim kurarak kolayca aşabilirsiniz. Ayın son haftasında romantik sürprizlere açık olun."
            case "kariyer":
                return "Bu ay kariyerinizde Mars'ın olumlu etkisi görülüyor. İş hayatınızda uzun zamandır beklediğiniz fırsatlar nihayet kapınızı çalabilir. Üstlerinizin dikkatini çekecek bir proje üzerinde çalışabilirsiniz. Ay ortasında iş temponuz artabilir, ancak göstereceğiniz çaba ve kararlılık, ileride büyük başarılara dönüşecek. Ayın sonunda alacağınız bir haber, kariyer hedeflerinizi gözden geçirmenize neden olabilir."
            case "sağlık":
                return "Bu ay sağlığınızla ilgili olarak Jüpiter'in koruyucu etkisi altındasınız. Enerjiniz yüksek olacak, ancak bu enerjiyi doğru yönetmelisiniz. Ay başında düzenli egzersiz ve dengeli beslenme rutinlerinize dikkat edin. Orta haftada mental sağlığınıza özen göstermek için meditasyon veya yoga gibi aktivitelere yönelebilirsiniz. Ayın sonunda, sağlık kontrollerinizi yaptırmak için uygun bir zaman olabilir."
            default:
                return "Bu ay genel olarak birçok gezegen sizin burcunuzu olumlu etkiliyor. Hayatınızın her alanında ilerlemeler kaydedebilirsiniz. Özellikle ayın ilk haftası, yeni başlangıçlar için ideal bir zaman. Finansal konularda dikkatli planlar yaparsanız, maddi açıdan rahat bir ay geçirebilirsiniz. Sosyal çevreniz genişleyecek ve yeni insanlarla tanışacaksınız. Ay sonunda, uzun zamandır düşündüğünüz bir konuda nihayet karar verme aşamasına gelebilirsiniz. İçgüdülerinizi dinleyin ve kalbinizin sesini takip edin."
            }
        case .palm:
            switch focusArea {
            case "aşk":
                return "El çizgilerinizde güçlü bir kalp çizgisi görüyorum, bu duygusal derinliğinizi ve sevgi dolu bir kişiliğe sahip olduğunuzu gösteriyor. Kalp çizgisinin parlaklığı, aşk hayatınızda yakın zamanda önemli bir dönüm noktası yaşayacağınızı işaret ediyor. Evliyseniz ilişkinizde yeni bir sayfanın açılacağını, bekarseniz sizi derinden etkileyecek biriyle tanışabileceğinizi gösteriyor. El ayasındaki ada şekli, duygusal bağlılık konusunda güçlü olduğunuzu gösteriyor."
            case "kariyer":
                return "Kafa çizginiz ve kader çizginiz arasındaki güçlü bağlantı, kariyer konusunda stratejik düşünme yeteneğinizi gösteriyor. Kader çizgisinin derinliği, mesleğinizde ilerleme kaydedeceğinizi ve başarıya ulaşacağınızı işaret ediyor. El ayasındaki üçgen şekli, yaratıcı düşünce ve problem çözme konusundaki yeteneğinizi vurguluyor. Önümüzdeki 6 ay içinde kariyerinizde önemli bir fırsat karşınıza çıkabilir, hazırlıklı olun."
            case "sağlık":
                return "Yaşam çizginizin uzunluğu ve netliği, sağlıklı ve uzun bir ömrünüz olacağını gösteriyor. El ayasınızdaki çizgiler arasındaki dengeli dağılım, fiziksel ve zihinsel sağlığınızın dengede olduğunu işaret ediyor. Ancak stresle başa çıkma konusunda biraz zorluk yaşayabilirsiniz, bu yüzden rahatlama teknikleri öğrenmenizde fayda var. Güneş tepesindeki çizgiler, pozitif düşüncenin sağlığınız üzerindeki olumlu etkisini gösteriyor."
            default:
                return "El çizgilerinizde görülen şekiller ve hatlar, dengeli ve uyumlu bir hayat sürdüğünüzü gösteriyor. Yaşam çizginiz güçlü ve uzun, bu size sağlıklı ve enerjik bir ömür vaat ediyor. Kafa çizginiz ve kalp çizginiz arasındaki dengeli ilişki, duygusal ve mantıksal kararlar arasında iyi bir denge kurabildiğinizi gösteriyor. Kader çizginizin belirginliği, hayatınızda belirli bir amaca doğru ilerlediğinizi işaret ediyor. El ayasınızdaki dağ bölgelerinin belirginliği, çeşitli yeteneklere sahip olduğunuzu ve bu yetenekleri başarılı bir şekilde kullanabileceğinizi gösteriyor. Önümüzdeki iki yıl içinde hayatınızda olumlu değişiklikler olacak."
            }
        case .water:
            switch focusArea {
            case "aşk":
                return "Su falınızda oluşan dalgalı şekiller, duygusal hayatınızdaki değişimleri gösteriyor. Suyun yüzeyindeki kalp şeklindeki dalgalanma, yakın zamanda aşk hayatınızda yaşanacak olumlu gelişmelere işaret ediyor. Eğer bir ilişkiniz varsa, ilişkiniz daha derin ve anlamlı bir seviyeye taşınabilir. Bekarsanız, sizi derinden etkileyecek biriyle karşılaşabilirsiniz. Su yüzeyindeki parlaklık, duygusal açıdan aydınlanma yaşayacağınızı gösteriyor."
            case "kariyer":
                return "Su falınızda oluşan yükselen kabarcıklar, kariyer hayatınızda yükselişe geçeceğinizi gösteriyor. Suyun dibinde toplanan kristaller, yakın zamanda maddi kazanç elde edeceğinize işaret ediyor. İş hayatınızda yeni fırsatlar kapınızı çalabilir, bu fırsatları değerlendirmek için hazırlıklı olun. Su yüzeyinde oluşan daire şekilleri, yeni iş bağlantıları kuracağınızı ve bu bağlantıların size fayda sağlayacağını gösteriyor."
            case "para":
                return "Su falınızda oluşan parlak ve yoğun kristaller, maddi durumunuzun yakın zamanda iyileşeceğine işaret ediyor. Suyun hareketleri, para akışınızın artacağını gösteriyor. Beklenmedik bir yerden gelir elde edebilirsiniz. Su yüzeyindeki dalgalanmalar, finansal kararlarınızda dikkatli olmanız gerektiğini hatırlatıyor. Doğru yatırımlar yaparsanız, maddi açıdan rahat bir döneme girebilirsiniz."
            default:
                return "Su falınızda oluşan şekiller, önünüzdeki dönemde hayatınızda pozitif değişimler olacağını gösteriyor. Suyun berraklığı, zihinsel netlik kazanacağınıza işaret ediyor. Yakın zamanda alacağınız bir karar, hayatınızı olumlu yönde değiştirebilir. Su yüzeyindeki dalgalanmalar, zaman zaman duygusal iniş çıkışlar yaşayabileceğinizi, ancak bu durumların geçici olduğunu gösteriyor. Hayatınıza girecek yeni insanlar, size farklı bakış açıları kazandıracak. Önümüzdeki üç ay içinde, uzun zamandır beklediğiniz bir haber alabilirsiniz."
            }
        case .tarot:
            switch focusArea {
            case "aşk":
                return "Aşıklar kartı ve Kupa Ası sizin için çıktı. Bu kartlar, aşk hayatınızda yeni ve güçlü bir bağın kurulacağını gösteriyor. Mevcut bir ilişkiniz varsa, ilişkiniz daha derin bir seviyeye taşınabilir ve karşılıklı anlayış artabilir. Bekarsanız, sizi derinden etkileyecek biriyle tanışma olasılığınız yüksek. Aşıklar kartı, önünüzdeki dönemde alacağınız kararların duygusal hayatınızı şekillendireceğini hatırlatıyor. Seçimlerinizi yaparken kalbinizin sesini dinlemelisiniz."
            case "kariyer":
                return "Asaların Kralı ve Dünya kartları sizin için çıktı. Bu kartlar, kariyer hayatınızda liderlik pozisyonuna yükseleceğinizi ve hedeflerinize ulaşacağınızı gösteriyor. Asaların Kralı, yaratıcı gücünüzü ve kararlılığınızı temsil eder. Önümüzdeki dönemde iş hayatınızda inisiyatif almanız ve liderlik etmeniz gereken durumlarla karşılaşabilirsiniz. Dünya kartı ise, çabalarınızın meyvesini toplayacağınızı ve kariyer hedeflerinize ulaşacağınızı işaret ediyor. Yeni iş fırsatları karşınıza çıkabilir, değerlendirmek için hazırlıklı olun."
            case "para":
                return "Pentagram Ası ve İmparatoriçe kartları sizin için çıktı. Bu kartlar, maddi konularda bolluk ve bereket dönemine gireceğinizi gösteriyor. Pentagram Ası, yeni finansal başlangıçları ve maddi kaynaklardaki artışı temsil eder. Yakın zamanda beklenmedik bir gelir elde edebilir veya finansal bir fırsat yakalayabilirsiniz. İmparatoriçe kartı ise, bolluk ve üretkenliği simgeler. Bu kart, yaptığınız yatırımların karşılığını alacağınızı ve maddi açıdan rahatlayacağınızı gösteriyor. Ancak paranızı akıllıca yönetmek ve gelecek için tasarruf etmek önemli olacak."
            default:
                return "Kule, Kâhin ve Yıldız kartları sizin için çıktı. Bu kartlar, hayatınızda önemli bir değişim sürecinden geçeceğinizi gösteriyor. Kule kartı, beklenmedik değişimleri ve eski yapıların yıkılmasını temsil eder. Hayatınızdaki bazı eski ve işlevsiz düzenler sona erebilir, ancak bu değişimler yeni başlangıçlar için alan açacak. Kâhin kartı, içgüdülerinize ve sezgilerinize güvenmeniz gerektiğini hatırlatıyor. İçinizdeki bilgeliği dinlemek, bu dönemde size rehberlik edecek. Yıldız kartı ise, zorlu değişimlerden sonra gelen umut ve yenilenmeyi temsil eder. Önünüzdeki dönemde, zorluklardan sonra huzur ve dengeye kavuşacaksınız. Bu üç kart bir arada, zorlu bir değişim sürecinden geçerek olumlu bir geleceğe doğru ilerlediğinizi gösteriyor."
            }
        }
    }
} 
