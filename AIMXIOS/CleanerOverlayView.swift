import SwiftUI

struct CleanerOverlayView: View {
    let onDismiss: (Int) -> Void

    @State private var progress: Double = 0.0
    @State private var statusText: String = "INITIALIZING CLEANER ENGINE..."
    @State private var cleanedItemsCount: Int = 0
    @State private var isFinished: Bool = false
    @State private var pulseGlow: Bool = false

    private let cyanGlow = Color(red: 0.0, green: 1.0, blue: 0.85)
    private let purpleGlow = Color(red: 0.62, green: 0.25, blue: 0.98)
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Dark Backdrop
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            ParticleSystemView(count: 25, color: cyanGlow)

            VStack(spacing: 24) {
                
                // Animated Glowing Radial Circle Progress
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 10)
                        .frame(width: 160, height: 160)

                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(
                            LinearGradient(
                                colors: [cyanGlow, purpleGlow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: cyanGlow, radius: pulseGlow ? 12 : 4)

                    VStack(spacing: 4) {
                        Image(systemName: isFinished ? "checkmark.circle.fill" : "trash.circle.fill")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [cyanGlow, .white],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 20)

                // Animated Text Progress
                VStack(spacing: 8) {
                    Text("SYSTEM CLEANER ACTIVE")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .tracking(2.0)
                        .foregroundColor(cyanGlow)

                    Text(statusText)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }

                if isFinished {
                    VStack(spacing: 4) {
                        Text("CLEANED \(cleanedItemsCount) CACHE FILES")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(Color.green)
                        Text("RAM & STORAGE BOOSTED")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(30)
            .background(Color(red: 0.05, green: 0.07, blue: 0.12).opacity(0.95), in: RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(cyanGlow.opacity(0.4), lineWidth: 1.5)
            )
            .padding(.horizontal, 30)
        }
        .onAppear {
            pulseGlow = true
        }
        .onReceive(timer) { _ in
            if progress < 1.0 {
                progress += (0.05 / 3.0) // Exactly 3 seconds duration
                
                if progress >= 0.25 && progress < 0.60 {
                    statusText = "FLUSHING CACHE MEMORY & TEMP LOGS..."
                } else if progress >= 0.60 && progress < 0.90 {
                    statusText = "PURGING UNUSED SANDBOX DATA..."
                } else if progress >= 0.90 {
                    statusText = "FINALIZING OPTIMIZATION..."
                }
            } else {
                timer.upstream.connect().cancel()
                let cleaned = CacheCleaner.clearAppCaches()
                self.cleanedItemsCount = cleaned
                withAnimation {
                    self.isFinished = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onDismiss(cleaned)
                }
            }
        }
    }
}

