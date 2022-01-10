//
//  State.swift
//  Magiko
//
//  Created by Janice Hablützel on 10.01.22.
//

import UIKit

struct Status {
    let name: String
    let element: Element
    
    var duration: Int
}

enum States {
    case fine
    case burned
    
    func getStatus() -> Status {
        switch self {
            case .fine:
                return Status(name: "Fine", element: Element(), duration: 3)
            default:
                return Status(name: "Fainted", element: GlobalData.shared.elements["Aether"] ?? Element(), duration: -1)
        }
    }
    
    func getStatus(element: String) -> Status {
        switch element {
            case "Plant":
                return Status(name: "Trapped", element: Element(), duration: 3)
            default:
                return Status(name: "Fine", element: Element(), duration: -1)
        }
    }
}
