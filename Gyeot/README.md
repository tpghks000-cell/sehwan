# 곁 (Gyeot) — 커플 잠금화면 펫

내 잠금화면의 펫이 곧 상대방입니다. 상대가 "피곤"을 찍으면 내 잠금화면 펫이 축 처지고,
내가 "안아주기"를 보내면 상대 폰의 펫이 활짝 핍니다. 하루 연락이 없으면 펫이 등을 돌리고 삐집니다.

## 지금 상태 (0.1 데모)

- 서버 없음. 한 폰에서 "내 역할 / 상대 역할"을 토글해 가며 동작을 확인하는 단계입니다.
- 잠금화면 위젯(원형, 직사각형)과 홈 화면 작은 위젯이 들어 있습니다.
- 다음 단계: 두 폰 동기화(서버), 알림, 펫 종류/옷, 기념일 연출.

## 맥에서 실행하기 (개발 경험 없어도 됩니다)

1. App Store에서 **Xcode** 설치 (용량 크니 와이파이에서).
2. 터미널 앱을 열고 아래를 한 줄씩 붙여넣기:
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   brew install xcodegen
   ```
3. 이 저장소를 받고 프로젝트 생성:
   ```
   git clone https://github.com/tpghks000-cell/sehwan.git
   cd sehwan/Gyeot
   xcodegen
   open Gyeot.xcodeproj
   ```
4. Xcode가 열리면
   - 왼쪽 맨 위 파란 아이콘 **Gyeot** 클릭 → 가운데 **TARGETS > Gyeot** → **Signing & Capabilities** 탭
   - **Team**에서 본인 Apple ID 선택 (없으면 Add an Account). 무료 계정이면 됩니다.
   - 같은 작업을 **TARGETS > GyeotWidget**에도 한 번 더.
5. 아이폰을 케이블로 연결하고, 위쪽 기기 선택에서 본인 아이폰 선택 → **▶ 실행**.
   - 아이폰에서 "신뢰하지 않는 개발자" 뜨면: 설정 → 일반 → VPN 및 기기 관리 → 본인 Apple ID 신뢰.
6. 잠금화면 길게 누르기 → 사용자화 → 잠금화면 → 위젯 추가 → **곁**.

막히면 Xcode 화면 캡처해서 보내주세요.
