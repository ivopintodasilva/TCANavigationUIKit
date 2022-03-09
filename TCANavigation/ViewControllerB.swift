import ComposableArchitecture
import UIKit

struct FeatureBState: Equatable {
    
}

enum FeatureBAction: Equatable {
    
}

struct FeatureBEnvironment {
    
}

let featureBReducer = Reducer<
    FeatureBState,
    FeatureBAction,
    FeatureBEnvironment
> { state, action, environment in
    
    switch action {
    default:
        return .none
    }
}

class ViewControllerB: UIViewController {
    
    let store: Store<FeatureBState, FeatureBAction>
    let viewStore: ViewStore<FeatureBState, FeatureBAction>

    init(store: Store<FeatureBState, FeatureBAction>) {
        
        self.store = store
        self.viewStore = ViewStore(store)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
    }
}

