// Prints the text of a PDF using macOS PDFKit. Usage: swift tools/pdftext.swift file.pdf
import PDFKit
let doc = PDFDocument(url: URL(fileURLWithPath: CommandLine.arguments[1]))!
for i in 0..<doc.pageCount { print("--- page \(i+1)"); print(doc.page(at: i)?.string ?? "") }
