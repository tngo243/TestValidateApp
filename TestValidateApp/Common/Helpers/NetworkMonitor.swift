//
//  NetworkMonitor.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 11/7/25.
//

import Foundation
import Combine
import Network

// MARK: - Network Condition Models
enum NetworkCondition: Equatable {
    case connected(ConnectionType)
    case disconnected
    case connecting
    case unknown
    
    var isConnected: Bool {
        switch self {
        case .connected:
            return true
        default:
            return false
        }
    }
}

enum ConnectionType: Equatable {
    case wifi
    case cellular
    case ethernet
    case other
}

struct NetworkStatus: Equatable {
    let condition: NetworkCondition
    let isExpensive: Bool
    let isConstrained: Bool
    let timestamp: Date
    
    init(condition: NetworkCondition, isExpensive: Bool = false, isConstrained: Bool = false) {
        self.condition = condition
        self.isExpensive = isExpensive
        self.isConstrained = isConstrained
        self.timestamp = Date()
    }
}

// MARK: - Network Condition Monitor
class NetworkConditionMonitor: ObservableObject {
    static let shared = NetworkConditionMonitor()
    
    // MARK: - Publishers
    private let networkStatusSubject = CurrentValueSubject<NetworkStatus, Never>(
        NetworkStatus(condition: .unknown)
    )
    
    // Public publishers
    var networkStatus: AnyPublisher<NetworkStatus, Never> {
        networkStatusSubject.eraseToAnyPublisher()
    }
    
    var isConnected: AnyPublisher<Bool, Never> {
        networkStatusSubject
            .map { $0.condition.isConnected }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var connectionType: AnyPublisher<ConnectionType?, Never> {
        networkStatusSubject
            .map { status in
                switch status.condition {
                case .connected(let type):
                    return type
                default:
                    return nil
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    private var pathMonitor: NWPathMonitor?
    private let monitorQueue = DispatchQueue(label: "network.condition.monitor", qos: .utility)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Current Status (Synchronous Access)
    var currentStatus: NetworkStatus {
        networkStatusSubject.value
    }
    
    var currentlyConnected: Bool {
        currentStatus.condition.isConnected
    }
    
    // MARK: - Initialization
    init() {
        startMonitoring()
    }
    
    // MARK: - Public Methods
    func startMonitoring() {
        stopMonitoring()
        
        pathMonitor = NWPathMonitor()
        
        pathMonitor?.pathUpdateHandler = { [weak self] path in
            self?.handlePathUpdate(path)
        }
        
        pathMonitor?.start(queue: monitorQueue)
    }
    
    func stopMonitoring() {
        pathMonitor?.cancel()
        pathMonitor = nil
    }
    
    // MARK: - Private Methods
    private func handlePathUpdate(_ path: NWPath) {
        let condition = determineNetworkCondition(from: path)
        let status = NetworkStatus(
            condition: condition,
            isExpensive: path.isExpensive,
            isConstrained: path.isConstrained
        )
        
        // Add debounce for network transitions to avoid false negatives
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            // Double check the status before updating
            if let self = self, let monitor = self.pathMonitor {
                let currentPath = monitor.currentPath
                let finalCondition = self.determineNetworkCondition(from: currentPath)
                let finalStatus = NetworkStatus(
                    condition: finalCondition,
                    isExpensive: currentPath.isExpensive,
                    isConstrained: currentPath.isConstrained
                )
                self.networkStatusSubject.send(finalStatus)
            }
        }
    }
    
    private func determineNetworkCondition(from path: NWPath) -> NetworkCondition {
        switch path.status {
        case .satisfied:
            return .connected(determineConnectionType(from: path))
        case .unsatisfied:
            return .disconnected
        case .requiresConnection:
            // During wifi reconnection, this state might appear briefly
            // Check if we have available interfaces
            if path.availableInterfaces.count > 0 {
                return .connecting
            } else {
                return .disconnected
            }
        @unknown default:
            return .unknown
        }
    }
    
    private func determineConnectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .other
        }
    }
    
    deinit {
        stopMonitoring()
    }
}

// MARK: - Convenience Extensions
extension NetworkConditionMonitor {
    
    // Publisher that emits when network becomes available
    var onNetworkAvailable: AnyPublisher<NetworkStatus, Never> {
        networkStatus
            .filter { $0.condition.isConnected }
            .eraseToAnyPublisher()
    }
    
    // Publisher that emits when network becomes unavailable
    var onNetworkUnavailable: AnyPublisher<NetworkStatus, Never> {
        networkStatus
            .filter { !$0.condition.isConnected }
            .eraseToAnyPublisher()
    }
    
    // Publisher that emits only when connection type changes
    var onConnectionTypeChange: AnyPublisher<ConnectionType?, Never> {
        connectionType
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // Publisher for expensive network conditions (cellular)
    var isExpensiveConnection: AnyPublisher<Bool, Never> {
        networkStatus
            .map { $0.isExpensive }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // Publisher for constrained network conditions
    var isConstrainedConnection: AnyPublisher<Bool, Never> {
        networkStatus
            .map { $0.isConstrained }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
