//
//  AMF0EncoderTests.swift
//  
//
//  Created by 郭 輝平 on 2023/06/30.
//

import XCTest
@testable import HPRTMP

final class AMF0EncoderTests: XCTestCase {
  
  let encoder = AMF0Encoder()

  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  
  func testAmf0Value() {
    // Number
    XCTAssertEqual(123.amf0Value, Data([0x00, 0x40, 0x5E, 0xC0, 0x00, 0x00, 0x00, 0x00, 0x00]))
    XCTAssertEqual(3.14.amf0Value, Data([0x00, 0x40, 0x09, 0x1E, 0xB8, 0x51, 0xEB, 0x85, 0x1F]))

    // Boolean
    XCTAssertEqual(true.amf0Value, Data([0x01, 0x01]))
    XCTAssertEqual(false.amf0Value, Data([0x01, 0x00]))
    
    // String
    XCTAssertEqual("hello".amf0Value, Data([0x02, 0x00, 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F]))
    
    // Long String
    let longString = String(repeating: "a", count: Int(UInt16.max) + 1)
    XCTAssertEqual(longString.amf0Value, Data([0x0c, 0x00, 0x01, 0x00, 0x00] + Array(repeating: 0x61, count: Int(UInt16.max) + 1)))
    
    // Date
    let date = Date(timeIntervalSince1970: 10.12)
    XCTAssertEqual(date.amf0Value, Data([0x0b, 0x0, 0x0, 0x0, 0x0, 0x0, 0xc4, 0xc3, 0x40, 0x0, 0x0]))

    // Objects
    let object = ["name": "John", "age": 30] as [String: Any]
    let expectedObjectData1 = Data([0x03, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x02, 0x00, 0x04, 0x4A, 0x6F, 0x68, 0x6E, 0x00, 0x03, 0x61, 0x67, 0x65, 0x00, 0x40, 0x3E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09])
    let expectedObjectData2 = Data([0x03, 0x00, 0x03, 0x61, 0x67, 0x65, 0x00, 0x40, 0x3E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x02, 0x00, 0x04, 0x4A, 0x6F, 0x68, 0x6E, 0x00, 0x00, 0x09])
    
    XCTAssert(object.amf0Encode == expectedObjectData1 || object.amf0Encode == expectedObjectData2)

    // Simple array with Int, String, and Double values
    let array: [Any] = [1, "two", 3.0]
    XCTAssertEqual(array.amf0Value, Data([0x0A, 0x00, 0x00, 0x00, 0x03, 0x00, 0x3F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x03, 0x74, 0x77, 0x6F, 0x00, 0x40, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
    
    // Array of dictionaries
    let dict1: [String: Any] = ["name": "John"]
    let dict2: [String: Any] = ["name": "Jane"]
    let array2 = [dict1, dict2]

    let expectedData = Data([0x0A, 0x00, 0x00, 0x00, 0x02, 0x03, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x02, 0x00, 0x04, 0x4A, 0x6F, 0x68, 0x6E, 0x00, 0x00, 0x09, 0x03, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x02, 0x00, 0x04, 0x4A, 0x61, 0x6E, 0x65, 0x00, 0x00, 0x09])
    XCTAssertEqual(array2.amf0Value, expectedData)
  }
  
  func testEncoder() {
    
    // Number
    XCTAssertEqual(encoder.encode(123), Data([0x00, 0x40, 0x5E, 0xC0, 0x00, 0x00, 0x00, 0x00, 0x00]))
    XCTAssertEqual(encoder.encode(3.14), Data([0x00, 0x40, 0x09, 0x1E, 0xB8, 0x51, 0xEB, 0x85, 0x1F]))
    
    // Boolean
    XCTAssertEqual(encoder.encode(true), Data([0x01, 0x01]))
    XCTAssertEqual(encoder.encode(false), Data([0x01, 0x00]))
    
    // String
    XCTAssertEqual(encoder.encode("hello"), Data([0x02, 0x00, 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F]))
    
    // Long String
    let longString = String(repeating: "a", count: Int(UInt16.max) + 1)
    XCTAssertEqual(encoder.encode(longString), Data([0x0c, 0x00, 0x01, 0x00, 0x00] + Array(repeating: 0x61, count: Int(UInt16.max) + 1)))
    
    // Date
    let date = Date(timeIntervalSince1970: 10.12)
    XCTAssertEqual(encoder.encode(date), Data([0x0b, 0x0, 0x0, 0x0, 0x0, 0x0, 0xc4, 0xc3, 0x40, 0x0, 0x0]))
    
    // Objects
    let object = ["name": "John", "age": 30] as [String: Any]
    let expectedObjectData1 = Data([0x03, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x02, 0x00, 0x04, 0x4A, 0x6F, 0x68, 0x6E, 0x00, 0x03, 0x61, 0x67, 0x65, 0x00, 0x40, 0x3E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09])
    let expectedObjectData2 = Data([0x03, 0x00, 0x03, 0x61, 0x67, 0x65, 0x00, 0x40, 0x3E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x02, 0x00, 0x04, 0x4A, 0x6F, 0x68, 0x6E, 0x00, 0x00, 0x09])

    let data = encoder.encode(object)
    XCTAssert(data == expectedObjectData1 || data == expectedObjectData2)

    // Simple array with Int, String, and Double values
    let array: [Any] = [1, "two", 3.0]
    XCTAssertEqual(encoder.encode(array), Data([0x0A, 0x00, 0x00, 0x00, 0x03, 0x00, 0x3F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x03, 0x74, 0x77, 0x6F, 0x00, 0x40, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))

    // Array of dictionaries
    let dict1: [String: Any] = ["name": "John"]
    let dict2: [String: Any] = ["name": "Jane"]
    let array2 = [dict1, dict2]

    let expectedData = Data([0x0A, 0x00, 0x00, 0x00, 0x02, 0x03, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x02, 0x00, 0x04, 0x4A, 0x6F, 0x68, 0x6E, 0x00, 0x00, 0x09, 0x03, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x02, 0x00, 0x04, 0x4A, 0x61, 0x6E, 0x65, 0x00, 0x00, 0x09])
    XCTAssertEqual(encoder.encode(array2), expectedData)
  }
}
