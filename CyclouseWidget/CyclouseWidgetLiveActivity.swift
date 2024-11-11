//
//  CyclouseWidgetLiveActivity.swift
//  CyclouseWidget
//
//  Created by yoga arie on 11/11/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CyclouseWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CyclouseWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CyclouseWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension CyclouseWidgetAttributes {
    fileprivate static var preview: CyclouseWidgetAttributes {
        CyclouseWidgetAttributes(name: "World")
    }
}

extension CyclouseWidgetAttributes.ContentState {
    fileprivate static var smiley: CyclouseWidgetAttributes.ContentState {
        CyclouseWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CyclouseWidgetAttributes.ContentState {
         CyclouseWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CyclouseWidgetAttributes.preview) {
   CyclouseWidgetLiveActivity()
} contentStates: {
    CyclouseWidgetAttributes.ContentState.smiley
    CyclouseWidgetAttributes.ContentState.starEyes
}
