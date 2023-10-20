# AuthDemo
## 環境
Language：Swift
- Version：5.8.1
- Xcode：14.3.1
### ライブラリ
- FirebaseAuth
## 概要
FirebaseAuthを使用したサインイン認証およびサインアップのデモアプリです。画面遷移をNavigationStack(NavigationViewはiOS16からduplicated)を使用せずにデータバインディングやViewModelを活用して実装しています。データの登録処理では、Swift Concurrencyを使用してメインスレッドではローディング中のUIの表示を、サブスレッドではデータの登録処理をできるようにして非同期処理を実装しています。


![sample](https://github.com/KaitoSeita/AuthDemo/assets/113151647/456ef09d-c646-4565-a3b1-effc85357208)

## 使用した技術
### Swift Concurrency
- 使用したコード
```
Task {
    do {
      let userId = try await signInAuth.signIn(signIn.email, signIn.password)
    }catch{
      setErrorMessage(error)    // エラー処理に関する表示の呼び出し
    }
}

actor SignInUpAuth {
    func signIn(_ email: String, _ pass: String) async throws -> String {
        async let result = try await Auth.auth().signIn(withEmail: email, password: pass)
        let uid = try await result.user.uid
        return uid
    }
}
```
- コードの概要
  - アクタークラス
    - メールとパスワードを引数とし、async throwsでエラーを吐かせるメソッドを定義
    - resultにサインイン処理の結果を格納されるのを待ってからユーザーIDを取得する
  - Task
    - do/catch構文を使用して、処理にアクタークラスのメソッドを呼び出し、エラーを吐いたらエラー表示をさせる処理を記述
