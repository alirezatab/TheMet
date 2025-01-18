/// Copyright (c) 2025 Kodeco LLC
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
import WidgetKit

struct WidgetView: View {
  
  let entry: Provider.Entry
  
  var body: some View {
    VStack {
      /// 1 - You can’t use `NavigationStack` in a widget view, so you create your own title with `headline` font size and `top` padding to push it away from the top edge.
      Text("The Met")
        .font(.headline)
        .padding(.top)
      /// 2 - You add a divider line, to make it look more like a title.
      Divider()

      /// 3 - You display the object’s title so it looks similar to how it appears in the app’s list.
      if !entry.object.isPublicDomain {
        WebIndicatorView(title: entry.object.title)
          .padding()
          .background(Color.metBackground)
          .foregroundColor(.white)
      } else {
        DetailIndicatorView(title: entry.object.title)
          .padding()
          .background(Color.metForeground)
      }
    }
    /// 4 - You apply `truncationMode` and `fontWeight` to the `VStack` so it works for both `WebIndicatorView` and `DetailIndicatorView`.
    .truncationMode(.middle)
    .fontWeight(.semibold)
    .widgetURL(URL(string: "themet://\(entry.object.objectID)"))
  }
}

struct DetailIndicatorView: View {
  let title: String

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(title)
      Spacer()
      Image(systemName: "doc.text.image.fill")
    }
  }
}


struct WidgetView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      WidgetView(
        entry: SimpleEntry(
          date: Date(),
          object: Object.sample(isPublicDomain: true)))
      .containerBackground(.fill.tertiary, for: .widget)
      .previewContext(WidgetPreviewContext(family: .systemLarge))
      
      // non-public-domain sample object
      
      WidgetView(
        entry: SimpleEntry(
          date: Date(),
          object: Object.sample(isPublicDomain: false)))
      .containerBackground(.fill.tertiary, for: .widget)
      .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
  }
}

//#Preview {
//  WidgetView(
//    entry: SimpleEntry(
//      date: Date(),
//      object: Object.sample(isPublicDomain: true))
//  )
//}

