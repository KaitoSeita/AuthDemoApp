import SwiftUI

struct Complete: View {
    let userId: String
    var body: some View {
        Text("COMPLETED!")
    }
}

struct Complete_Previews: PreviewProvider {
    static var previews: some View {
        Complete(userId: "")
    }
}
