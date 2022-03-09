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

        store.scope(state: \.route?.featureAState, action: AppAction.featureA)
            .ifLet(
                then: { [weak self] in
                    print(">>> featureA scope then")
                    self?.present(ViewControllerA(store: $0), animated: true)
                },
                else: {
                    print(">>> featureA scope else")
                }
            )
            .store(in: &cancellables)
        
        store.scope(state: \.route?.featureBState, action: AppAction.featureB)
            .ifLet(
                then: { [weak self] in
                    print(">>> featureB scope then")
                    self?.present(ViewControllerB(store: $0), animated: true)
                },
                else: {
                    print(">>> featureB scope else")
                }
            )
            .store(in: &cancellables)
    }
}

