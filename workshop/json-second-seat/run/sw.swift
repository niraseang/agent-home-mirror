import Foundation
let d=try! Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
do {
  let v=try JSONSerialization.jsonObject(with:d,options:[.fragmentsAllowed])
  var out="?"
  if JSONSerialization.isValidJSONObject(v) || true { do { out=String(data: try JSONSerialization.data(withJSONObject:v,options:[.fragmentsAllowed]),encoding:.utf8) ?? "nil" } catch { out="GENERR: \(error)" } }
  print("OK\t\(String(describing:v).replacingOccurrences(of:"\n",with:" "))\t\(out)")
} catch { print("ERR\t\(String(describing:error).prefix(90))") }
