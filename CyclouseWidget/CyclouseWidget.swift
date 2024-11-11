//
//  CyclouseWidget.swift
//  CyclouseWidget
//
//  Created by yoga arie on 11/11/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
  let bikeName: String = "Mountain Bike Pro"
  let price: Double = 1299.99
  let imageURL: String = "bike_image_url"
  
}

struct CyclouseWidgetEntryView : View {
  var entry: Provider.Entry
  let primaryColor = Color(UIColor(red: 150/255, green: 251/255, blue: 74/255, alpha: 1.0))
  
  @Environment(\.widgetFamily) var family // Add this to detect widget size


  var body: some View {
         ZStack {
             // Content
             VStack(alignment: .leading, spacing: 4) { // Reduced spacing
                 // Header
                 Text("Featured Bike")
                     .font(.system(size: 12, weight: .medium))
                     .foregroundColor(.white)
                 
                 // Bike Image Placeholder
                 Image(systemName: "bicycle")
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(maxHeight: family == .systemSmall ? 40 : 60) // Adjust height based on widget size
                     .foregroundColor(.white)
                 
                 // Bike Details
                 VStack(alignment: .leading, spacing: 2) { // Reduced spacing
                     Text(entry.bikeName)
                         .font(.system(size: 12, weight: .bold)) // Reduced font size
                         .foregroundColor(.white)
                         .lineLimit(1)
                     
                     Text("$\(entry.price, specifier: "%.2f")")
                         .font(.system(size: 11, weight: .semibold)) // Reduced font size
                         .foregroundColor(primaryColor)
                 }
                 
                 if family != .systemSmall {
                     Spacer(minLength: 0)
                 }
                 
                 // Bottom tag
                 HStack {
                     Image(systemName: "tag.fill")
                         .foregroundColor(primaryColor)
                         .font(.system(size: 10)) // Add size to icon
                     Text("Best Deal")
                         .font(.system(size: 9, weight: .medium)) // Reduced font size
                         .foregroundColor(primaryColor)
                 }
             }
             .padding(8) // Reduced padding
             .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
  }
}

struct CyclouseWidget: Widget {
    let kind: String = "CyclouseWidget"

  let primaryColor = Color(UIColor(red: 150/255, green: 251/255, blue: 74/255, alpha: 1.0))

  
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            CyclouseWidgetEntryView(entry: entry)
            .containerBackground(for: .widget) {
                      Color(red: 26/255, green: 29/255, blue: 31/255) // background
                  }
              
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    CyclouseWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
