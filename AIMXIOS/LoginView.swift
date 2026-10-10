import SwiftUI

struct LoginView: View {
    let onSuccess: () -> Void

    @State private var username: String = UserDefaults.standard.string(forKey: "saved_username") ?? ""
    @State private var licenseKey: String = UserDefaults.standard.string(forKey: "saved_license_key") ?? ""
    @State private var isVerifying: Bool = false
    @State private var statusMessage: String = "READY TO AUTHENTICATE"
    @State private var isError: Bool = false
    @State private var showSettingsModal: Bool = false

    @StateObject private var supabase = SupabaseManager.shared

    private let cyanGlow = Color(red: 0.0, green: 1.0, blue: 0.85)
    private let purpleGlow = Color(red: 0.62, green: 0.25, blue: 0.98)

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.03, green: 0.04, blue: 0.08)
                .ignoresSafeArea()

            ParticleSystemView(count: 30, color: cyanGlow.opacity(0.6))

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Top Bar Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("RANZY NXRPLOIT DEV")
                                .font(.system(size: 9, weight: .black, design: .rounded))
                                .tracking(2.5)
                                .foregroundColor(cyanGlow)

                            Text("SENS X IOS")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        
                        Button {
                            showSettingsModal = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(cyanGlow)
                                .padding(10)
                                .background(Color.white.opacity(0.06), in: Circle())
                                .overlay(Circle().stroke(cyanGlow.opacity(0.3), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // Hero Icon & Title Card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(cyanGlow.opacity(0.12))
                                .frame(width: 86, height: 86)
                                .blur(radius: 12)

                            Image(systemName: "key.fill")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [cyanGlow, purpleGlow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: cyanGlow, radius: 10)
                        }

                        Text("SYSTEM ACCESS CONTROL")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(1.2)

                        Text("Enter your credentials or active Supabase license key to continue")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .padding(.top, 10)

                    // Glassmorphic Input Form Container
                    VStack(spacing: 18) {
                        
                        // Username Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("USERNAME ACCESS")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(cyanGlow)

                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(cyanGlow)
                                    .frame(width: 24)

                                TextField("Enter username (e.g. RanzyPlayer)", text: $username)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .padding(14)
                            .background(Color.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(cyanGlow.opacity(0.25), lineWidth: 1)
                            )
                        }

                        // License Key Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SUPABASE LICENSE KEY")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(cyanGlow)

                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(purpleGlow)
                                    .frame(width: 24)

                                SecureField("Enter License Key (or RANZY-VIP-2026)", text: $licenseKey)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                            }
                            .padding(14)
                            .background(Color.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(purpleGlow.opacity(0.35), lineWidth: 1)
                            )
                        }

                        // Status Output Box
                        HStack(spacing: 8) {
                            Image(systemName: isError ? "exclamationmark.triangle.fill" : "shield.checkmark.fill")
                                .foregroundColor(isError ? .red : cyanGlow)

                            Text(statusMessage)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(isError ? Color.red.opacity(0.9) : Color.white.opacity(0.85))
                                .lineLimit(2)

                            Spacer()
                        }
                        .padding(12)
                        .background(
                            (isError ? Color.red : cyanGlow).opacity(0.08),
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke((isError ? Color.red : cyanGlow).opacity(0.2), lineWidth: 1)
                        )

                        // Authenticate Button
                        Button {
                            performAuthentication()
                        } label: {
                            HStack(spacing: 10) {
                                if isVerifying {
                                    ProgressView()
                                        .tint(.black)
                                } else {
                                    Image(systemName: "checkmark.shield.fill")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("VERIFY & UNLOCK SYSTEM")
                                        .font(.system(size: 13, weight: .black, design: .rounded))
                                        .tracking(1.2)
                                }
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    colors: [cyanGlow, Color(red: 0.0, green: 0.85, blue: 0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                            .shadow(color: cyanGlow.opacity(0.6), radius: 10)
                        }
                        .disabled(isVerifying)
                    }
                    .padding(22)
                    .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(cyanGlow.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    // Supabase Indicator Badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 7, height: 7)
                        Text("SUPABASE INTEGRATION ACTIVE")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    .padding(.top, 10)

                    Spacer(minLength: 40)
                }
            }
        }
        .sheet(isPresented: $showSettingsModal) {
            SupabaseConfigModal(supabase: supabase)
        }
    }

    private func performAuthentication() {
        guard !username.isEmpty else {
            statusMessage = "Please enter a username"
            isError = true
            return
        }

        isVerifying = true
        isError = false
        statusMessage = "CONNECTING TO SUPABASE..."

        supabase.verifyLicense(username: username, licenseKey: licenseKey) { success, message in
            isVerifying = false
            statusMessage = message
            isError = !success

            if success {
                UserDefaults.standard.set(username, forKey: "saved_username")
                UserDefaults.standard.set(licenseKey, forKey: "saved_license_key")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    onSuccess()
                }
            }
        }
    }
}

struct SupabaseConfigModal: View {
    @ObservedObject var supabase: SupabaseManager
    @Environment(\.dismiss) var dismiss

    @State private var urlInput: String = ""
    @State private var keyInput: String = ""

    private let cyanGlow = Color(red: 0.0, green: 1.0, blue: 0.85)

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.06, blue: 0.12).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("SUPABASE CONFIGURATION")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(cyanGlow)

                VStack(alignment: .leading, spacing: 6) {
                    Text("SUPABASE PROJECT URL")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                    TextField("https://your-project.supabase.co", text: $urlInput)
                        .padding(12)
                        .background(Color.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("SUPABASE ANON KEY")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                    TextField("public-anon-key", text: $keyInput)
                        .padding(12)
                        .background(Color.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(.white)
                }

                Button("SAVE SUPABASE CREDENTIALS") {
                    supabase.saveCredentials(url: urlInput, anonKey: keyInput)
                    dismiss()
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(cyanGlow, in: RoundedRectangle(cornerRadius: 12))

                Spacer()
            }
            .padding(24)
        }
        .onAppear {
            urlInput = supabase.supabaseURL
            keyInput = supabase.supabaseAnonKey
        }
    }
}

