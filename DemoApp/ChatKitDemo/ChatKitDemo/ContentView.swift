//
//  ContentView.swift
//  ChatKitDemo
//
//  Created by Andrew Grathwohl on 8/29/23.
//

import ChatKit2
import SwiftUI

struct ContentView: View {
  // @Binding means value passed by reference
  @Binding var audioConfigHelper: AudioConfigHelper
  @Binding var isPlaying: Bool
  @Binding var text: String
  
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
            Text(text)
            // TODO: Add audio config information
          
          Text(audioConfigHelper.preferredLocalization ?? "none") // ?? used to specify default value in case preceeding is nil (Swift's version of null)
            .background(.yellow)
          
          // Try clicking on the play button
          Button(action: {
            self.isPlaying.toggle()
          }) {
            Image(systemName: self.isPlaying ? "pause.fill" : "play.fill")
          }
          .foregroundColor(.blue)
        }
        .foregroundColor(.pink)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    PreviewInternalView()
  }
  
  // This nested view is needed to allow for button tapping within a preview
  struct PreviewInternalView: View {
    // @State is short hand for wiring up the ObservableObject and that these values persist when subviews are instantiated
    @State var audioConfigHelper: AudioConfigHelper = .init()
    @State var text: String = "Hi Tyler"
    @State var isPlaying: Bool = false
    
    var body: some View {
      ContentView(audioConfigHelper: $audioConfigHelper, // '$' is the passing by reference
                  isPlaying: $isPlaying,
                  text: $text)
      .previewLayout(.sizeThatFits)
      .colorScheme(.dark)
    }
  }
}
