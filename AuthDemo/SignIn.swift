import SwiftUI
import FirebaseAuth

struct SignIn: View {
    @State private var showPassword: Bool = false
    @State private var pageCase: SignInCase = .email
    @State private var resetPassFlag: Bool = false        // email / pass を忘れた際の処理
    @State private var isCompleted: Bool = false
    @State private var errorMessage: String = ""      // エラーメッセージ
    @Binding var backToHome: HomePageCase
    @ObservedObject var signIn = SignInUp()
    @ObservedObject var load = Loading()
    var signInAuth = SignInUpAuth()
    private var signInFlag: Bool {
        isValidEmail(signIn.email) && signIn.password.count >= 8
    }
    var body: some View {
        ZStack{
            if !isCompleted{
                inputInfo()
            }else{
                Complete()
            }
        }
    }
    /// 入力画面
    @ViewBuilder private func inputInfo() -> some View {
        if !load.flag {
            VStack(alignment: .leading, spacing: 15){
                VStack(alignment: .leading) {
                    Text("Enter your")
                        .font(.system(size: 17, design: .rounded))
                    Text("E-mail and Password")
                        .font(.system(.title, design: .rounded))
                        .bold()
                }
                Text("E-mail")
                    .font(.system(size: 13))
                    .fontWeight(.ultraLight)
                InputForm(icon: "envelope", tag: "e-mail", input: signIn)
                Text("Password")
                    .font(.system(size: 13))
                    .fontWeight(.ultraLight)
                PassForm(isShow: $showPassword, input: signIn)
                Spacer()
                    .frame(height: 10)
                // 有効性判定後サインインボタンを表示
                if signInFlag {
                    signInButton()
                }else{
                    // パスワード, emailの再設定はモーダル表示で処理させる
                    Button(action: {
                        self.resetPassFlag.toggle()
                    }, label: {
                        Text("Forgot Password ?")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.black)
                            .bold()
                    })
                }
                if errorMessage != "" {
                    Text(errorMessage)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.red)
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 80, leading: 30, bottom: 0, trailing: 30))
            .sheet(isPresented: $resetPassFlag){
                ZStack{
                    Color.gray.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            UIApplication.shared.closeKeyboard()
                        }
                    reSettingInfo()
                }
            }
            SignInBackward(prohibit: signIn.prohibit, backToHome: $backToHome, pageCase: $pageCase)
        }else{
            LoadingPopUp(load: load)
                .onChange(of: errorMessage){ newMessage in
                    // エラーメッセージの変化を検知し、それが空白でなければエラー表示
                    if newMessage != "" {
                        withAnimation(.easeInOut(duration: 0.2)){
                            load.flag = false
                        }
                    }
                }
        }
    }
    @ViewBuilder private func signInButton() -> some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(width: 330, height: 60)
            .foregroundColor(.black.opacity(0.85))
            .shadow(color: .white.opacity(0.8), radius: 10, x: -7, y: -7)
            .shadow(color: .gray.opacity(0.3), radius: 10, x: 8, y: 8)
            .overlay{
                Text("Sign In")
                    .font(.system(size: 20, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
            }
            .onTapGesture {
                UIApplication.shared.closeKeyboard()
                // ログイン処理
                Task {
                    do {
                        let userId = try await signInAuth.signIn(signIn.email, signIn.password)
                        if !userId.isEmpty {
                            withAnimation(.easeInOut(duration: 0.2)){
                                isCompleted.toggle()
                            }
                        }
                    }catch{
                        setErrorMessage(error)
                    }
                }
                withAnimation(.easeInOut(duration: 0.3)){
                    load.flag = true
                    signIn.prohibit = true
                }
                // ローディング画面のアニメーション
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true){_ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 1).repeatForever(autoreverses: false)){
                        load.left = 0.0
                    }
                }
                Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true){_ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 1).repeatForever(autoreverses: false)){
                        load.center = 0.0
                    }
                }
                Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true){_ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 1).repeatForever(autoreverses: false)){
                        load.right = 0.0
                    }
                }
            }
    }
    @State private var resetFlag: Bool = false
    /// eメールおよびパスワードの再設定画面
    @ViewBuilder private func reSettingInfo() -> some View {
        VStack{
            RoundedRectangle(cornerRadius: 15)
                .frame(width: 80, height: 8)
                .foregroundColor(.gray.opacity(0.7))
            Spacer()
                .frame(height: 30)
            if !resetFlag{
                VStack(alignment: .leading) {
                    Text("Enter your")
                        .font(.system(size: 17, design: .rounded))
                    Text("E-mail")
                        .font(.system(.title, design: .rounded))
                        .bold()
                    Text("E-mail")
                        .font(.system(size: 13))
                        .fontWeight(.ultraLight)
                    InputForm(icon: "envelope", tag: "e-mail", input: signIn)
                    if isValidEmail(signIn.email){
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 330, height: 60)
                            .foregroundColor(.black.opacity(0.85))
                            .shadow(color: .white.opacity(0.8), radius: 10, x: -7, y: -7)
                            .shadow(color: .gray.opacity(0.3), radius: 10, x: 8, y: 8)
                            .overlay{
                                Text("Send")
                                    .font(.system(size: 20, design: .rounded))
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            .onTapGesture {
                                UIApplication.shared.closeKeyboard()
                                Task {
                                    do {
                                        try await signInAuth.resetPassword(signIn.email)
                                    }catch{
                                        
                                    }
                                }
                                withAnimation(.easeInOut(duration: 0.2)){
                                    self.resetFlag.toggle()
                                }
                            }
                    }
                }
            }else{
                // メールを確認させて続行リンクを踏ませる
                
            }
            Spacer()
        }.padding(EdgeInsets(top: 20, leading: 30, bottom: 0, trailing: 30))
    }
    // エラーメッセージの表示
    private func setErrorMessage(_ error: Error?){
        if let error = error as NSError? {
            if let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:
                    errorMessage = "メールアドレスの形式が違います。"
                case .emailAlreadyInUse:
                    errorMessage = "このメールアドレスはすでに使われています。"
                case .weakPassword:
                    errorMessage = "パスワードが弱すぎます。"
                case .userNotFound, .wrongPassword:
                    errorMessage = "メールアドレス、またはパスワードが間違っています"
                case .userDisabled:
                    errorMessage = "このユーザーアカウントは無効化されています"
                default:
                    errorMessage = "予期せぬエラーが発生しました。\nしばらく時間を置いてから再度お試しください。"
                }
            }
        }
    }
}

struct AuthAccount_Previews: PreviewProvider {
    @State static var pageCase: HomePageCase = .signIn
    static var previews: some View {
        SignIn(backToHome: $pageCase)
    }
}
