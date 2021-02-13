import Foundation

func getMimeTypeSwift(Name: UnsafePointer<Int8>!) -> String {
  let NameStr = String(cString: Name)

  var dot = ""
  if let ExtensionIndex = NameStr.lastIndex(of: ".") {
    dot = String(NameStr[ExtensionIndex...])
  }

  switch dot {
  case ".html":
    return "text/html; charset=iso-8859-1"
  case ".midi":
    return "audio/midi"
  case ".jpg":
    return "image/jpeg"
  case ".jpeg":
    return "image/jpeg"
  case ".mpeg":
    return "video/mpeg"
  case ".gif":
    return "image/gif"
  case ".png":
    return "image/png"
  case ".css":
    return "text/css"
  case ".au":
    return "audio/basic"
  case ".wav":
    return "audio/wav"
  case ".avi":
    return "video/x-msvideo"
  case ".mov":
    return "video/quicktime"
  case ".mp3":
    return "audio/mpeg"
  case ".m4a":
    return "audio/mp4"
  case ".pdf":
    return "application/pdf"
  case ".ogg":
    return "application/ogg"
  default:
    return "text/plain; charset=iso-8859-1"
  }
}

func send_headers(
  status: Int32, title: UnsafePointer<Int8>!,
  mime: UnsafePointer<Int8>!,
  socket: UnsafeMutablePointer<FILE>?,
  len: size_t
) {
  let Title = String(cString: title)
  let Mime = String(cString: mime)

  var HeaderStr = "HTTP/1.1 \(status) \(Title) \r\n" + "Server: swift-httpd\r\n"
  if Mime != "" {
    HeaderStr += "Content-Type: \(Mime) \r\n"
  }

  if len >= 0 {
    HeaderStr += "Content-Length: \(len) \r\n"
  }

  HeaderStr += "Connection: close\r\n\r\n"

  let HeaderCStr = HeaderStr.cString(using: String.Encoding.ascii)
  fwrite(HeaderCStr, 1, strlen(HeaderCStr!), socket)
  fflush(socket)
}

func HttpStart(
  status: Int32,
  socket: UnsafeMutablePointer<FILE>?,
  color: UnsafePointer<Int8>!,
  title: UnsafePointer<Int8>!
) {
  let Mime = "text/html"
  let Color = String(cString: color)
  let Title = String(cString: title)
  let TitleStatus = (status == 200 ? "Ok" : Title)

  send_headers(
    status: status,
    title: TitleStatus.cString(using: String.Encoding.ascii),
    mime: Mime, socket: socket, len: -1)
  let HtmlHeader =
    "<html><head><title>\(Title)</title></head>" + "<body bgcolor=\(Color)>"
    + "<h4>\(Title)</h4><pre>"

  let HtmlHeaderCStr = HtmlHeader.cString(using: String.Encoding.ascii)
  fwrite(HtmlHeaderCStr, 1, strlen(HtmlHeaderCStr!), socket)
}

func HttpEnd(status: Int32, socket: UnsafeMutablePointer<FILE>?) -> Int32 {
  let HtmlFooter = "</pre><a href=\"github.com/plotfi/swift-httpd\">swift-httpd</a></body></html>\n"
  let HtmlFooterCStr = HtmlFooter.cString(using: String.Encoding.ascii)
  fwrite(HtmlFooterCStr, 1, strlen(HtmlFooterCStr!), socket)
  fflush(socket)
  return status
}

func send_error(
  status: Int32,
  socket: UnsafeMutablePointer<FILE>?,
  title: UnsafePointer<Int8>!,
  text: UnsafePointer<Int8>!
) -> Int32 {
  let HtmlHeader = String(status) + " " + String(cString: title)
  let HtmlBody = String(cString: text) == "" ? title : text
  HttpStart(
    status: status, socket: socket, color: "#cc9999",
    title: HtmlHeader)
  fwrite(HtmlBody, 1, strlen(HtmlBody!), socket)
  return HttpEnd(status: status, socket: socket)
}

func doFile(
  filename: UnsafePointer<Int8>!,
  socket: UnsafeMutablePointer<FILE>?
) -> Int32 {
  do {
    let Contents = try Data(
      contentsOf:
        URL(fileURLWithPath: String(cString: filename)))
    var rawBytes: [UInt8] = []
    Contents.withUnsafeBytes {
      rawBytes.append(contentsOf: $0)
    }

    var Buffer: [UInt8] = []
    for byte in rawBytes {
      Buffer.append(byte)
    }

    let Mime = getMimeTypeSwift(Name: filename).cString(using: String.Encoding.ascii)
    send_headers(
      status: 200, title: "Ok",
      mime: Mime,
      socket: socket, len: Buffer.count)

    fwrite(Buffer, 1, Buffer.count, socket)
    fflush(socket)
    return 200
  } catch {
  }

  return 404
}

func CHECK(check: Int, message: UnsafePointer<Int8>!) {
  if check < 0 {
    let Message = String(cString: message)
    print("\(Message) failed: Error\n")
    perror(message)
    exit(EXIT_FAILURE)
  }
}

func http_proto(
  socket: UnsafeMutablePointer<FILE>?,
  request: UnsafePointer<Int8>!
) -> Int32 {

  if request == nil || strlen(request) < strlen("GET / HTTP/1.1") {
    return send_error(
      status: 403, socket: socket,
      title: "Bad Request", text: "No request found.")
  }

  let Request = String(cString: request)
  let FirstLine = Request.split(separator: "\r\n")[0]
  let RequestSubParts = FirstLine.split(separator: " ")

  if RequestSubParts.count != 3 {
    return send_error(
      status: 400, socket: socket,
      title: "Bad Request", text: "Can't parse request.")
  }

  let Method = RequestSubParts[0]
  let Path = RequestSubParts[1]
  // let Protocol = RequestSubParts[2]

  if Method.lowercased() != "get" {
    return send_error(status: 501, socket: socket, title: "Not Impl", text: "")
  }

  if !Path.starts(with: "/") {
    return send_error(
      status: 400, socket: socket,
      title: "Bad Filename", text: "")
  }

  var PathTrim = String(Path)
  PathTrim = String(PathTrim[PathTrim.index(after: PathTrim.startIndex)..<PathTrim.endIndex])

  if PathTrim.count == 0 {
    PathTrim = "./"
  }

  if PathTrim.starts(with: "/") || PathTrim.starts(with: "..") || PathTrim.starts(with: "../")
    || PathTrim.contains("/../") || PathTrim.reversed().starts(with: "../")
  {
    return send_error(
      status: 400, socket: socket,
      title: "Bad Request",
      text: "Illegal filename.")
  }

  let sb = UnsafeMutablePointer<stat>.allocate(capacity: 1)
  if stat(PathTrim.cString(using: String.Encoding.ascii), sb) < 0 {
    return send_error(
      status: 404, socket: socket,
      title: "File Not Found", text: "")
  }

  var isDir: ObjCBool = false
  if !FileManager.default.fileExists(
    atPath: PathTrim,
    isDirectory: &isDir)
  {
    return send_error(
      status: 404, socket: socket,
      title: "File Not Found", text: "")
  }

  var readDir = false
  if isDir.boolValue {
    if !PathTrim.reversed().starts(with: "/") {
      PathTrim += "/"
    }

    if FileManager.default.fileExists(
      atPath: PathTrim + "index.html",
      isDirectory: &isDir)
    {
      PathTrim += "index.html"
    } else {
      readDir = true
    }
  }

  if readDir {
    do {
      let DirectoryContents = try FileManager.default.contentsOfDirectory(atPath: PathTrim)
      HttpStart(
        status: 200, socket: socket,
        color: "lightblue", title: "Index of " + PathTrim)
      var DirListing = ""
      for Entry in DirectoryContents {
        DirListing += "<a href=\"\(Entry)\">\(Entry)</a>\n"
      }
      fwrite(
        DirListing.cString(using: String.Encoding.ascii),
        1, DirListing.count, socket)
      return HttpEnd(status: 200, socket: socket)
    } catch {
      return send_error(
        status: 400, socket: socket,
        title: "Bad Filename", text: "")
    }
  } else {
    print("\n\nPATH: \(PathTrim)\n\n")
    return doFile(filename: PathTrim, socket: socket)
  }
}
