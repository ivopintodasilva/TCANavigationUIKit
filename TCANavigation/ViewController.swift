import Combine
import ComposableArchitecture
import UIKit

struct AppState: Equatable {
 
    var route: Route?
}

struct FeatureARouteID: Hashable {}

struct FeatureBRouteID: Hashable {}

enum Route: Equatable, Identifiable {
    
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
    
    var id: AnyHashable {
        switch self {
        case .featureA:
            return FeatureARouteID()
        case .featureB:
            return FeatureBRouteID()
        }
    }
}

enum AppAction: Equatable {
    
    case openA
    case openB
    case dismissed(Route)
    case featureA(FeatureAAction)
    case featureB(FeatureBAction)
}

struct AppEnvironment {
    
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    
    Reducer { state, action, environment in
        
        switch action {
        case .openA:
            state.route = .featureA(FeatureAState())
            return .none
        case .openB:
            state.route = .featureB(FeatureBState())
            return .none
        case .dismissed(let route) where route.id == state.route?.id:
            state.route = nil
            return .none
        case .dismissed:
            return .none
        case .featureA:
            return .none
        case .featureB:
            return .none
        }
    },
    
    featureAReducer
        .pullback(
            state: /Route.featureA,
            action: /FeatureAAction.self,
            environment: { $0 }
        )
        .optional()
        .pullback(
            state: \.route,
            action: /AppAction.featureA,
            environment: { appEnvironment in FeatureAEnvironment() }
        ),
    
    featureBReducer
        .pullback(
            state: /Route.featureB,
            action: /FeatureBAction.self,
            environment: { $0 }
        )
        .optional()
        .pullback(
            state: \.route,
            action: /AppAction.featureB,
            environment: { appEnvironment in FeatureBEnvironment() }
        )
)
.debug()

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
            .removeDuplicates(by: { $0?.id == $1?.id })
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
                    let viewController = ViewControllerA(
                        store: store,
                        onDismiss: { [weak self] in self?.viewStore.send(.dismissed(route)) }
                    )
                    present(viewController)
                    
                case .featureB(let state):
                    let store = self.store.scope(
                        state: { $0.route?.featureBState ?? state },
                        action: AppAction.featureB
                    )
                    let viewController = ViewControllerB(
                        store: store,
                        onDismiss: { [weak self] in self?.viewStore.send(.dismissed(route)) }
                    )
                    present(viewController)
                }
            }
            .store(in: &cancellables)
    }
}
