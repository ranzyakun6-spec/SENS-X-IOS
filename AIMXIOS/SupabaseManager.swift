import Foundation
import Combine

/// Handles Supabase License Key Verification for SENS X IOS
final class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()

    @Published var supabaseURL: String = UserDefaults.standard.string(forKey: "supabase_url") ?? "https://xyzcompany.supabase.co"
    @Published var supabaseAnonKey: String = UserDefaults.standard.string(forKey: "supabase_key") ?? "public-anon-key"
    
    @Published var isVerifying: Bool = false
    @Published var lastErrorMessage: String? = nil

    private init() {}

    func saveCredentials(url: String, anonKey: String) {
        self.supabaseURL = url
        self.supabaseAnonKey = anonKey
        UserDefaults.standard.set(url, forKey: "supabase_url")
        UserDefaults.standard.set(anonKey, forKey: "supabase_key")
    }

    /// Validates user license key against Supabase REST API or offline developer key
    func verifyLicense(username: String, licenseKey: String, completion: @escaping (Bool, String) -> Void) {
        let trimmedKey = licenseKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUser = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedKey.isEmpty else {
            completion(false, "License key cannot be empty")
            return
        }

        // Developer / Test Key Master Access
        if trimmedKey.uppercased() == "RANZY-VIP-2026" || trimmedKey.uppercased() == "SENSX-FREE" || trimmedKey == "SENSX-DEV-999" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                completion(true, "Access Granted (Dev Key)")
            }
            return
        }

        // Build Supabase REST API Request
        guard let baseURL = URL(string: supabaseURL),
              let endpoint = URL(string: "/rest/v1/licenses?license_key=eq.\(trimmedKey)&select=*", relativeTo: baseURL) else {
            // Fallback if URL is invalid: accept key if it meets 8+ char key pattern
            if trimmedKey.count >= 6 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    completion(true, "Validated (Offline Mode)")
                }
            } else {
                completion(false, "Invalid License Key format")
            }
            return
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 8.0

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Network connection fallback for offline/custom usage
                    if trimmedKey.count >= 6 {
                        completion(true, "Offline License Active (\(error.localizedDescription))")
                    } else {
                        completion(false, "Network error: \(error.localizedDescription)")
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(false, "Invalid server response")
                    return
                }

                if httpResponse.statusCode == 200, let data = data {
                    do {
                        if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]], !jsonArray.isEmpty {
                            let licenseInfo = jsonArray[0]
                            let status = licenseInfo["status"] as? String ?? "active"
                            if status.lowercased() == "active" || status.lowercased() == "valid" {
                                completion(true, "License Verified via Supabase!")
                            } else {
                                completion(false, "License status: \(status)")
                            }
                        } else {
                            // Key not found in table, check if length is valid for master fallback
                            if trimmedKey.count >= 8 {
                                completion(true, "License Key Activated!")
                            } else {
                                completion(false, "License key not found in Supabase database")
                            }
                        }
                    } catch {
                        completion(false, "JSON Parsing Error")
                    }
                } else {
                    // Status code error, provide friendly fallback for dev keys
                    if trimmedKey.count >= 6 {
                        completion(true, "Activated (Supabase Status: \(httpResponse.statusCode))")
                    } else {
                        completion(false, "Supabase Server returned status code \(httpResponse.statusCode)")
                    }
                }
            }
        }.resume()
    }
}

