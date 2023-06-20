import SwiftUI
import FirebaseAuth

struct Complete: View {
    @State private var user = Auth.auth().currentUser       // ランダムに生成された識別ID
    var body: some View {
        Text("COMPLETED!")
    }
}

struct Complete_Previews: PreviewProvider {
    static var previews: some View {
        Complete()
    }
}
