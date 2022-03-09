import ComposableArchitecture
import UIKit

struct FeatureAState: Equatable {
    
}

enum FeatureAAction: Equatable {
    
}

struct FeatureAEnvironment {
    
}

let featureAReducer = Reducer<
    FeatureAState,
    FeatureAAction,
    FeatureAEnvironment
> { state, action, environment in
    
    switch action {
    default:
        return .none
    }
}

class ViewControllerA: UIViewController {
    
    let store: Store<FeatureAState, FeatureAAction>
    let viewStore: ViewStore<FeatureAState, FeatureAAction>

    init(store: Store<FeatureAState, FeatureAAction>) {
        
        self.store = store
        self.viewStore = ViewStore(store)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .blue
    }
}

