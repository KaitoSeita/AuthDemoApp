import SwiftUI

// Eメールの入力フォーム
struct InputForm: View {
    var icon: String
    var tag: String
    @ObservedObject var input: SignInUp
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(width: 330, height: 60)
            .foregroundColor(.white)
            .shadow(color: .white.opacity(0.8), radius: 10, x: -7, y: -7)
            .shadow(color: .gray.opacity(0.3), radius: 10, x: 8, y: 8)
            .overlay{
                HStack{
                    Image(systemName: icon)
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                    Spacer()
                        .frame(width: 20)
                    TextField(tag, text: $input.email)
                        .disabled(input.prohibit)
                        .font(.system(.body, design: .rounded))
                        .keyboardType(.alphabet)
                        .autocapitalization(.none)
                    Spacer()
                    if isValidEmail(input.email){
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green.opacity(0.5))
                            .frame(width: 10, height: 10)
                    }else{
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red.opacity(0.5))
                            .frame(width: 10, height: 10)
                    }
                }.padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
            }
    }
}
// パスワードの入力フォーム
struct PassForm: View {
    @Binding var isShow: Bool
    @ObservedObject var input: SignInUp
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(width: 330, height: 60)
            .foregroundColor(.white)
            .shadow(color: .white.opacity(0.8), radius: 10, x: -7, y: -7)
            .shadow(color: .gray.opacity(0.3), radius: 10, x: 8, y: 8)
            .overlay{
                HStack{
                    Image(systemName: "lock")
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                    Spacer()
                        .frame(width: 20)
                    if isShow{
                        TextField("password", text: $input.password)
                            .disabled(input.prohibit)
                            .font(.system(.body, design: .rounded))
                            .keyboardType(.alphabet)
                            .autocapitalization(.none)
                    }else{
                        SecureField("password", text: $input.password)
                            .disabled(input.prohibit)
                            .font(.system(.body, design: .rounded))
                            .keyboardType(.alphabet)
                    }
                    Spacer()
                    Image(systemName: isShow ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray.opacity(0.5))
                        .onTapGesture{
                            self.isShow.toggle()
                        }
                }.padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
            }
    }
}
// パスワード再入力用の入力フォーム
struct reInputForm: View {
    var color: Color
    @Binding var isShow: Bool
    @ObservedObject var input: SignInUp
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(width: 330, height: 60)
            .foregroundColor(.white)
            .shadow(color: .white.opacity(0.8), radius: 10, x: -7, y: -7)
            .shadow(color: color.opacity(0.3), radius: 10, x: 8, y: 8)
            .overlay{
                HStack{
                    Image(systemName: "lock")
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                    Spacer()
                        .frame(width: 20)
                    if isShow{
                        TextField("password", text: $input.reInput)
                            .font(.system(.body, design: .rounded))
                            .keyboardType(.alphabet)
                            .autocapitalization(.none)
                    }else{
                        SecureField("password", text: $input.reInput)
                            .font(.system(.body, design: .rounded))
                            .keyboardType(.alphabet)
                    }
                    Spacer()
                    Image(systemName: isShow ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray.opacity(0.5))
                        .onTapGesture{
                            self.isShow.toggle()
                        }
                }.padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
            }
    }
}
// 新規登録時の戻るボタン
struct SignUpBackward: View {
    @Binding var pageCase: SignUpCase
    @Binding var backToHome: HomePageCase
    var color: ProgressColor
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)){
                switch pageCase {
                case .email:
                    backToHome = .home
                case .name:
                    pageCase = .email
                    color.colorSelecter(pageCase: .name)
                case .id:
                    pageCase = .name
                    color.colorSelecter(pageCase: .id)
                case .image:
                    pageCase = .id
                    color.colorSelecter(pageCase: .image)
                }
            }
        }, label: {
            Image(systemName: "arrow.uturn.backward")
                .foregroundColor(.gray)
                .font(.system(size: 24))
        })
        .frame(width: 60, height: 60)
    }
}
// ログイン時の戻るボタン
struct SignInBackward: View {
    var prohibit: Bool
    @Binding var backToHome: HomePageCase
    @Binding var pageCase: SignInCase
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    if !prohibit{
                        withAnimation(.easeInOut(duration: 0.15)){
                            switch pageCase {
                            case .email:
                                backToHome = .home
                            case .complete:
                                pageCase = .email
                            }
                        }
                    }
                }, label: {
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                })
                .frame(width: 60, height: 60)
                Spacer()
            }
            Spacer()
        }.padding(.leading, 30)
    }
}
// 新規登録時の進むボタン
struct ForwardButton: View {
    @Binding var pageCase: SignUpCase
    @ObservedObject var arrow: Arrow
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)){
                switch pageCase {
                case .email:
                    pageCase = .name
                case .name:
                    pageCase = .id
                case .id:
                    pageCase = .image
                case .image:
                    break
                }
            }
        }, label: {
            Path { path in
                path.move(to: arrow.width)
                path.addLine(to: CGPoint(x: 40, y: 30))
                path.move(to: CGPoint(x: 42, y: 30))
                path.addLine(to: arrow.height)
                path.move(to: CGPoint(x: 42, y: 30))
                path.addLine(to: arrow.height + CGPoint(x: 0, y: 15))
            }
            .trim(from: 0.0, to: arrow.end)
            .stroke(style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
            .fill(Color.gray.opacity(0.9))
        })
        .frame(width: 60, height: 60)
    }
}
// ローディング表示
struct LoadingPopUp: View {
    @ObservedObject var load: Loading
    var body: some View {
        HStack {
            Circle()
                .frame(width: 12)
                .foregroundColor(.black)
                .offset(x: -8, y: load.left)
            Circle()
                .frame(width: 12)
                .foregroundColor(.black)
                .offset(x: 0, y: load.center)
            Circle()
                .frame(width: 12)
                .foregroundColor(.black)
                .offset(x: 8, y: load.right)
        }
    }
}
// 正常終了表示
struct DisplaySuccess: View {
    var body: some View {
        VStack{
            
        }
    }
}
// ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct Components_Previews: PreviewProvider {
    static var previews: some View {
        LoadingPopUp(load: Loading())
    }
}
