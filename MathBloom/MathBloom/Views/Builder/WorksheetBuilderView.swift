import SwiftUI

struct WorksheetBuilderView: View {
    @Bindable var viewModel: WorksheetBuilderViewModel

    var body: some View {
        NavigationStack {
            WizardView(viewModel: viewModel)
        }
    }
}
