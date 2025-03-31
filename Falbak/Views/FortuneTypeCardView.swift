import SwiftUI

struct FortuneTypeCardView: View {
    let fortuneType: FortuneTellingType
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: fortuneType.icon)
                .font(.system(size: 30))
                .foregroundColor(isSelected ? .white : .purple)
            
            Text(fortuneType.rawValue)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
            
            Text(fortuneType.description)
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.purple : Color.purple.opacity(0.1))
                .shadow(color: isSelected ? .purple.opacity(0.5) : .clear, radius: 5)
        )
    }
} 
