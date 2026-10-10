import SwiftUI

struct ContentView: View {
    // Persistent User Settings
    @AppStorage("isAimdragOn") private var isAimdragOn = true
    @AppStorage("isFixRecoilOn") private var isFixRecoilOn = true
    @AppStorage("isStabilizerAimOn") private var isStabilizerAimOn = true
    @AppStorage("isHighSensYXOn") private var isHighSensYXOn = false

    @AppStorage("isMaxTouchBoostOn") private var isMaxTouchBoostOn = true
    @AppStorage("isBoostFPSOn") private var isBoostFPSOn = true
    @AppStorage("isBoostTouchFeelOn") private var isBoostTouchFeelOn = true

    @AppStorage("dragSystemLevel") private var dragSystemLevel = 4.0 // Range 1 to 7
    @AppStorage("performanceMode") private var performanceMode = "Performa" // Balance, Performa, Competitive
    @AppStorage("kursorTouchValue") private var kursorTouchValue = 85 // Limit 1 - 120

    // UI Navigation State
    @State private var appState: AppState = .splash
    @State private var showCleanerOverlay = false
    @State private var cleanerResultText = ""
    @State private var showResultAlert = false
    @State private var kursorInputText: String = "85"

    private let cyanGlow = Color(red: 0.0, green: 1.0, blue: 0.85)
    private let purpleGlow = Color(red: 0.62, green: 0.25, blue: 0.98)
    private let cardBackground = Color(red: 0.07, green: 0.09, blue: 0.16).opacity(0.85)

    enum AppState {
        case splash
        case login
        case mainDashboard
    }

    var body: some View {
        ZStack {
            switch appState {
            case .splash:
                SplashScreenView {
                    withAnimation {
                        appState = .login
                    }
                }

            case .login:
                LoginView {
                    withAnimation {
                        appState = .mainDashboard
                    }
                }

            case .mainDashboard:
                mainDashboardView
            }

            // 3-Second Animated Cleaner Modal Overlay
            if showCleanerOverlay {
                CleanerOverlayView { itemsCleaned in
                    showCleanerOverlay = false
                    cleanerResultText = "Successfully cleaned \(itemsCleaned) junk cache items!"
                    showResultAlert = true
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .alert("SENS X IOS OPTIMIZER", isPresented: $showResultAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(cleanerResultText)
        }
    }

    // MARK: - Main Dashboard View
    private var mainDashboardView: some View {
        ZStack {
            // Dark Ambient Glow Background
            Color(red: 0.03, green: 0.04, blue: 0.08)
                .ignoresSafeArea()

            ParticleSystemView(count: 35, color: cyanGlow.opacity(0.5))

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    topBarHeader
                    brandingHeroBanner
                    performanceModeCard
                    togglesCard
                    systemBoostCard
                    dragSystemGliderCard
                    kursorTouchCard
                    cleanerTriggerCard
                    footerBranding
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 36)
            }
        }
    }

    // MARK: - TopBar Header (RANZY NXRPLOIT DEV & SENS X IOS)
    private var topBarHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("RANZY NXRPLOIT DEV")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(2.4)
                    .foregroundStyle(cyanGlow)
                    .shadow(color: cyanGlow.opacity(0.8), radius: 6)

                Text("SENS X IOS")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(.white)
            }

            Spacer()

            // Active Badge & Relock Button
            HStack(spacing: 8) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(cyanGlow)
                        .frame(width: 6, height: 6)
                        .shadow(color: cyanGlow, radius: 4)
                    Text("ACTIVE")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(cyanGlow)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(cyanGlow.opacity(0.12), in: Capsule())
                .overlay(Capsule().stroke(cyanGlow.opacity(0.3), lineWidth: 1))

                Button {
                    withAnimation {
                        appState = .login
                    }
                } label: {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(8)
                        .background(Color.white.opacity(0.08), in: Circle())
                }
            }
        }
    }

    // MARK: - Hero Banner
    private var brandingHeroBanner: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.08, green: 0.12, blue: 0.22), Color(red: 0.04, green: 0.06, blue: 0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(cyanGlow.opacity(0.3), lineWidth: 1)
                )

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(cyanGlow)
                        Text("PREMIUM TOUCH ENGINE")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .tracking(1.8)
                            .foregroundColor(cyanGlow)
                    }

                    Text("SENS X IOS VIP TUNER")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("Aimdrag, Touch Boost, & FPS Response engineered by Ranzy NXRPLOIT DEV.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()

                Image(systemName: "scope")
                    .font(.system(size: 64, weight: .thin))
                    .foregroundStyle(cyanGlow.opacity(0.2))
            }
            .padding(18)
        }
    }

    // MARK: - 3 Performance Modes (Balance, Performa, Competitive)
    private var performanceModeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "PERFORMANCE MODE", icon: "speedometer")

            HStack(spacing: 8) {
                modeButton(title: "Balance", icon: "scale.3d")
                modeButton(title: "Performa", icon: "bolt.fill")
                modeButton(title: "Competitive", icon: "flame.fill")
            }
        }
        .padding(16)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(cyanGlow.opacity(0.18), lineWidth: 1))
    }

    private func modeButton(title: String, icon: String) -> some View {
        let isSelected = performanceMode == title
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                performanceMode = title
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
            }
            .foregroundColor(isSelected ? .black : .white.opacity(0.8))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                isSelected ?
                LinearGradient(colors: [cyanGlow, Color(red: 0.0, green: 0.85, blue: 0.7)], startPoint: .leading, endPoint: .trailing) :
                LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.04)], startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? cyanGlow : Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: isSelected ? cyanGlow.opacity(0.5) : .clear, radius: 8)
        }
    }

    // MARK: - Toggles Card (Aimdrag, Fix Recoil, Stabilizer Aim, High Sens Y and X)
    private var togglesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "AIM & RECOIL CONTROLS", icon: "cross.circle.fill")

            VStack(spacing: 12) {
                glowToggleRow(title: "AIMDRAG", subtitle: "Enhanced dragging smooth lock", isOn: $isAimdragOn)
                glowToggleRow(title: "FIX RECOIL", subtitle: "Screen shaking stabilization", isOn: $isFixRecoilOn)
                glowToggleRow(title: "STABILIZER AIM", subtitle: "Precision touch aiming dampener", isOn: $isStabilizerAimOn)
                glowToggleRow(title: "HIGH SENS Y AND X", subtitle: "Maximized multi-axis sensitivity", isOn: $isHighSensYXOn)
            }
        }
        .padding(16)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(cyanGlow.opacity(0.18), lineWidth: 1))
    }

    // MARK: - System Boost Card (Max Touch Boost, Boost FPS, Boost Touch Feel)
    private var systemBoostCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "SYSTEM BOOST ENGINE", icon: "cpu.fill")

            VStack(spacing: 12) {
                glowToggleRow(title: "MAX TOUCH BOOST", subtitle: "Ultra-low response touch sampling", isOn: $isMaxTouchBoostOn)
                glowToggleRow(title: "BOOST FPS", subtitle: "Thread frame pacing lock", isOn: $isBoostFPSOn)
                glowToggleRow(title: "BOOST TOUCH FEEL", subtitle: "Smooth gesture friction override", isOn: $isBoostTouchFeelOn)
            }
        }
        .padding(16)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(purpleGlow.opacity(0.25), lineWidth: 1))
    }

    // MARK: - Drag System Gliding Slider (Steps 1 to 7)
    private var dragSystemGliderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeader(title: "DRAG SYSTEM", icon: "hand.draw.fill")
                Spacer()
                Text("LEVEL \(Int(dragSystemLevel)) / 7")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(cyanGlow)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(cyanGlow.opacity(0.12), in: Capsule())
            }

            VStack(spacing: 10) {
                Slider(value: $dragSystemLevel, in: 1...7, step: 1)
                    .tint(cyanGlow)

                HStack {
                    ForEach(1...7, id: \.self) { step in
                        Text("\(step)")
                            .font(.system(size: 10, weight: dragSystemLevel == Double(step) ? .black : .bold, design: .monospaced))
                            .foregroundColor(dragSystemLevel == Double(step) ? cyanGlow : .white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(16)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(cyanGlow.opacity(0.18), lineWidth: 1))
    }

    // MARK: - Kursor Touch (Typable / Stepper Limit 1 - 120)
    private var kursorTouchCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeader(title: "KURSOR TOUCH", icon: "cursorarrow.motionlines")
                Spacer()
                Text("LIMIT: 1 - 120")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.5))
            }

            HStack(spacing: 12) {
                // Decrement Button
                Button {
                    if kursorTouchValue > 1 {
                        kursorTouchValue -= 1
                        kursorInputText = "\(kursorTouchValue)"
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(cyanGlow)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(cyanGlow.opacity(0.3), lineWidth: 1))
                }

                // Direct Input Field
                HStack {
                    TextField("1-120", text: $kursorInputText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(cyanGlow)
                        .multilineTextAlignment(.center)
                        .onChange(of: kursorInputText) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if let num = Int(filtered) {
                                if num > 120 {
                                    kursorTouchValue = 120
                                    kursorInputText = "120"
                                } else if num < 1 {
                                    kursorTouchValue = 1
                                    kursorInputText = "1"
                                } else {
                                    kursorTouchValue = num
                                    kursorInputText = "\(num)"
                                }
                            }
                        }
                }
                .frame(height: 44)
                .background(Color.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(cyanGlow.opacity(0.4), lineWidth: 1))

                // Increment Button
                Button {
                    if kursorTouchValue < 120 {
                        kursorTouchValue += 1
                        kursorInputText = "\(kursorTouchValue)"
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(cyanGlow)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(cyanGlow.opacity(0.3), lineWidth: 1))
                }
            }
        }
        .padding(16)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(cyanGlow.opacity(0.18), lineWidth: 1))
        .onAppear {
            kursorInputText = "\(kursorTouchValue)"
        }
    }

    // MARK: - Cleaner All Junks File Trigger Button (3 Seconds Animation)
    private var cleanerTriggerCard: some View {
        Button {
            withAnimation {
                showCleanerOverlay = true
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 18, weight: .bold))

                VStack(alignment: .leading, spacing: 2) {
                    Text("CLEANER ALL JUNKS FILE")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .tracking(1.0)
                    Text("Flush RAM cache & clear temporary storage files (3s Boost)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                }
                Spacer()

                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 22, weight: .bold))
            }
            .foregroundColor(.black)
            .padding(16)
            .background(
                LinearGradient(
                    colors: [cyanGlow, Color(red: 0.0, green: 0.85, blue: 0.75)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .shadow(color: cyanGlow.opacity(0.6), radius: 10)
        }
    }

    // MARK: - Shared Helper Components
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(cyanGlow)
            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1.2)
                .foregroundColor(.white)
        }
    }

    private func glowToggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(cyanGlow)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Footer
    private var footerBranding: some View {
        VStack(spacing: 4) {
            Text("SENS X IOS v2.0 • BY RANZY NXRPLOIT DEV")
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .foregroundColor(cyanGlow.opacity(0.8))

            Text("SUPABASE PROTECTED LICENSE • ALL RIGHTS RESERVED")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.35))
        }
        .padding(.top, 10)
    }
}
