import os.log

enum Logger {
    private static let subsystem = "dev.openclaw.hamsterim"

    static func log(_ message: String) {
        os_log("%{public}@", log: .init(subsystem: subsystem, category: "General"), type: .info, message)
    }

    static func error(_ message: String) {
        os_log("%{public}@", log: .init(subsystem: subsystem, category: "Error"), type: .error, message)
    }
}
