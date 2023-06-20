import SwiftUI

struct ContentView: View {
    @ObservedObject var progressColor = ProgressColor()
    @ObservedObject var arrow: Arrow = Arrow()
    @State private var page: HomePageCase = .home
    var body: some View {
        ZStack{
            Color.gray.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.closeKeyboard()
                }
            switch page {
            case .home:
                selectSignInUp()
            case .signIn:
                SignIn(backToHome: $page)
            case .signUp:
                SignUp(backToHome: $page)
            }
        }
    }
    @ViewBuilder private func selectSignInUp() -> some View {
        VStack(spacing: 15){
            VStack(alignment: .leading){
                Text("Welcome to the")
                    .font(.system(size: 20, design: .rounded))
                    .bold()
                Text("Auth Demo App")
                    .font(.system(.largeTitle, design: .rounded))
                    .bold()
            }
            Spacer()
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 330, height: 60)
                .foregroundColor(.white)
                .shadow(color: .white.opacity(0.8), radius: 10, x: -7, y: -7)
                .shadow(color: .gray.opacity(0.3), radius: 10, x: 8, y: 8)
                .overlay{
                    Text("Sign in")
                        .font(.system(size: 20, design: .rounded))
                        .bold()
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)){
                        page = .signIn
                    }
                }
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 330, height: 60)
                .foregroundColor(.black.opacity(0.85))
                .shadow(color: .white.opacity(0.8), radius: 10, x: -7, y: -7)
                .shadow(color: .gray.opacity(0.3), radius: 10, x: 8, y: 8)
                .overlay{
                    Text("Create a new account")
                        .font(.system(size: 20, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)){
                        page = .signUp
                    }
                }
        }.padding(EdgeInsets(top: 120, leading: 0, bottom: 150, trailing: 0))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
