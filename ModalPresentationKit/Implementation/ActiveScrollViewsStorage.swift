//
//  ActiveScrollViewsStorage.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 16.07.2022.
//

import UIKit

final class ActiveScrollViewsStorage {
    var scrollViews: Set<UIScrollView> = .init()
    
    func update() {
        scrollViews.forEach {
            guard !$0.hasActiveGestures else { return }
            scrollViews.remove($0)
        }
    }
}
