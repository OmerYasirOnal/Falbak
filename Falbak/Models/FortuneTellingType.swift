import Foundation

enum FortuneTellingType: String, CaseIterable, Identifiable {
    case coffee = "Kahve Falı"
    case horoscope = "Burç Yorumu"
    case palm = "El Falı"
    case water = "Su Falı"
    case tarot = "Tarot"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .coffee:
            return "Kahve fincanınızın fotoğrafını çekerek falınızı öğrenin."
        case .horoscope:
            return "Aylık burç yorumunuzu öğrenin."
        case .palm:
            return "Elinizin fotoğrafını çekerek el falınızı öğrenin."
        case .water:
            return "Su falı ile geleceğinize bakın."
        case .tarot:
            return "Tarot kartları ile geleceğinizi öğrenin."
        }
    }
    
    var icon: String {
        switch self {
        case .coffee:
            return "cup.and.saucer.fill"
        case .horoscope:
            return "moon.stars.fill"
        case .palm:
            return "hand.raised.fill"
        case .water:
            return "drop.fill"
        case .tarot:
            return "creditcard.fill"
        }
    }
} 