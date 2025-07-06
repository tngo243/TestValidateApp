/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A simple class that represents an entry from the `Streams.plist` file in the main application bundle.
*/

import Foundation

struct Stream: Codable, Sendable {
  
  // MARK: Types
  
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case name = "name"
    case playlistURL = "playlist_url"
  }
  
  // MARK: Properties
  let id: String
  
  /// The name of the stream.
  let name: String
  
  /// The URL pointing to the HLS stream.
  let playlistURL: String
  
}

extension Stream: Equatable {
  static func ==(lhs: Stream, rhs: Stream) -> Bool {
    return (lhs.name == rhs.name) && (lhs.playlistURL == rhs.playlistURL)
  }
}
