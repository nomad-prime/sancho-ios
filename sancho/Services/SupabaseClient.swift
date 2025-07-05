import Supabase
import Foundation

enum SupabaseClientSingle {
    static let shared = SupabaseClientImpl()

    final class SupabaseClientImpl {
        let client: SupabaseClient

        init() {
            guard let supabaseUrl = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else {
                fatalError("SUPABASE_URL not found in config")
            }
            guard let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
                fatalError("SUPABASE_ANON_KEY not found in config")
            }

            client = SupabaseClient(
                supabaseURL: URL(string: supabaseUrl)!,
                supabaseKey: supabaseKey
            )
        }

        var auth: AuthClient { client.auth }
    }
}
