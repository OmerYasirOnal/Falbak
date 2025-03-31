import SwiftUI
import PhotosUI

struct FortuneTellingView: View {
    @ObservedObject var viewModel: FortuneViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var showingCamera = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Başlık
                Text(viewModel.selectedFortuneType.rawValue)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                
                // Açıklama
                Text(viewModel.selectedFortuneType.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                // Kamera ve galeri butonları (kahve ve el falı için)
                if viewModel.selectedFortuneType == .coffee || viewModel.selectedFortuneType == .palm {
                    VStack {
                        HStack(spacing: 20) {
                            Button {
                                showingCamera = true
                            } label: {
                                VStack {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 24))
                                    Text("Fotoğraf Çek")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            PhotosPicker(selection: $photoPickerItem, matching: .images) {
                                VStack {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.system(size: 24))
                                    Text("Galeriden Seç")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Seçilen görüntüyü göster
                        if let selectedImage = viewModel.selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                                .padding(.vertical)
                                .overlay(
                                    Button(action: {
                                        viewModel.selectedImage = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                            .background(Circle().fill(Color.black.opacity(0.7)))
                                    }
                                    .padding(8),
                                    alignment: .topTrailing
                                )
                        }
                    }
                }
                
                // Kullanıcı girişi (burç için doğum tarihi, veya diğer fal türleri için özel sorular)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sorunuzu yazın veya detay ekleyin")
                        .font(.headline)
                    
                    TextField("Örn: Kariyer ile ilgili geleceğim nasıl olacak?", text: $viewModel.userInput, axis: .vertical)
                        .lineLimit(3...)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .focused($isInputFocused)
                }
                
                // Hata mesajını göster
                if let errorMessage = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Fal bakma butonu
                Button {
                    isInputFocused = false
                    Task {
                        await viewModel.getFortune()
                    }
                } label: {
                    HStack {
                        Text("Falıma Bak")
                            .fontWeight(.semibold)
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "sparkles")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.gradient)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .purple.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .disabled(viewModel.isLoading)
                
                // Fal sonuçları
                if !viewModel.fortuneResult.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Falınız")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text(viewModel.fortuneResult)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.purple.opacity(0.1))
                            )
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Geri")
                    }
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { image in
                viewModel.selectedImage = image
            }
        }
        .onChange(of: photoPickerItem) { _ in
            Task {
                if let data = try? await photoPickerItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.selectedImage = image
                }
            }
        }
    }
}

// Kamera görünümü için UIViewControllerRepresentable
struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageCaptured: (UIImage) -> Void
        
        init(onImageCaptured: @escaping (UIImage) -> Void) {
            self.onImageCaptured = onImageCaptured
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImageCaptured(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
} 