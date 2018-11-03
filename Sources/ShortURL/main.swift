import Foundation
import Application
import LoggerAPI
import HeliumLogger

do {

    HeliumLogger.use(LoggerMessageType.info)

    let app = try App()
    try app.run()

} catch let error {
    Log.error(error.localizedDescription)
}
