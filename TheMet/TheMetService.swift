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

import Foundation

struct TheMetService {
  let baseURLString = "https://collectionapi.metmuseum.org/public/collection/v1/"
  let session = URLSession.shared
  let decoder = JSONDecoder()
  
  
  /// Both methods are async because they’ll call `session.data(for:)`, and both methods can rethrow errors thrown by `session.data(for:)`.
  /// The `JSONDecoder` can also throw errors, but these errors are extremely useful for finding any JSON-decoding problems, so you’ll catch and
  /// print them right away. For now, both methods return `nil`, so the compiler doesn’t complain.
  func getObjectIDs(from queryTerm: String) async throws -> ObjectIDs? {
    /// 1 - You’ll decode `data` into `objectIDs`, then return this structure.
    let objectIDs: ObjectIDs?
    
    guard
      var urlComponents = URLComponents(string: baseURLString + "search")
    else {
      /// 2 - You create the `URLRequest`, taking greater care to unwrap most of the optional values.
      return nil
    }
    
    let baseParams = ["hasImages": "true"]
    urlComponents.setQueryItems(with: baseParams)
    urlComponents.queryItems! += [URLQueryItem(name: "q", value: queryTerm)]
    guard let queryURL = urlComponents.url else { return nil }
    let request = URLRequest(url: queryURL)
    
    /// 1 - This is the playground code that calls `data(for:)`, awaits `data` and `response`, then checks the status code.
    /// You add` getObjectIDs` to the print message, so you know which method had the problem. Because getObjectIDs is an asynchronous method, it already runs in an asynchronous context, so you don’t need to embed this code in a Task.
    let (data, response) = try await session.data(for: request)
    guard
      let response = response as? HTTPURLResponse,
      (200..<300).contains(response.statusCode)
    else {
      print(">>> getObjectIDs response outside bounds")
      return nil
    }

    /// 2 - The decoder can throw errors, so you call it in a do-catch statement. You print the raw `error` value, as this gives you
    /// more information about what went wrong.
    do {
      objectIDs = try decoder.decode(ObjectIDs.self, from: data)
    } catch {
      print(error)
      return nil
    }
    /// 3 - If execution reaches this line, everything has worked without errors, and you return `ObjectIDs`.
    return objectIDs

  }
  
  func getObject(from objectID: Int) async throws -> Object? {
    /// 1 - You’ll decode `data` into `object`, then return this structure.
    let object: Object?
    
    /// 2 - You create the` URLRequest`, taking greater care to unwrap the optional value.
    /// You don’t need to use `URLComponent` to construct `objectURLString` because objectID is an Int, so there won’t be any characters that need to be URL-encoded.
    let objectURLString = baseURLString + "objects/\(objectID)"
    guard let objectURL = URL(string: objectURLString) else { return nil }
    let objectRequest = URLRequest(url: objectURL)
    
    /// 3 - This is modified from the playground code that calls `data(for:)`, awaits `data` and `response`,
    /// then checks the status code. Some `objectID` values return 404-not-found, so you print the actual `statusCode` and the problem URL string.
    let (data, response) = try await session.data(for: objectRequest)
    if let response = response as? HTTPURLResponse {
      let statusCode = response.statusCode
      if !(200..<300).contains(statusCode) {
        print(">>> getObject response \(statusCode) outside bounds")
        print(">>> \(objectURLString)")
        return nil
      }
    }
    
    /// 4 - The decoder can throw errors, so you call it in a do-catch statement.
    do {
      object = try decoder.decode(Object.self, from: data)
    } catch {
      print(error)
      return nil
    }
    
    /// 5 - If execution reaches this line, everything has worked without errors, and you return the resulting `Object`.
    return object
  }
}
