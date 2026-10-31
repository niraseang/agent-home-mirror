import Foundation
for s in ["[-0]","[-0.0]"] { let a = try! JSONSerialization.jsonObject(with: s.data(using:.utf8)!) as! [NSNumber]; print("swift", s, a[0].doubleValue.sign == .minus, String(cString: a[0].objCType)) }
