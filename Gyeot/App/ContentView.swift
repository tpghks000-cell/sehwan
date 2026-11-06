import SwiftUI
import WidgetKit

/// 1차 데모 화면. 서버가 없으므로 "나"와 "상대" 역할을 한 폰에서 전환해 가며 써본다.
struct ContentView: View {
    @State private var state = PetStore.load()
    /// true면 상대방 역할로 조작 중 (상대 폰에서 하는 일을 흉내 냄)
    @State private var actingAsPartner = false
    @State private var toast: String? = nil

    private var other: PersonState { actingAsPartner ? state.me : state.partner }
    private var otherName: String { actingAsPartner ? state.myName : state.partnerName }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    partnerCard
                    moodPicker
                    actions
                    settings
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("곁")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle(isOn: $actingAsPartner) {
                        Text(actingAsPartner ? "상대 역할" : "내 역할")
                    }
                    .toggleStyle(.button)
                }
            }
            .overlay(alignment: .bottom) {
                if let toast {
                    Text(toast)
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(.thinMaterial, in: Capsule())
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear { state = PetStore.load() }
    }

    // MARK: 섹션

    private var header: some View {
        VStack(spacing: 4) {
            Text("\(state.daysTogether)일째")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .monospacedDigit()
            let next = state.daysToNextMilestone
            Text("\(next.milestone)일까지 \(next.days)일 남았어요")
                .font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var partnerCard: some View {
        let exp = state.expression(of: other)
        return VStack(spacing: 12) {
            Text("\(otherName)의 지금")
                .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            PetView(expression: exp)
                .frame(height: 160)
                .animation(.spring(duration: 0.5), value: exp)
            Text(exp.caption).font(.headline)
            if exp == .sulky {
                Text("아무 행동이나 하나 보내면 풀려요").font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }

    private var moodPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("내 오늘 기분").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            Text("상대 잠금화면의 펫 표정이 이걸로 바뀌어요").font(.caption2).foregroundStyle(.tertiary)
            HStack(spacing: 8) {
                ForEach(Mood.allCases) { mood in
                    let selected = (actingAsPartner ? state.partner.mood : state.me.mood) == mood
                    Button {
                        setMood(mood)
                    } label: {
                        VStack(spacing: 4) {
                            Text(mood.emoji).font(.title2)
                            Text(mood.rawValue).font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selected ? Color.accentColor.opacity(0.18) : Color(.secondarySystemBackground),
                                    in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? Color.accentColor : .clear, lineWidth: 1.5))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(otherName)에게 보내기").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(Action.allCases) { action in
                    Button {
                        send(action)
                    } label: {
                        Label(action.rawValue, systemImage: action.symbol)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(action == .sorry ? .pink : .orange)
                }
            }
        }
    }

    private var settings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("설정").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            DatePicker("사귄 날", selection: $state.anniversary, in: ...Date.now, displayedComponents: .date)
                .onChange(of: state.anniversary) { _ in PetStore.save(state) }
            HStack {
                TextField("내 이름", text: $state.myName).textFieldStyle(.roundedBorder)
                TextField("상대 이름", text: $state.partnerName).textFieldStyle(.roundedBorder)
            }
            .onSubmit { PetStore.save(state) }
            Button("연락 끊긴 지 하루 지난 것처럼 만들기 (삐짐 테스트)") {
                state.lastContact = Date.now.addingTimeInterval(-25 * 3600)
                state.me.receivedAction = nil
                state.partner.receivedAction = nil
                PetStore.save(state)
                show("펫이 삐졌어요. 잠금화면을 확인해 보세요")
            }
            .font(.caption)
            Text("잠금화면에 추가하기: 잠금화면 길게 누르기 → 사용자화 → 위젯 추가 → 곁")
                .font(.caption2).foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: 동작

    private func setMood(_ mood: Mood) {
        if actingAsPartner {
            state.partner.mood = mood
            state.partner.moodSetAt = .now
        } else {
            state.me.mood = mood
            state.me.moodSetAt = .now
        }
        state.lastContact = .now
        PetStore.save(state)
        show("\(otherName) 잠금화면 펫이 \(mood.rawValue) 표정이 됐어요")
    }

    private func send(_ action: Action) {
        if actingAsPartner {
            state.me.receivedAction = action
            state.me.receivedAt = .now
        } else {
            state.partner.receivedAction = action
            state.partner.receivedAt = .now
        }
        state.lastContact = .now
        PetStore.save(state)
        show("\(otherName)에게 \(action.rawValue) 보냈어요")
    }

    private func show(_ text: String) {
        withAnimation { toast = text }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { toast = nil }
        }
    }
}

#Preview {
    ContentView()
}
