import SwiftUI

struct SplashScreenView: View {
    let onFinish: () -> Void
    
    @State private var progress: Double = 0.0
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0.0
    @State private var glowPulse: Bool = false
    @State private var statusText: String = "INITIALIZING CORE SYSTEM..."
    
    private let cyanGlow = Color(red: 0.0, green: 1.0, blue: 0.85)
    private let purpleGlow = Color(red: 0.62, green: 0.25, blue: 0.98)

    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background Base
            Color(red: 0.02, green: 0.03, blue: 0.06)
                .ignoresSafeArea()
            
            // Particle Canvas
            ParticleSystemView(count: 45, color: cyanGlow)

            // Neon Radial Glow Behind Logo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [cyanGlow.opacity(glowPulse ? 0.35 : 0.15), purpleGlow.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 200
                    )
                )
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowPulse)

            VStack(spacing: 30) {
                Spacer()

                // Animated Logo Box
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 130, height: 130)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(
                                    LinearGradient(
                                        colors: [cyanGlow, purpleGlow, cyanGlow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2.5
                                )
                                .shadow(color: cyanGlow.opacity(0.8), radius: glowPulse ? 15 : 6)
                        )

                    VStack(spacing: 4) {
                        Image(systemName: "bolt.shield.fill")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [cyanGlow, .white],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: cyanGlow, radius: 10)
                        
                        Text("SENS X")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // Branding Text
                VStack(spacing: 8) {
                    Text("RANZY NXRPLOIT DEV")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(3.5)
                        .foregroundStyle(cyanGlow)
                        .shadow(color: cyanGlow.opacity(0.9), radius: 8)

                    Text("SENS X IOS")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .tracking(2.0)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, cyanGlow.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: cyanGlow.opacity(0.5), radius: 12)

                    Text("ULTIMATE TOUCH & FPS SYSTEM")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(2.0)
                        .foregroundColor(Color.white.opacity(0.5))
                }
                .opacity(logoOpacity)

                Spacer()

                // 5-Second Progress Bar Container
                VStack(spacing: 12) {
                    HStack {
                        Text(statusText)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(cyanGlow)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 40)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [cyanGlow, purpleGlow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * CGFloat(progress), height: 8)
                                .shadow(color: cyanGlow, radius: 8)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            glowPulse = true
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
        .onReceive(timer) { _ in
            if progress < 1.0 {
                progress += (0.05 / 5.0) // 5 seconds duration exact
                
                if progress >= 0.25 && progress < 0.55 {
                    statusText = "LOADING SUPABASE CONNECTOR..."
                } else if progress >= 0.55 && progress < 0.85 {
                    statusText = "OPTIMIZING TOUCH LATENCY..."
                } else if progress >= 0.85 {
                    statusText = "PREPARING ACCESS GATEWAY..."
                }
            } else {
                timer.upstream.connect().cancel()
                withAnimation(.easeInOut(duration: 0.5)) {
                    onFinish()
                }
            }
        }
    }
}

