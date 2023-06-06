import SwiftUI

// Forwordボタンが絶妙にダサくて納得いかないしPathの表現はリアルタイム性に欠ける

struct SignUp: View {
    @State private var pageCase: SignUpCase = .id    // 画面の管理用変数
    @State private var showPassword: Bool = false     // パスワードの表示/非表示
    @State private var showReInput: Bool = false    // 再入力パスワードの表示/非表示
    @State private var formOpacity: CGFloat = 0.0       // パス再入力フォームの表示用
    @State private var showImgPicker: Bool = false      // ImagePickerの表示/非表示を管理
    @State private var image: UIImage?      // 選択したimageを保持
    @Binding var backToHome: HomePageCase     // emailとpassを入力する画面からホームに戻る際に使用
    @ObservedObject var progColor = ProgressColor()
    @ObservedObject var signUp = SignInUp()
    @ObservedObject var arrow = Arrow()
    private var forwordCase: Bool {
        (isEmail && pageCase == .email) || (isNameCount && pageCase == .name) || (isId && pageCase == .id) || (isImage && pageCase == .image)
    }
    private var isEmail: Bool {
        isValidEmail(signUp.email) && signUp.password.count >= 8 && (signUp.password == signUp.reInput)
    }
    private var isNameCount: Bool {
        signUp.name.count > 0 && signUp.name.count <= 10
    }
    private var isId: Bool {
        signUp.id.count > 0
    }
    @State private var isImage: Bool = false
    var body: some View {
        ZStack{
            switch pageCase {
            case .email:
                emailpassForm()
            case .name:
                createName()
            case .id:
                createID()
            case .image:
                uploadImg()
            }
            // ここに登録完了用のviewをセットしておく
            progressBar()
        }
    }
    /// 進捗表示バー
    @ViewBuilder private func progressBar() -> some View {
        VStack{
            HStack{
                SignUpBackward(pageCase: $pageCase, backToHome: $backToHome, color: progColor)
                Spacer()
                if forwordCase {
                    
                    ForwardButton(pageCase: $pageCase, arrow: arrow)
                        .onAppear{
                            arrow.end = 0.0
                            withAnimation(.linear(duration: 0.7)){
                                arrow.width = CGPoint(x: 20, y: 30)
                                arrow.height = CGPoint(x: 34, y: 22)
                                arrow.end = 1.0
                            }
                        }
                }
            }
            Spacer()
                .frame(height: 20)
            HStack(spacing: 12){
                ForEach(progColor.colorBlock){ color in
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 70, height: 8)
                        .foregroundColor(color.color.opacity(0.85))
                }
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
    }
    /// Eメールとパスワードの入力フォーム
    @ViewBuilder private func emailpassForm() -> some View {
        VStack(alignment: .leading, spacing: 15){
            VStack(alignment: .leading){
                Text("Enter your")
                    .font(.system(size: 17, design: .rounded))
                Text("E-mail and Password")
                    .font(.system(.title, design: .rounded))
                    .bold()
            }
            Text("E-mail")
                .font(.system(size: 14))
                .fontWeight(.ultraLight)
            InputForm(icon: "envelope", tag: "e-mail", input: signUp)
            Text("Password ( at least 8 characters )")
                .font(.system(size: 14))
                .fontWeight(.ultraLight)
            PassForm(isShow: $showPassword, input: signUp)
            if signUp.password.count >= 8{
                reInputForm(color: Color.gray, isShow: $showReInput, input: signUp)
                    .opacity(formOpacity)
                    .onAppear{
                        withAnimation(.easeInOut(duration: 0.3)){
                            formOpacity = 1.0
                        }
                    }
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 120, leading: 30, bottom: 0, trailing: 30))
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 1)){
                signUp.focusemail = false
                signUp.focusreInput = false
                signUp.focuspassword = false
            }
        }
        .onAppear{
            progColor.colorSelecter(pageCase: pageCase)
        }
    }
    /// ユーザーネーム登録画面
    /// 文字数制限
    @ViewBuilder private func createName() -> some View {
        VStack(alignment: .leading){
                VStack(alignment: .leading){
                    Text("Enter your")
                        .font(.system(size: 17, design: .rounded))
                    Text("User Name")
                        .font(.system(.title, design: .rounded))
                        .bold()
                }
            
            Text("( at most 10 characters )")
                .font(.system(size: 14))
                .fontWeight(.ultraLight)
            Spacer()
                .frame(height: 20)
            Text(": \(signUp.name)")
                .font(.system(.title, design: .rounded))
                .bold()

            RoundedRectangle(cornerRadius: 20)
                .frame(width: 330, height: 60)
                .foregroundColor(.white)
                .shadow(color: .white.opacity(0.8), radius: 10, x: -7, y: -7)
                .shadow(color: .gray.opacity(0.3), radius: 10, x: 8, y: 8)
                .overlay{
                    HStack{
                        TextField("name", text: $signUp.name)
                            .font(.system(.body, design: .rounded))
                            .autocapitalization(.none)
                        if isNameCount{
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green.opacity(0.5))
                                .frame(width: 10, height: 10)
                        }else{
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red.opacity(0.5))
                                .frame(width: 10, height: 10)
                        }
                    }.padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                }
            Spacer()
        }
        .padding(EdgeInsets(top: 120, leading: 30, bottom: 0, trailing: 30))
        .onAppear{
            progColor.colorSelecter(pageCase: pageCase)
        }
    }
    /// ID登録の画面
    @ViewBuilder private func createID() -> some View {
        VStack(alignment: .leading){
                VStack(alignment: .leading){
                    Text("Enter your")
                        .font(.system(size: 17, design: .rounded))
                    Text("User ID")
                        .font(.system(.title, design: .rounded))
                        .bold()
                }
            
            Text("( at most 10 characters )")
                .font(.system(size: 14))
                .fontWeight(.ultraLight)
            Spacer()
                .frame(height: 20)
            Text("@\(signUp.id)")
                .font(.system(.title, design: .rounded))
                .bold()

            RoundedRectangle(cornerRadius: 20)
                .frame(width: 330, height: 60)
                .foregroundColor(.white)
                .shadow(color: .white.opacity(0.8), radius: 10, x: -7, y: -7)
                .shadow(color: .gray.opacity(0.3), radius: 10, x: 8, y: 8)
                .overlay{
                    HStack{
                        TextField("id", text: $signUp.id)
                            .font(.system(.body, design: .rounded))
                            .autocapitalization(.none)
                        if isId{
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green.opacity(0.5))
                                .frame(width: 10, height: 10)
                        }else{
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red.opacity(0.5))
                                .frame(width: 10, height: 10)
                        }
                    }.padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                }
            Spacer()
        }
        .padding(EdgeInsets(top: 120, leading: 30, bottom: 0, trailing: 30))
        .onAppear{
            progColor.colorSelecter(pageCase: pageCase)
        }
    }
    /// 画像のアップロード画面
    @ViewBuilder private func uploadImg() -> some View {
        VStack(alignment: .leading, spacing: 40){
            VStack(alignment: .leading){
                Text("Upload your")
                    .font(.system(size: 17, design: .rounded))
                Text("Image")
                    .font(.system(.title, design: .rounded))
                    .bold()
            }
            HStack{
                Spacer()
                if image != nil {
                    Image(uiImage: image!)
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .onAppear{
                            isImage = true
                        }
                }else{
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                }
                Spacer()
            }
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 200, height: 60)
                .foregroundColor(.black.opacity(0.85))
                .shadow(color: .white.opacity(0.8), radius: 10, x: -7, y: -7)
                .shadow(color: .gray.opacity(0.3), radius: 10, x: 8, y: 8)
                .overlay{
                    Text("Select Image")
                        .font(.system(size: 20, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    self.showImgPicker.toggle()
                }
            Spacer()
        }
        .padding(EdgeInsets(top: 120, leading: 30, bottom: 0, trailing: 30))
        .onAppear{
            progColor.colorSelecter(pageCase: pageCase)
        }
        .sheet(isPresented: $showImgPicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
        }
    }
}

struct CreateAccount_Previews: PreviewProvider {
    @State static var pageCase: HomePageCase = .signUp
    static var previews: some View {
        SignUp(backToHome: $pageCase)
    }
}
