import Combine
import ComposableArchitecture
import UIKit

struct AppState: Equatable {
 
    var route: Route?
}

enum Route: Equatable {
    
    case featureA(FeatureAState)
    case featureB(FeatureBState)
    
    var featureAState: FeatureAState? {
        switch self {
        case .featureA(let state):
            return state
        case .featureB:
            return nil
        }
    }
    
    var featureBState: FeatureBState? {
        switch self {
        case .featureB(let state):
            return state
        case .featureA:
            return nil
        }
    }
}

enum AppAction: Equatable {
    
    case openA
    case openB
    case featureA(FeatureAAction)
    case featureB(FeatureBAction)
}

struct AppEnvironment {
    
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    
    switch action {
    case .openA:
        state.route = .featureA(FeatureAState())
        return .none
    case .openB:
        state.route = .featureB(FeatureBState())
        return .none
    }
}
.combined(
    with: featureAReducer
        .pullback(
            state: /Route.featureA,
            action: /AppAction.featureA,
            environment: { _ in FeatureAEnvironment() }
        )
        .optional()
        .pullback(
            state: \.route,
            action: /AppAction.self,
            environment: { $0 }
        )
)
.combined(
    with: featureBReducer
        .pullback(
            state: /Route.featureB,
            action: /AppAction.featureB,
            environment: { _ in FeatureBEnvironment() }
        )
        .optional()
        .pullback(
            state: \.route,
            action: /AppAction.self,
            environment: { $0 }
        )
)


class ViewController: UIViewController {

    @IBOutlet weak var navigateToA: UIButton!
    
    @IBOutlet weak var navigateToB: UIButton!
    
    let store: Store<AppState, AppAction> = Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment())
    
    lazy var viewStore: ViewStore<AppState, AppAction> = { ViewStore(store) }()
    
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
                
        super.viewDidLoad()
        
        navigateToA.addAction(UIAction { [weak self] _ in self?.viewStore.send(.openA) }, for: .touchUpInside)
        navigateToB.addAction(UIAction { [weak self] _ in self?.viewStore.send(.openB) }, for: .touchUpInside)

        let present: (UIViewController) -> Void = { [weak self] viewController in
            guard let self = self else { return }
            
            guard self.presentedViewController != nil else {
                self.present(viewController, animated: true)
                return
            }
            
            self.dismiss(animated: true, completion: { self.present(viewController, animated: true) })
        }

        viewStore.publisher.route
            .removeDuplicates()
            .sink { [weak self] in
                
                guard let self = self else { return }
                
                guard let route = $0 else {
                    if self.presentedViewController != nil, self.presentedViewController?.isBeingDismissed == false {
                        self.dismiss(animated: true)
                    }
                    return
                }
                                
                switch route {
                case .featureA(let state):
                    let store = self.store.scope(
                        state: { $0.route?.featureAState ?? state },
                        action: AppAction.featureA
                    )
                    present(ViewControllerA(store: store))
                    
                case .featureB(let state):
                    let store = self.store.scope(
                        state: { $0.route?.featureBState ?? state },
                        action: AppAction.featureB
                    )
                    present(ViewControllerB(store: store))
                }
            }
            .store(in: &cancellables)
    }
}
