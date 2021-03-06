import Foundation
import PathKit
import PathKit
import AEXML

// swiftlint:disable:next type_body_length
public struct XCScheme {

    // MARK: - BuildableReference

    public struct BuildableReference {
        public var referencedContainer: String
        public var blueprintIdentifier: String
        public var buildableName: String
        public var buildableIdentifier: String
        public var blueprintName: String

        public init(referencedContainer: String,
                    blueprintIdentifier: String,
                    buildableName: String,
                    blueprintName: String,
                    buildableIdentifier: String = "primary") {
            self.referencedContainer = referencedContainer
            self.blueprintIdentifier = blueprintIdentifier
            self.buildableName = buildableName
            self.buildableIdentifier = buildableIdentifier
            self.blueprintName = blueprintName
        }

        public init(element: AEXMLElement) throws {
            guard let buildableIdentifier = element.attributes["BuildableIdentifier"] else {
                throw XCSchemeError.missing(property: "BuildableIdentifier")
            }
            guard let blueprintIdentifier = element.attributes["BlueprintIdentifier"] else {
                throw XCSchemeError.missing(property: "BlueprintIdentifier")
            }
            guard let buildableName = element.attributes["BuildableName"] else {
                throw XCSchemeError.missing(property: "BuildableName")
            }
            guard let blueprintName = element.attributes["BlueprintName"] else {
                throw XCSchemeError.missing(property: "BlueprintName")
            }
            guard let referencedContainer = element.attributes["ReferencedContainer"] else {
                throw XCSchemeError.missing(property: "ReferencedContainer")
            }
            self.buildableIdentifier = buildableIdentifier
            self.blueprintIdentifier = blueprintIdentifier
            self.buildableName = buildableName
            self.blueprintName = blueprintName
            self.referencedContainer = referencedContainer
        }

        public func xmlElement() -> AEXMLElement {
            return AEXMLElement(name: "BuildableReference",
                                value: nil,
                                attributes: ["BuildableIdentifier": buildableIdentifier,
                                             "BlueprintIdentifier": blueprintIdentifier,
                                             "BuildableName": buildableName,
                                             "BlueprintName": blueprintName,
                                             "ReferencedContainer": referencedContainer])
        }
    }

    public struct TestableReference {
        public var skipped: Bool
        public var buildableReference: BuildableReference
        public init(skipped: Bool,
                    buildableReference: BuildableReference) {
            self.skipped = skipped
            self.buildableReference = buildableReference
        }
        public init(element: AEXMLElement) throws {
            self.skipped = element.attributes["skipped"] == "YES"
            self.buildableReference = try BuildableReference(element: element["BuildableReference"])
        }
        public func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "TestableReference",
                                       value: nil,
                                       attributes: ["skipped": skipped.xmlString])
            element.addChild(buildableReference.xmlElement())
            return element
        }
    }

    public struct LocationScenarioReference {
        public var identifier: String
        public var referenceType: String
        public init(identifier: String, referenceType: String) {
            self.identifier = identifier
            self.referenceType = referenceType
        }
        public init(element: AEXMLElement) throws {
            self.identifier = element.attributes["identifier"]!
            self.referenceType = element.attributes["referenceType"]!
        }
        public func xmlElement() -> AEXMLElement {
            return AEXMLElement(name: "LocationScenarioReference",
                                value: nil,
                                attributes: ["identifier": identifier,
                                             "referenceType": referenceType])
        }
    }

    public struct BuildableProductRunnable {
        public var runnableDebuggingMode: String
        public var buildableReference: BuildableReference
        public init(buildableReference: BuildableReference,
                    runnableDebuggingMode: String = "0") {
            self.buildableReference = buildableReference
            self.runnableDebuggingMode = runnableDebuggingMode
        }
        public init(element: AEXMLElement) throws {
            self.runnableDebuggingMode = element.attributes["runnableDebuggingMode"] ?? "0"
            self.buildableReference = try BuildableReference(element:  element["BuildableReference"])
        }
        public func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "BuildableProductRunnable",
                                       value: nil,
                                       attributes: ["runnableDebuggingMode": runnableDebuggingMode])
            element.addChild(buildableReference.xmlElement())
            return element
        }
    }

    // MARK: - Build Action

    public struct BuildAction {

        public struct Entry {

            public enum BuildFor {
                case running, testing, profiling, archiving, analyzing
                public static var `default`: [BuildFor] = [.running, .testing, .archiving, .analyzing]
                public static var indexing: [BuildFor] = [.testing, .analyzing, .archiving]
                public static var testOnly: [BuildFor] = [.testing, .analyzing]
            }

            public var buildableReference: BuildableReference
            public var buildFor: [BuildFor]

            public init(buildableReference: BuildableReference,
                        buildFor: [BuildFor]) {
                self.buildableReference = buildableReference
                self.buildFor = buildFor
            }
            public init(element: AEXMLElement) throws {
                var buildFor: [BuildFor] = []
                if element.attributes["buildForTesting"] == "YES" {
                    buildFor.append(.testing)
                }
                if element.attributes["buildForRunning"] == "YES" {
                    buildFor.append(.running)
                }
                if element.attributes["buildForProfiling"] == "YES" {
                    buildFor.append(.profiling)
                }
                if element.attributes["buildForArchiving"] == "YES" {
                    buildFor.append(.archiving)
                }
                if element.attributes["buildForAnalyzing"] == "YES" {
                    buildFor.append(.analyzing)
                }
                self.buildFor = buildFor
                self.buildableReference = try BuildableReference(element: element["BuildableReference"])
            }
            public func xmlElement() -> AEXMLElement {
                var attributes: [String: String] = [:]
                attributes["buildForTesting"] = buildFor.contains(.testing) ? "YES" : "NO"
                attributes["buildForRunning"] = buildFor.contains(.running) ? "YES" : "NO"
                attributes["buildForProfiling"] = buildFor.contains(.profiling) ? "YES" : "NO"
                attributes["buildForArchiving"] = buildFor.contains(.archiving) ? "YES" : "NO"
                attributes["buildForAnalyzing"] = buildFor.contains(.analyzing) ? "YES" : "NO"
                let element = AEXMLElement(name: "BuildActionEntry",
                                           value: nil,
                                           attributes: attributes)
                element.addChild(buildableReference.xmlElement())
                return element
            }
        }

        public var buildActionEntries: [Entry]
        public var parallelizeBuild: Bool
        public var buildImplicitDependencies: Bool

        public init(buildActionEntries: [Entry] = [],
                    parallelizeBuild: Bool = false,
                    buildImplicitDependencies: Bool = false) {
            self.buildActionEntries = buildActionEntries
            self.parallelizeBuild = parallelizeBuild
            self.buildImplicitDependencies = buildImplicitDependencies
        }

        public init(element: AEXMLElement) throws {
            parallelizeBuild = element.attributes["parallelizeBuildables"]! == "YES"
            buildImplicitDependencies = element.attributes["buildImplicitDependencies"] == "YES"
            self.buildActionEntries = try element["BuildActionEntries"]["BuildActionEntry"]
                .all?
                .map(Entry.init) ?? []
        }

        public func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "BuildAction",
                                       value: nil,
                                       attributes: ["parallelizeBuildables": parallelizeBuild.xmlString,
                                                    "buildImplicitDependencies": buildImplicitDependencies.xmlString])
            let entries = element.addChild(name: "BuildActionEntries")
            buildActionEntries.forEach { (entry) in
                entries.addChild(entry.xmlElement())
            }
            return element
        }

        public func add(buildActionEntry: Entry) -> BuildAction {
            var buildActionEntries = self.buildActionEntries
            buildActionEntries.append(buildActionEntry)
            return BuildAction(buildActionEntries: buildActionEntries,
                               parallelizeBuild: parallelizeBuild)
        }
    }

    public struct LaunchAction {

        public enum Style: String {
            case auto = "0"
            case wait = "1"
        }

        public var buildableProductRunnable: BuildableProductRunnable
        public var selectedDebuggerIdentifier: String
        public var selectedLauncherIdentifier: String
        public var buildConfiguration: String
        public var launchStyle: Style
        public var useCustomWorkingDirectory: Bool
        public var ignoresPersistentStateOnLaunch: Bool
        public var debugDocumentVersioning: Bool
        public var debugServiceExtension: String
        public var allowLocationSimulation: Bool
        public var locationScenarioReference: LocationScenarioReference?

        public init(buildableProductRunnable: BuildableProductRunnable,
                    buildConfiguration: String,
                    selectedDebuggerIdentifier: String = "Xcode.DebuggerFoundation.Debugger.LLDB",
                    selectedLauncherIdentifier: String = "Xcode.DebuggerFoundation.Launcher.LLDB",
                    launchStyle: Style = .auto,
                    useCustomWorkingDirectory: Bool = false,
                    ignoresPersistentStateOnLaunch: Bool = false,
                    debugDocumentVersioning: Bool = true,
                    debugServiceExtension: String = "internal",
                    allowLocationSimulation: Bool = true,
                    locationScenarioReference: LocationScenarioReference? = nil) {
            self.buildableProductRunnable = buildableProductRunnable
            self.buildConfiguration = buildConfiguration
            self.launchStyle = launchStyle
            self.selectedDebuggerIdentifier = selectedDebuggerIdentifier
            self.selectedLauncherIdentifier = selectedLauncherIdentifier
            self.useCustomWorkingDirectory = useCustomWorkingDirectory
            self.ignoresPersistentStateOnLaunch = ignoresPersistentStateOnLaunch
            self.debugDocumentVersioning = debugDocumentVersioning
            self.debugServiceExtension = debugServiceExtension
            self.allowLocationSimulation = allowLocationSimulation
            self.locationScenarioReference = locationScenarioReference
        }

        public init(element: AEXMLElement) throws {
            guard let buildConfiguration = element.attributes["buildConfiguration"] else {
                throw XCSchemeError.missing(property: "buildConfiguration")
            }
            guard let selectedDebuggerIdentifier = element.attributes["selectedDebuggerIdentifier"] else {
                throw XCSchemeError.missing(property: "selectedDebuggerIdentifier")
            }
            guard let selectedLauncherIdentifier = element.attributes["selectedLauncherIdentifier"] else {
                throw XCSchemeError.missing(property: "selectedLauncherIdentifier")
            }
            guard let launchStyle = element.attributes["launchStyle"] else {
                throw XCSchemeError.missing(property: "launchStyle")
            }
            guard let debugServiceExtension = element.attributes["debugServiceExtension"] else {
                throw XCSchemeError.missing(property: "debugServiceExtension")
            }
            self.buildConfiguration = buildConfiguration
            self.selectedDebuggerIdentifier = selectedDebuggerIdentifier
            self.selectedLauncherIdentifier = selectedLauncherIdentifier
            self.launchStyle = Style(rawValue: launchStyle) ?? .auto
            self.useCustomWorkingDirectory = element.attributes["useCustomWorkingDirectory"] == "YES"
            self.ignoresPersistentStateOnLaunch = element.attributes["ignoresPersistentStateOnLaunch"] == "YES"
            self.debugDocumentVersioning = element.attributes["debugDocumentVersioning"] == "YES"
            self.debugServiceExtension = debugServiceExtension
            self.allowLocationSimulation = element.attributes["allowLocationSimulation"] == "YES"
            self.buildableProductRunnable = try BuildableProductRunnable(element:  element["BuildableProductRunnable"])
            if element["LocationScenarioReference"].all?.first != nil {
                self.locationScenarioReference = try LocationScenarioReference(element: element["LocationScenarioReference"])
            } else {
                self.locationScenarioReference = nil
            }
        }
        public func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "LaunchAction",
                                       value: nil,
                                       attributes: ["buildConfiguration": buildConfiguration,
                                                    "selectedDebuggerIdentifier": selectedDebuggerIdentifier,
                                                    "selectedLauncherIdentifier": selectedLauncherIdentifier,
                                                    "launchStyle": launchStyle.rawValue,
                                                    "useCustomWorkingDirectory": useCustomWorkingDirectory.xmlString,
                                                    "ignoresPersistentStateOnLaunch": ignoresPersistentStateOnLaunch.xmlString,
                                                    "debugDocumentVersioning": debugDocumentVersioning.xmlString,
                                                    "debugServiceExtension": debugServiceExtension,
                                                    "allowLocationSimulation": allowLocationSimulation.xmlString])
            element.addChild(buildableProductRunnable.xmlElement())
            if let locationScenarioReference = locationScenarioReference {
                element.addChild(locationScenarioReference.xmlElement())
            }
            return element
        }
    }

    public struct ProfileAction {
        public var buildableProductRunnable: BuildableProductRunnable
        public var buildConfiguration: String
        public var shouldUseLaunchSchemeArgsEnv: Bool
        public var savedToolIdentifier: String
        public var useCustomWorkingDirectory: Bool
        public var debugDocumentVersioning: Bool
        public init(buildableProductRunnable: BuildableProductRunnable,
                    buildConfiguration: String,
                    shouldUseLaunchSchemeArgsEnv: Bool = true,
                    savedToolIdentifier: String = "",
                    useCustomWorkingDirectory: Bool = false,
                    debugDocumentVersioning: Bool = true) {
            self.buildableProductRunnable = buildableProductRunnable
            self.buildConfiguration = buildConfiguration
            self.shouldUseLaunchSchemeArgsEnv = shouldUseLaunchSchemeArgsEnv
            self.savedToolIdentifier = savedToolIdentifier
            self.useCustomWorkingDirectory = useCustomWorkingDirectory
            self.debugDocumentVersioning = debugDocumentVersioning
        }
        public init(element: AEXMLElement) throws {
            guard let buildConfiguration = element.attributes["buildConfiguration"] else {
                throw XCSchemeError.missing(property: "buildConfiguration")
            }
            guard let savedToolIdentifier = element.attributes["savedToolIdentifier"] else {
                throw XCSchemeError.missing(property: "savedToolIdentifier")
            }
            self.buildConfiguration = buildConfiguration
            self.shouldUseLaunchSchemeArgsEnv = element.attributes["shouldUseLaunchSchemeArgsEnv"] == "YES"
            self.savedToolIdentifier = savedToolIdentifier
            self.useCustomWorkingDirectory = element.attributes["useCustomWorkingDirectory"] == "YES"
            self.debugDocumentVersioning = element.attributes["debugDocumentVersioning"] == "YES"
            self.buildableProductRunnable = try BuildableProductRunnable(element: element["BuildableProductRunnable"])
        }
        public func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "ProfileAction",
                                       value: nil,
                                       attributes: ["buildConfiguration": buildConfiguration,
                                                    "shouldUseLaunchSchemeArgsEnv": shouldUseLaunchSchemeArgsEnv.xmlString,
                                                    "savedToolIdentifier": savedToolIdentifier,
                                                    "useCustomWorkingDirectory": useCustomWorkingDirectory.xmlString,
                                                    "debugDocumentVersioning": debugDocumentVersioning.xmlString])
            element.addChild(buildableProductRunnable.xmlElement())
            return element
        }
    }

    public struct TestAction {
        public var testables: [TestableReference]
        public var buildConfiguration: String
        public var selectedDebuggerIdentifier: String
        public var selectedLauncherIdentifier: String
        public var shouldUseLaunchSchemeArgsEnv: Bool
        public var macroExpansion: BuildableReference
        public init(buildConfiguration: String,
                    macroExpansion: BuildableReference,
                    testables: [TestableReference] = [],
                    selectedDebuggerIdentifier: String = "Xcode.DebuggerFoundation.Debugger.LLDB",
                    selectedLauncherIdentifier: String = "Xcode.DebuggerFoundation.Launcher.LLDB",
                    shouldUseLaunchSchemeArgsEnv: Bool = true) {
            self.buildConfiguration = buildConfiguration
            self.macroExpansion = macroExpansion
            self.testables = testables
            self.selectedDebuggerIdentifier = selectedDebuggerIdentifier
            self.selectedLauncherIdentifier = selectedLauncherIdentifier
            self.shouldUseLaunchSchemeArgsEnv = shouldUseLaunchSchemeArgsEnv
        }
        public init(element: AEXMLElement) throws {
            guard let buildConfiguration = element.attributes["buildConfiguration"] else {
                throw XCSchemeError.missing(property: "buildConfiguration")
            }
            guard let selectedDebuggerIdentifier = element.attributes["selectedDebuggerIdentifier"] else {
                throw XCSchemeError.missing(property: "selectedDebuggerIdentifier")
            }
            guard let selectedLauncherIdentifier = element.attributes["selectedLauncherIdentifier"] else {
                throw XCSchemeError.missing(property: "selectedLauncherIdentifier")
            }
            self.buildConfiguration = buildConfiguration
            self.selectedDebuggerIdentifier = selectedDebuggerIdentifier
            self.selectedLauncherIdentifier = selectedLauncherIdentifier
            self.shouldUseLaunchSchemeArgsEnv = element.attributes["shouldUseLaunchSchemeArgsEnv"] == "YES"
            self.testables = try element["Testables"]["TestableReference"]
                .all?
                .map(TestableReference.init) ?? []
            self.macroExpansion = try BuildableReference(element: element["MacroExpansion"]["BuildableReference"])
        }
        public func xmlElement() -> AEXMLElement {
            var attributes: [String: String] = [:]
            attributes["buildConfiguration"] = buildConfiguration
            attributes["selectedDebuggerIdentifier"] = selectedDebuggerIdentifier
            attributes["selectedLauncherIdentifier"] = selectedLauncherIdentifier
            attributes["shouldUseLaunchSchemeArgsEnv"] = shouldUseLaunchSchemeArgsEnv.xmlString
            let element = AEXMLElement(name: "TestAction", value: nil, attributes: attributes)
            let testablesElement = element.addChild(name: "Testables")
            testables.forEach { (testable) in
                testablesElement.addChild(testable.xmlElement())
            }
            let macro = element.addChild(name: "MacroExpansion")
            macro.addChild(macroExpansion.xmlElement())
            return element
        }
    }

    public struct AnalyzeAction {
        public var buildConfiguration: String
        public init(buildConfiguration: String) {
            self.buildConfiguration = buildConfiguration
        }
        public init(element: AEXMLElement) throws {
            guard let buildConfiguration = element.attributes["buildConfiguration"] else {
                throw XCSchemeError.missing(property: "buildConfiguration")
            }
            self.buildConfiguration = buildConfiguration
        }
        public func xmlElement() -> AEXMLElement {
            var attributes: [String: String] = [:]
            attributes["buildConfiguration"] = buildConfiguration
            return AEXMLElement(name: "AnalyzeAction", value: nil, attributes: attributes)
        }
    }

    public struct ArchiveAction {
        public var buildConfiguration: String
        public var revealArchiveInOrganizer: Bool
        public var customArchiveName: String?
        public init(buildConfiguration: String,
                    revealArchiveInOrganizer: Bool,
                    customArchiveName: String? = nil) {
            self.buildConfiguration = buildConfiguration
            self.revealArchiveInOrganizer = revealArchiveInOrganizer
            self.customArchiveName = customArchiveName
        }
        public init(element: AEXMLElement) throws {
            guard let buildConfiguration = element.attributes["buildConfiguration"] else {
                throw XCSchemeError.missing(property: "buildConfiguration")
            }
            guard let customArchiveName = element.attributes["customArchiveName"] else {
                throw XCSchemeError.missing(property: "customArchiveName")
            }
            self.buildConfiguration = buildConfiguration
            self.revealArchiveInOrganizer = element.attributes["revealArchiveInOrganizer"] == "YES"
            self.customArchiveName = customArchiveName
        }
        public func xmlElement() -> AEXMLElement {
            var attributes: [String: String] = [:]
            attributes["buildConfiguration"] = buildConfiguration
            attributes["customArchiveName"] = customArchiveName
            attributes["revealArchiveInOrganizer"] = revealArchiveInOrganizer.xmlString
            return AEXMLElement(name: "ArchiveAction", value: nil, attributes: attributes)
        }
    }

    // MARK: - Properties

    public var buildAction: BuildAction?
    public var testAction: TestAction?
    public var launchAction: LaunchAction?
    public var profileAction: ProfileAction?
    public var analyzeAction: AnalyzeAction?
    public var archiveAction: ArchiveAction?
    public var lastUpgradeVersion: String?
    public var version: String?
    public var name: String

    // MARK: - Init

    /// Initializes the scheme reading the content from the disk.
    ///
    /// - Parameters:
    ///   - path: scheme path.
    public init(path: Path) throws {
        if !path.exists {
            throw XCSchemeError.notFound(path: path)
        }
        name = path.lastComponent
        let document = try AEXMLDocument(xml: try path.read())
        let scheme = document["Scheme"]
        lastUpgradeVersion = scheme.attributes["LastUpgradeVersion"]
        version = scheme.attributes["version"]
        buildAction = try BuildAction(element: scheme["BuildAction"])
        testAction = try TestAction(element: scheme["TestAction"])
        launchAction = try LaunchAction(element: scheme["LaunchAction"])
        analyzeAction = try AnalyzeAction(element: scheme["AnalyzeAction"])
        archiveAction = try ArchiveAction(element: scheme["ArchiveAction"])
        profileAction = try ProfileAction(element: scheme["ProfileAction"])
    }

    public init(name: String,
                lastUpgradeVersion: String?,
                version: String?,
                buildAction: BuildAction? = nil,
                testAction: TestAction? = nil,
                launchAction: LaunchAction? = nil,
                profileAction: ProfileAction? = nil,
                analyzeAction: AnalyzeAction? = nil,
                archiveAction: ArchiveAction? = nil) {
        self.name = name
        self.lastUpgradeVersion = lastUpgradeVersion
        self.version = version
        self.buildAction = buildAction
        self.testAction = testAction
        self.launchAction = launchAction
        self.profileAction = profileAction
        self.analyzeAction = analyzeAction
        self.archiveAction = archiveAction
    }

}

// MARK: - XCScheme Extension (Writable)

extension XCScheme: Writable {

    public func write(path: Path, override: Bool) throws {
        let document = AEXMLDocument()
        var schemeAttributes: [String: String] = [:]
        schemeAttributes["LastUpgradeVersion"] = lastUpgradeVersion
        schemeAttributes["version"] = version
        let scheme = document.addChild(name: "Scheme", value: nil, attributes: schemeAttributes)
        if let analyzeAction = analyzeAction {
            scheme.addChild(analyzeAction.xmlElement())
        }
        if let archiveAction = archiveAction {
            scheme.addChild(archiveAction.xmlElement())
        }
        if let testAction = testAction {
            scheme.addChild(testAction.xmlElement())
        }
        if let profileAction = profileAction {
            scheme.addChild(profileAction.xmlElement())
        }
        if let buildAction = buildAction {
            scheme.addChild(buildAction.xmlElement())
        }
        if let launchAction = launchAction {
            scheme.addChild(launchAction.xmlElement())
        }
        if override && path.exists {
            try path.delete()
        }
        try path.write(document.xml)
    }

}

// MARK: - XCScheme Errors.

/// XCScheme Errors.
///
/// - notFound: returned when the .xcscheme cannot be found.
/// - missing: returned when there's a property missing in the .xcscheme.
public enum XCSchemeError: Error, CustomStringConvertible {
    case notFound(path: Path)
    case missing(property: String)

    public var description: String {
        switch self {
        case .notFound(let path):
            return ".xcscheme couldn't be found at path \(path)"
        case .missing(let property):
            return "Property \(property) missing"
        }
    }
}
