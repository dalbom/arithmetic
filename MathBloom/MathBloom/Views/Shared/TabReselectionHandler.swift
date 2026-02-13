import SwiftUI
import Combine

/// Publishes tab re-selection events (when the user taps an already-selected tab)
final class TabReselectionPublisher {
    static let shared = TabReselectionPublisher()
    let reselected = PassthroughSubject<Int, Never>()
    private init() {}
}

/// UIKit bridge that detects when the user taps the already-selected tab
struct TabReselectionHandler: UIViewControllerRepresentable {
    let tabIndex: Int

    func makeUIViewController(context: Context) -> TabReselectionViewController {
        let vc = TabReselectionViewController()
        vc.tabIndex = tabIndex
        return vc
    }

    func updateUIViewController(_ uiViewController: TabReselectionViewController, context: Context) {}
}

final class TabReselectionViewController: UIViewController, UITabBarControllerDelegate {
    var tabIndex: Int = 0
    private var previousDelegate: UITabBarControllerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDelegate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupDelegate()
    }

    private func setupDelegate() {
        guard let tbc = findTabBarController() else { return }
        if !(tbc.delegate is TabReselectionViewController) {
            previousDelegate = tbc.delegate
            tbc.delegate = self
        }
    }

    private func findTabBarController() -> UITabBarController? {
        // 1. Try built-in property (walks parent VC chain)
        if let tbc = self.tabBarController { return tbc }
        // 2. Walk parent chain explicitly
        var current: UIViewController? = self
        while let parent = current?.parent {
            if let tbc = parent as? UITabBarController { return tbc }
            current = parent
        }
        return nil
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let viewControllers = tabBarController.viewControllers,
           let selectedIndex = viewControllers.firstIndex(of: viewController),
           selectedIndex == tabBarController.selectedIndex {
            TabReselectionPublisher.shared.reselected.send(selectedIndex)
        }
        return true
    }
}
