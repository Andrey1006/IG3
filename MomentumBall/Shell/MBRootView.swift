
import SwiftUI

struct MBReportRoute: Hashable {
    let matchIdentifier: String
}

struct MBBucketRoute: Hashable {
    let bucketIndex: Int
}

struct MBPlayerRoute: Hashable {
    let playerIdentifier: String
}

struct MBRootView: View {
    @EnvironmentObject private var ledger: MBLedger

    var body: some View {
        ZStack {
            if (ledger.club == nil) {
                MBOnboardingFlow()
                    .transition(.opacity)
            } else {
                MBShellView()
                    .transition(.asymmetric(insertion: .scale(scale: 0.96).combined(with: .opacity), removal: .opacity))
            }
        }
        .onAppear {
            MBHaptics.isEnabled = ledger.club?.hapticsEnabled ?? true
        }
        .onChange(of: ledger.club?.hapticsEnabled) { hapticsSetting in
            MBHaptics.isEnabled = hapticsSetting ?? true
        }
    }
}
