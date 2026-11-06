import SwiftUI

/// 동그란 펫 한 마리. 표정에 따라 눈, 입, 소품이 바뀐다.
/// 잠금화면(단색)과 앱(컬러) 양쪽에서 쓰인다.
struct PetView: View {
    var expression: PetFace
    var tint: Color = .orange

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                // 몸통
                Ellipse()
                    .fill(tint.opacity(0.9))
                    .frame(width: s * 0.86, height: s * 0.78)
                    .offset(y: bodyOffset(s))
                    .rotationEffect(.degrees(expression == .sulky ? 180 : 0))

                // 볼
                if [.happy, .loved, .cheered, .longing].contains(expression) {
                    HStack(spacing: s * 0.38) {
                        Circle().fill(Color.pink.opacity(0.5)).frame(width: s * 0.12)
                        Circle().fill(Color.pink.opacity(0.5)).frame(width: s * 0.12)
                    }
                    .offset(y: s * 0.08)
                }

                // 눈
                if expression != .sulky {
                    HStack(spacing: s * 0.22) {
                        eye(s)
                        eye(s)
                    }
                    .offset(y: -s * 0.06)
                }

                // 입
                mouth(s).offset(y: s * 0.16)

                // 소품
                prop(s)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func bodyOffset(_ s: CGFloat) -> CGFloat {
        switch expression {
        case .tired, .sad: return s * 0.06
        default: return 0
        }
    }

    @ViewBuilder
    private func eye(_ s: CGFloat) -> some View {
        switch expression {
        case .tired:
            // 반쯤 감긴 눈
            Capsule().fill(.black).frame(width: s * 0.11, height: s * 0.035)
        case .sad, .longing:
            ZStack {
                Circle().fill(.black).frame(width: s * 0.1)
                Circle().fill(.white).frame(width: s * 0.04).offset(x: -s * 0.02, y: -s * 0.02)
                if expression == .sad {
                    Circle().fill(Color.blue.opacity(0.7)).frame(width: s * 0.05).offset(y: s * 0.09)
                }
            }
        case .loved, .cheered:
            // ^ ^ 눈
            Text("^").font(.system(size: s * 0.2, weight: .black)).foregroundStyle(.black).offset(y: s * 0.02)
        default:
            Circle().fill(.black).frame(width: s * 0.09)
        }
    }

    @ViewBuilder
    private func mouth(_ s: CGFloat) -> some View {
        switch expression {
        case .happy, .loved, .cheered:
            Arc(start: 20, end: 160).stroke(.black, lineWidth: s * 0.03).frame(width: s * 0.26, height: s * 0.16)
        case .sad, .sulky:
            Arc(start: 200, end: 340).stroke(.black, lineWidth: s * 0.03).frame(width: s * 0.22, height: s * 0.16)
        case .tired:
            Capsule().fill(.black).frame(width: s * 0.12, height: s * 0.03)
        case .busy:
            Capsule().fill(.black).frame(width: s * 0.08, height: s * 0.08)
        case .longing, .sorryFlower:
            Circle().stroke(.black, lineWidth: s * 0.025).frame(width: s * 0.08)
        }
    }

    @ViewBuilder
    private func prop(_ s: CGFloat) -> some View {
        switch expression {
        case .busy:
            Image(systemName: "laptopcomputer").font(.system(size: s * 0.28)).foregroundStyle(.black.opacity(0.8)).offset(x: s * 0.3, y: s * 0.3)
        case .sorryFlower:
            Image(systemName: "camera.macro").font(.system(size: s * 0.3)).foregroundStyle(.pink).offset(x: s * 0.32, y: s * 0.2)
        case .loved:
            Image(systemName: "heart.fill").font(.system(size: s * 0.2)).foregroundStyle(.red).offset(x: s * 0.32, y: -s * 0.3)
        case .cheered:
            Image(systemName: "sparkles").font(.system(size: s * 0.22)).foregroundStyle(.yellow).offset(x: -s * 0.32, y: -s * 0.3)
        case .longing:
            Image(systemName: "moon.stars.fill").font(.system(size: s * 0.2)).foregroundStyle(.yellow.opacity(0.9)).offset(x: s * 0.33, y: -s * 0.3)
        case .tired:
            Text("z z").font(.system(size: s * 0.16, weight: .bold)).foregroundStyle(.black.opacity(0.7)).offset(x: s * 0.3, y: -s * 0.3)
        default:
            EmptyView()
        }
    }
}

/// 입 모양용 호(arc)
struct Arc: Shape {
    var start: Double
    var end: Double
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                 radius: min(rect.width, rect.height) / 2,
                 startAngle: .degrees(start), endAngle: .degrees(end), clockwise: false)
        return p
    }
}

#Preview {
    VStack {
        HStack { PetView(expression: .happy); PetView(expression: .tired); PetView(expression: .sad) }
        HStack { PetView(expression: .sulky); PetView(expression: .loved); PetView(expression: .sorryFlower) }
    }
    .padding()
}
