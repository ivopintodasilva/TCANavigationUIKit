import Combine
import ComposableArchitecture
import UIKit

struct FeatureAState: Equatable {
    
    var numberOfTaps: Int = 0
}

enum FeatureAAction: Equatable {
    
    case buttonTapped
}

struct FeatureAEnvironment {
    
}

let featureAReducer = Reducer<
    FeatureAState,
    FeatureAAction,
    FeatureAEnvironment
> { state, action, environment in
    
    switch action {
    case .buttonTapped:
        state.numberOfTaps += 1
        return .none
    }
}

class ViewControllerA: UIViewController {
    
    let store: Store<FeatureAState, FeatureAAction>
    let viewStore: ViewStore<FeatureAState, FeatureAAction>
    
    let onDismiss: () -> Void

    var cancellables = Set<AnyCancellable>()

    init(store: Store<FeatureAState, FeatureAAction>, onDismiss: @escaping () -> Void = {}) {
        
        self.store = store
        self.viewStore = ViewStore(store)
        self.onDismiss = onDismiss
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        
        let stack = UIStackView()
        stack.axis = .vertical
        view.addSubview(stack)

        let numberOfTaps = UILabel()
        numberOfTaps.textColor = .white
        stack.addArrangedSubview(numberOfTaps)
        
        viewStore.publisher.numberOfTaps
            .removeDuplicates()
            .sink { numberOfTaps.text = String($0) }
            .store(in: &cancellables)
        
        let button = UIButton()
        button.setTitle("View Controller A button", for: .normal)
        stack.addArrangedSubview(button)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        button.addAction(UIAction { [weak self] _ in self?.viewStore.send(.buttonTapped) }, for: .touchUpInside)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        if isBeingDismissed {
            onDismiss()
        }
    }
}

