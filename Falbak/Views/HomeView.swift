import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = FortuneViewModel()
    @State private var showFortuneTelling = false
    @State private var showSettings = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Başlık ve hoş geldin mesajı
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Falbak")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                            
                            Spacer()
                            
                            Button(action: {
                                showSettings.toggle()
                            }) {
                                Image(systemName: "gear")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                            }
                        }
                        
                        Text("Geleceğe bakmak için bir fal türü seçin")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("OpenRouter - \(viewModel.apiModel)")
                                .font(.caption)
                                .foregroundColor(.purple.opacity(0.7))
                            
                            Spacer()
                            
                            Toggle("Simülasyon", isOn: $viewModel.useSimulatedResponses)
                                .labelsHidden()
                                .tint(.purple)
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Fal tipleri ızgarası
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(FortuneTellingType.allCases) { fortuneType in
                            FortuneTypeCardView(
                                fortuneType: fortuneType,
                                isSelected: viewModel.selectedFortuneType == fortuneType
                            )
                            .onTapGesture {
                                viewModel.selectedFortuneType = fortuneType
                                viewModel.clearData()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Seçilen fal ile devam etme butonu
                    Button {
                        showFortuneTelling = true
                    } label: {
                        HStack {
                            Text("Falıma Baktır")
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .purple.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    // API Bilgisi
                    VStack {
                        if viewModel.useSimulatedResponses {
                            Text("Simülasyon Modu Aktif")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(4)
                        } else {
                            Text("OpenRouter Gemini 2.5 Pro API kullanılıyor")
                                .font(.caption)
                                .foregroundColor(.purple)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationDestination(isPresented: $showFortuneTelling) {
                FortuneTellingView(viewModel: viewModel)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FortuneViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("API Ayarları") {
                    Toggle("Simülasyon Modu", isOn: $viewModel.useSimulatedResponses)
                        .tint(.purple)
                }
                
                Section("API Bilgisi") {
                    VStack(alignment: .leading) {
                        Text("Model: \(viewModel.apiModel)")
                        Text("Sağlayıcı: OpenRouter")
                    }
                }
                
                Section("Hakkında") {
                    Text("Falbak, OpenRouter üzerinden Google'ın Gemini 2.5 Pro modelini kullanarak falcılık yapan bir uygulamadır. Simülasyon modu etkinleştirildiğinde, internet bağlantısı olmadan da kullanılabilir.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tamam") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
} 