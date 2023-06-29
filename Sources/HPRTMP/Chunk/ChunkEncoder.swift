import Foundation

class ChunkEncoder {
  
  static let maxChunkSize: UInt8 = 128
  
  var chunkSize = UInt32(ChunkEncoder.maxChunkSize)
  
  func chunk(message: RTMPMessage & RTMPEncodable, isFirstType0: Bool = true) -> [Chunk] {
    let payload = message.encode()
    
    return payload.split(size: Int(chunkSize))
      .enumerated()
      .map({
        // basic Header
        // Type 0 == first chunk , other use type 3
        let messageHeader: MessageHeader
        
        if $0.offset == 0 {
          if isFirstType0 {
            messageHeader = MessageHeaderType0(timestamp: message.timestamp,
                                               messageLength: payload.count,
                                               type: message.messageType ,
                                               messageStreamId: message.msgStreamId)
          } else {
            messageHeader = MessageHeaderType1(timestampDelta: message.timestamp,
                                               messageLength: payload.count,
                                               type: message.messageType)
          }
        } else {
          messageHeader = MessageHeaderType3()
        }
        
        let header = ChunkHeader(streamId: message.streamId,
                                 messageHeader: messageHeader)
        
        return Chunk(chunkHeader: header, chunkData: Data($0.element))
        
      })
  }
}


