import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// 상대방이 직접 고르는 오늘의 기분.
enum Mood: String, Codable, CaseIterable, Identifiable {
    case good = "좋음"
    case tired = "피곤"
    case sad = "속상"
    case busy = "바쁨"
    case missYou = "보고싶음"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .good: return "🙂"
        case .tired: return "🥱"
        case .sad: return "🥲"
        case .busy: return "💻"
        case .missYou: return "🥺"
        }
    }
}

/// 내가 상대에게 보낼 수 있는 행동. 펫의 표정을 바꾼다.
enum Action: String, Codable, CaseIterable, Identifiable {
    case feed = "밥 주기"
    case hug = "안아주기"
    case sorry = "사과하기"
    case cheer = "응원하기"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .feed: return "fork.knife"
        case .hug: return "heart.fill"
        case .sorry: return "camera.macro"      // 꽃 모양
        case .cheer: return "hands.clap.fill"
        }
    }
}

/// 잠금화면에 그려지는 펫의 최종 표정. 기분 + 연락 공백 + 받은 행동으로 계산된다.
enum PetFace: String, Codable {
    case happy, tired, sad, busy, longing, sulky, loved, sorryFlower, cheered

    var caption: String {
        switch self {
        case .happy: return "오늘 기분 좋대요"
        case .tired: return "오늘 많이 피곤하대요"
        case .sad: return "속상한 일이 있었대요"
        case .busy: return "정신없이 바쁘대요"
        case .longing: return "보고 싶대요"
        case .sulky: return "하루 종일 연락이 없어서 삐졌어요"
        case .loved: return "안아줘서 행복해해요"
        case .sorryFlower: return "꽃 들고 미안하다고 해요"
        case .cheered: return "응원 받고 힘이 났어요"
        }
    }
}

/// 한 사람 분의 상태. 1차 버전에서는 두 사람 분이 한 폰에 같이 저장된다.
struct PersonState: Codable, Equatable {
    var mood: Mood = .good
    var moodSetAt: Date = .distantPast
    /// 이 사람이 "받은" 마지막 행동
    var receivedAction: Action? = nil
    var receivedAt: Date = .distantPast
}

struct CoupleState: Codable, Equatable {
    var me = PersonState()
    var partner = PersonState()
    var anniversary: Date = Calendar.current.date(byAdding: .day, value: -99, to: .now) ?? .now
    var lastContact: Date = .now
    var myName: String = "나"
    var partnerName: String = "너"

    /// 사귄 지 며칠째인지. 첫날을 1일로 센다.
    var daysTogether: Int {
        let start = Calendar.current.startOfDay(for: anniversary)
        let today = Calendar.current.startOfDay(for: .now)
        return (Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0) + 1
    }

    /// 다음 기념일(100일 단위)까지 남은 날.
    var daysToNextMilestone: (days: Int, milestone: Int) {
        let next = ((daysTogether / 100) + 1) * 100
        return (next - daysTogether, next)
    }

    /// 상대 펫의 표정. 내 잠금화면에 보이는 건 이것.
    func expression(of person: PersonState, now: Date = .now) -> PetFace {
        // 최근 2시간 안에 받은 행동이 있으면 그 반응이 우선
        if let action = person.receivedAction, now.timeIntervalSince(person.receivedAt) < 2 * 3600 {
            switch action {
            case .feed, .hug: return .loved
            case .sorry: return .sorryFlower
            case .cheer: return .cheered
            }
        }
        // 24시간 넘게 아무 신호가 없으면 삐짐
        if now.timeIntervalSince(lastContact) > 24 * 3600 { return .sulky }
        switch person.mood {
        case .good: return .happy
        case .tired: return .tired
        case .sad: return .sad
        case .busy: return .busy
        case .missYou: return .longing
        }
    }
}

/// 앱과 위젯이 같은 저장소를 쓰도록 App Group UserDefaults에 저장한다.
enum PetStore {
    static let appGroup = "group.com.sehwan.gyeot"
    private static let key = "coupleState.v1"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroup) ?? .standard
    }

    static func load() -> CoupleState {
        guard let data = defaults.data(forKey: key),
              let state = try? JSONDecoder().decode(CoupleState.self, from: data) else {
            return CoupleState()
        }
        return state
    }

    static func save(_ state: CoupleState) {
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: key)
        }
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
