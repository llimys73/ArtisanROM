# ArtisanROM — Galaxy Note 20 (Snapdragon, c1q) 포팅 안내

> ⚠️ **실험용 포팅입니다.** 아직 실기기에서 부팅 검증을 하지 않았습니다.
> 첫 플래시 전에 반드시 EFS 백업을 하고, 문제가 생기면 Odin으로 스톡 펌웨어를 다시 올릴 준비를 해 두세요.
> ArtisanROM은 개발자 사전 승인 없이 수정·재배포할 수 없으므로 **개인 사용 용도**로만 쓰세요.

## 1. 지원 기기

| 모델 | 지역 | 지원 |
|---|---|---|
| SM-N981N | 한국 | ✅ (기본값, 싱글 SIM) |
| SM-N9810 | 홍콩/중국 | ✅ (듀얼 SIM, 빌드 옵션 `sim=2`) |
| SM-N981U / U1 / W | 미국/캐나다 | ❌ 부트로더 언락 불가 |
| SM-N981B / N980F | 유럽 등 (엑시노스) | ❌ 이 포팅이 아니라 원래 ArtisanROM c1s 사용 |

## 2. 구성 원리

- **SoC 쪽** (벤더, RIL, DVFS, 파티션 구조, 커널 패치): UN1CA의 **r8q (Galaxy S20 FE 스냅드래곤, 같은 SM8250)** 타깃에서 가져옴
- **본체 쪽** (60Hz FHD+ 패널 밝기 테이블, 카메라 기능, 초음파 지문, S Pen): ArtisanROM의 **c1s (Note 20 엑시노스)** 에서 가져옴
- 커널: UN1CA `kernel_samsung_sm8250` 소스를 **c1q 설정**으로 직접 빌드 (UN1CA는 r8q 커널만 배포함 — r8q 커널은 c1q에서 부팅 불가)

## 3. 첫 플래시 전 확인할 값 (VERIFY)

TWRP에서 `adb shell`로 확인하고, 다르면 `target/c1q/config.sh`를 고치세요.

```sh
blockdev --getsize64 /dev/block/by-name/super   # 11156848640 이어야 함
blockdev --getsize64 /dev/block/by-name/boot    # 67108864 이상이어야 함
getprop ro.boot.bootloader                      # N981NKS... 또는 N9810ZH/ZC...
```

super 크기가 다르면: `TARGET_SUPER_PARTITION_SIZE` = 실제 값, `TARGET_QTI_DYNAMIC_PARTITIONS_SIZE` = 실제 값 − 4194304.

스톡 펌웨어 상태에서 확인 (선택):
```sh
ls /system/etc | grep siop                       # siop_c1q_sm8250 있는지
grep ESE /system/etc/floating_feature.xml        # eSE 칩/COS 이름
```

## 4. 빌드 (GitHub Actions, PC 성능 무관)

### 4-1. 커널
**가장 쉬운 방법**: 미리 빌드된 `boot.img`, `dtbo.img`(한국판 `c1q-kor`)를 ROM 포크의 `target/c1q/kernel-prebuilt/` 폴더에 올리면 끝입니다. 이 경우 아래 1~4단계와 4-2의 `C1Q_KERNEL_REPO` 설정은 건너뜁니다.

직접 빌드하려면:
1. https://github.com/UN1CA/kernel_samsung_sm8250 를 **Fork**
2. 이 패치의 `target/c1q/kernel-build/` 에 있는 `build_kernel.sh` 를 포크 저장소 루트에, `build_kernel_note20.yml` 을 `.github/workflows/` 에 추가 (c1q와 공용)
3. Actions → **Build Note 20 kernel** → device `c1q`, region `kor`(N981N) 또는 `chn`(N9810) → Run
4. 완료되면 Releases의 `c1q-kor`(또는 `c1q-chn`) 태그에 `boot.img`, `dtbo.img`가 생김

### 4-2. ROM
1. https://github.com/ArtisanROM/ArtisanROM 를 Fork하고 `note20q-port.patch` 적용
   (`git am note20q-port.patch` 후 push)
2. 포크 Settings → Secrets and variables → Actions
   - **Secret** `C1Q_FIRMWARE` = `SM-N981N/KOO/<내 IMEI>` (IMEI는 `*#06#`, 앞 8자리만 써도 됨. 일련번호 R로 시작하는 11자리도 가능)
     - N9810이면 `SM-N9810/TGY/<IMEI>`
   - **Variable** `C1Q_KERNEL_REPO` = `https://github.com/<내아이디>/kernel_samsung_sm8250/releases/download/c1q-kor`
3. Actions → **Build Note 20 Snapdragon (c1q / c2q)** → device `c1q`, sim 선택 → Run
4. 완료 후 Artifacts에서 `ArtisanROM-c1q` zip 다운로드 (5일 보관)

## 5. 설치

1. 부트로더 언락 (개발자 옵션 → OEM 잠금 해제 → 다운로드 모드에서 언락). **데이터 전부 삭제됨**
2. Odin으로 **최신 Android 13 스톡 펌웨어** 설치 (벤더/모뎀이 최신이어야 함)
3. c1q용 TWRP 설치, **EFS 백업** (`efs`, `sec_efs`) 후 PC에 복사
4. TWRP → Wipe → **Format Data** (암호화 방식이 FBEv2로 바뀌므로 필수)
5. ROM zip 설치 → 재부팅. 첫 부팅은 5~10분 걸릴 수 있음
   - 이 ROM 설치 후 TWRP는 /data를 복호화하지 못합니다 (정상). 파일 옮기기는 OTG/MTP로.

## 6. 테스트 체크리스트

부팅되면 아래를 확인하고 안 되는 항목을 기록하세요 (`adb logcat`, `/proc/last_kmsg` 첨부).

- [ ] 부팅 / 잠금화면 / 지문 등록(초음파)
- [ ] 통화·문자·LTE/5G 데이터 (RIL 라이브러리는 r8q 것을 사용 — 가장 불확실한 부분)
- [ ] Wi-Fi, 블루투스, NFC/삼성페이
- [ ] 카메라 (광각 12MP, 초광각, 3배 망원 64MP, 전면), 동영상
- [ ] S Pen 필기, 에어 액션
- [ ] 60Hz 화면, 자동 밝기, AOD
- [ ] 스피커 2개, 이어폰, 진동
- [ ] 무선 충전, 역충전, 진동(MAX77705)

## 7. 알려진 제한 / 미포팅

- **UWB**: Note 20(일반)에는 UWB 칩이 없습니다
- **eSE / 삼성페이**: eSE 설정값은 r8q 것을 넣었으므로 3장의 값으로 보정 필요할 수 있음
- **카메라**: r8q 벤더 라이브러리 hex 패치는 c1q 바이너리와 일치할 때만 적용되도록 바꿨습니다(불일치 시 건너뜀)
- **커널**: c1q 전용 드라이버(S Pen, 초음파 지문, MAX77705 진동, FHD 패널, BCM4375 Wi‑Fi, 터치)는 컴파일 검증 완료. `build_kernel.sh`가 VL53L5 헤더 경로 버그와 최신 clang 경고(-Werror)를 자동 처리합니다
- **주사율**: 60Hz 고정 패널이라 가변 주사율은 끔 (ArtisanROM c1s와 동일)
