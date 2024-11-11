//
//  CyclouseWidgetBundle.swift
//  CyclouseWidget
//
//  Created by yoga arie on 11/11/24.
//

import WidgetKit
import SwiftUI

@main
struct CyclouseWidgetBundle: WidgetBundle {
    var body: some Widget {
        CyclouseWidget()
        CyclouseWidgetControl()
        CyclouseWidgetLiveActivity()
    }
}
