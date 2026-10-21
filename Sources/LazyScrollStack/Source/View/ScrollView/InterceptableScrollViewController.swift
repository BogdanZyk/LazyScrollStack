import UIKit

extension LazyScrollStackHost {
    final class InterceptableScrollViewController: UIViewController {
        let scrollView = InterceptableScrollView()
        var onBoundsSizeChange: ((CGSize) -> Void)?

        private var previousBoundsSize: CGSize = .zero
        
        init() {
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupScrollView()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            let boundsSize = scrollView.bounds.size
            guard boundsSize != previousBoundsSize else { return }

            previousBoundsSize = boundsSize
            onBoundsSizeChange?(boundsSize)
        }
        
        private func setupScrollView() {
            scrollView.contentInsetAdjustmentBehavior = .always
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(scrollView)

            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
    }
}
