import Foundation
let d=try! Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
let a=try! JSONSerialization.jsonObject(with:d) as! [Any]
let n=a[0] as! NSNumber
let t=String(cString:n.objCType)
var dv=n.doubleValue; let bits=withUnsafeBytes(of:&dv){Data($0)}.map{String(format:"%02x",$0)}.joined()
let out=String(data:try! JSONSerialization.data(withJSONObject:a),encoding:.utf8)!
print("NSNumber(\(t)) bits=\(bits)\t\(out)")
