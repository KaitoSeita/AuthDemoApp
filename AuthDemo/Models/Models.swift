import SwiftUI
import Foundation
import FirebaseAuth

// Model
enum HomePageCase {
    case home, signUp, signIn
}

enum SignUpCase {
    case email, name, id, image
}

enum SignInCase {
    case email, complete
}
// userDefalutsのキー
struct SignInInfo {
    static let email = "email"
    static let password = "password"
}

struct ColorModel: Identifiable {
    var id = UUID()
    var color: Color
}

// スプラッシュのonAppearでイニシャライズ
// ログイン日時の取得をして初期化期限の計算もこのメソッド?
// async / await tryなどの記述が関数内で必要なのかどうかの検証

actor SignInUpAuth {
    /// メールとパスワードでサインインしてuserIDを取得
    func signIn(_ email: String, _ pass: String) async throws -> String {
        // resultに値が入らない限りuidの操作はできないので並行処理ではない
        async let result = try await Auth.auth().signIn(withEmail: email, password: pass)     // 処理が完了するまでresultへの格納を待つ
        let uid = try await result.user.uid
        return uid
    }
    /// メールとパスワードでサインアップしてuserIDを取得
    func signUp(_ email: String, _ pass: String) async throws -> String {
        async let result = try await Auth.auth().createUser(withEmail: email, password: pass)     // .処理が完了するまでresultへの格納を待つ
        let uid = try await result.user.uid
        return uid
    }
    /// パスワード再設定メールの送信
    func resetPassword(_ email: String) async throws {
        let auth = Auth.auth()
        auth.languageCode = "jp"
        let _ = try await auth.sendPasswordReset(withEmail: email)
    }
    /// メールアドレスの重複チェック
    func duplicationEmailChecker(_ email: String) async throws -> Bool {
        let result = try await Auth.auth().fetchSignInMethods(forEmail: email)
        return !result.isEmpty
    }
    /// メールアドレスの正当性チェック
    func emailVerified(_ email: String) async throws -> Bool {
        let result = Auth.auth().currentUser?.isEmailVerified
        return result ?? false
    }
    /// FireStoreでのIDの重複チェック( exist )
    func duplicationIDChecker(_ id: String) async throws/*-> Bool*/ {
        
    }
    /// FireStoreへのユーザー情報の登録
    func registerUser(_ uid: String, _ name: String, _ id: String, _ image: UIImage?) async throws {
        
    }
}

// viewModel
class SignInUp: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var reInput = ""
    @Published var name = ""
    @Published var id = ""
    @Published var prohibit = false
}

class Arrow: ObservableObject {
    @Published var width: CGPoint = CGPoint(x: 0, y: 0)
    @Published var height: CGPoint = CGPoint(x: 0, y: 0)
    @Published var end: CGFloat = 0.0
}

class Check: ObservableObject {
    @Published var width: CGPoint = CGPoint(x: 0, y: 0)
    @Published var height: CGPoint = CGPoint(x: 0, y: 0)
    @Published var end: CGFloat = 0.0
}

class Loading: ObservableObject {
    @Published var flag: Bool = false       // 認証処理の開始フラグ
    @Published var left: CGFloat = 10.0
    @Published var center: CGFloat = 10.0
    @Published var right: CGFloat = 10.0
    @Published var end: CGFloat = 0.0
}

class ProgressColor: ObservableObject {
    @Published var colorBlock: [ColorModel] = []
    init(){
        colorSelecter(pageCase: .email)
    }
    func colorSelecter(pageCase: SignUpCase){
        switch pageCase {
        case .email:
            colorBlock = [ColorModel(color: .black), ColorModel(color: .gray), ColorModel(color: .gray), ColorModel(color: .gray)]
        case .name:
            colorBlock = [ColorModel(color: .black), ColorModel(color: .black), ColorModel(color: .gray), ColorModel(color: .gray)]
        case .id:
            colorBlock = [ColorModel(color: .black), ColorModel(color: .black), ColorModel(color: .black), ColorModel(color: .gray)]
        case .image:
            colorBlock = [ColorModel(color: .black), ColorModel(color: .black), ColorModel(color: .black), ColorModel(color: .black)]
        }
    }
}
/// emailのバリデーション
func isValidEmail(_ email: String) -> Bool {
    let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailCheck = NSPredicate(format:"SELF MATCHES %@", pattern)
    return emailCheck.evaluate(with: email)
}

// extension
extension CGPoint {
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
