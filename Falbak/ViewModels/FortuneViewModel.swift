import Foundation
import SwiftUI

class FortuneViewModel: ObservableObject {
    @Published var selectedFortuneType: FortuneTellingType = .coffee
    @Published var userInput: String = ""
    @Published var fortuneResult: String = ""
    @Published var isLoading: Bool = false
    @Published var selectedImage: UIImage? = nil
    @Published var errorMessage: String? = nil
    @Published var useSimulatedResponses: Bool = false  // Geliştirme sırasında kolaylık için
    @Published var apiModel: String = "google/gemini-2.5-pro-exp-03-25:free"  // Varsayılan API modeli
    
    private let aiService = AIService()
    
    func getFortune() async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.fortuneResult = ""
            self.errorMessage = nil
        }
        
        // Simülasyon modu aktifse doğrudan simüle yanıtları kullan
        if useSimulatedResponses {
            await getSimulatedFortune()
            return
        }
        
        do {
            let result = try await aiService.getFortuneTelling(
                type: selectedFortuneType,
                prompt: userInput,
                image: selectedImage
            )
            
            DispatchQueue.main.async {
                self.fortuneResult = result
                self.isLoading = false
            }
        } catch {
            // API hatası oluştu, yedek olarak simüle edilmiş yanıtları kullanabiliriz
            DispatchQueue.main.async {
                self.errorMessage = "API bağlantısında hata: \(error.localizedDescription)"
                self.isLoading = false
                
                // Kullanıcıya simüle edilmiş yanıt kullanılabileceğini bildir
                let alert = UIAlertController(
                    title: "Bağlantı Hatası",
                    message: "OpenRouter (Gemini 2.5 Pro) API'sine bağlanırken bir hata oluştu. Yedek yanıtlarımızı kullanmak ister misiniz?",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "Evet", style: .default) { _ in
                    // Simülasyon yanıtını kullan
                    Task {
                        await self.getSimulatedFortune()
                    }
                })
                
                alert.addAction(UIAlertAction(title: "Hayır", style: .cancel))
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(alert, animated: true)
                }
            }
        }
    }
    
    // Simülasyon yanıtları için AIService'in simülasyon metodunu kullan
    private func getSimulatedFortune() async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.fortuneResult = ""
            self.errorMessage = nil
        }
        
        let result = await aiService.simulatedResponse(for: selectedFortuneType, with: userInput)
        
        DispatchQueue.main.async {
            self.fortuneResult = "(Simülasyon modu) " + result
            self.isLoading = false
        }
    }
    
    func clearData() {
        userInput = ""
        fortuneResult = ""
        errorMessage = nil
        selectedImage = nil
    }
    
    // Kullanıcıya API veya simülasyon modunu değiştirme imkanı
    func toggleSimulationMode() {
        useSimulatedResponses.toggle()
    }
} 