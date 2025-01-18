/// Copyright (c) 2023 Kodeco LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct ContentView: View {
  
  /*
   Note: If your NavigationStack presents only one type of view, path can be an array of the data type you pass to that view: [Object] for ObjectView or [URL] for SafariView. You’ll still need to use NavigationLink(value:) with the .navigationDestination(for:) modifier.
   */
  
  // for deeplinking
  @State private var path = NavigationPath()
  
  @StateObject private var store = TheMetStore()
  @State private var query = "peony"
  @State private var showQueryField = false
  @State private var fetchObjectsTask: Task<Void, Error>?
  
  var body: some View {
    /// Notice `navigationTitle` modifies List, not `NavigationStack`.
    /// A `NavigationStack` can contain alternative root views, each with its own
    /// `.navigationTitle` and `toolbars`.
    NavigationStack(path: $path) { // You pass a binding to path to the navigation stack. Now, you can observe the current state of the stack or modify path to specify where to navigate.
      VStack {
        Text("You searched for '\(query)'")
          .padding(5)
          .background(Color.metForeground)
          .cornerRadius(10)
        List(store.objects, id: \.objectID) { object in
          /*
          if !object.isPublicDomain, let url = URL(string: object.objectURL) {
            NavigationLink(destination: SafariView(url: url)) {
              WebIndicatorView(title: object.title)
            }
          } else {
            NavigationLink(object.title) {
              ObjectView(object: object)
            }
          }
           */
          // Link(object.title, destination: URL(string: object.objectURL)!)
          
          /// You use the `value` initializer for `NavigationLink`, so both label views are in the trailing closures. This version expects you to modify the enclosing `List` with a matching `navigationDestination` for each type of `value`.
          if !object.isPublicDomain,
             let url = URL(string: object.objectURL) {
            NavigationLink(value: url) {
              WebIndicatorView(title: object.title)
            }
            .listRowBackground(Color.metBackground)
            .foregroundStyle(.white)
          } else {
            NavigationLink(value: object) {
              Text(object.title)
            }
            .listRowBackground(Color.metForeground)
          }
        }
        .navigationTitle("The Met")
        .toolbar {
          Button("Search the Met") {
            query = ""
            showQueryField = true
          }
          .foregroundStyle(Color.metBackground)
          .padding(.horizontal)
          .background(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.metBackground, lineWidth: 2))
        }
        .alert("Search the Met", isPresented: $showQueryField) {
          TextField("Search the Met", text: $query)
          Button("Search") {
            fetchObjectsTask?.cancel()
            fetchObjectsTask = Task {
              do {
                store.objects = []
                try await store.fetchObjects(for: query)
                
              } catch { }
            }
          }
        }
        .navigationDestination(for: URL.self) { url in
          SafariView(url: url)
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea()
        }
        // For public-domain objects or non-public-domain objects without a valid objectURL, NavigationLink passes an object, which matches .navigationDestination(for: Object.self), so the destination is still ObjectView(object: object).
        .navigationDestination(for: Object.self) { object in
          ObjectView(object: object)
        }
      }
      .overlay {
        if store.objects.isEmpty {
          ProgressView()
        }
      }
    }
    /// When the app starts, `ContentView` appears and this task runs.
    /// Because it modifies `NavigationStack`, it runs only once, no matter how often you navigate to `ObjectView` and back to `ContentView`.
    .task {
      do {
        try await store.fetchObjects(for: query)
      } catch {}
    }
    .onOpenURL { url in
      /// 1 - Extract an `id` value from the widget URL, then find the first `object` whose `objectID` matches this `id` value. Because `url.host` is a `String`, convert the `objectID` value to `String` before comparing.
      if let id = url.host,
         let object = store.objects.first(where: { String($0.objectID) == id }) {
        
        /// 2 - If the object is in the public domain, append it to `path`. Otherwise, append the `URL` created from its `objectURL`.
        if object.isPublicDomain {
          path.append(object)
        } else {
          if let url = URL(string: object.objectURL) {
            path.append(url)
          }
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
