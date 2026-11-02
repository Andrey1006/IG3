
import SwiftUI

struct MomentumBallApp: View {
    @StateObject private var ledger = MBLedger()
    @StateObject private var liveSession = MBLiveSession()

    var body: some View {
        MBRootView()
            .environmentObject(ledger)
            .environmentObject(liveSession)
            .preferredColorScheme(.light)
    }
}
