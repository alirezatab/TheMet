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

/*
 Note: You can annotate a method with @MainActor to ensure it runs on the main thread or annotate a property to ensure it can only be updated from the main thread. Or you can annotate an entire class with @MainActor, if almost all its properties and methods need to be on the main thread, then mark any exceptions with the nonisolated keyword. Learn more about Swift concurrency from our book Modern Concurrency in Swift or video courses Modern Concurrency: Getting Started and Modern Concurrency: Beyond the Basics.
 */

import Foundation

class TheMetStore: ObservableObject {
  @Published var objects: [Object] = []

  let service = TheMetService()
  let maxIndex: Int
  
  init(_ maxIndex: Int = 30) {
    self.maxIndex = maxIndex
    
    /*
    #if DEBUG
    createDevData()
    #endif
     */
  }
    
  func fetchObjects(for queryTerm: String) async throws {
    /// 1 - First, you call `getObjectIDs(from:)` and wait for it to return `objectIDs`.
    if let objectIDs = try await service.getObjectIDs(from: queryTerm) {
      /// 2 - Then, you loop over `objectIDs.objectIDs` — at most `maxIndex` of them — calling `getObject(from:)` for each `objectID`. If it returns an `Object`, you append it to your `objects` array.
      for (index, objectID) in objectIDs.objectIDs.enumerated() where index < maxIndex {
        if let object = try await service.getObject(from: objectID) {
          await MainActor.run {
            objects.append(object)            
          }
        }
      }
    }
  }
}
