//
//  CrewModels.swift
//  DemoYachtTvOSApp
//
//  Created by Haitham Gado on 06/10/2025.
//

import Foundation

struct Department: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
    let order: Int
    enum CodingKeys: String, CodingKey { case id = "_id", name, order }
    init(id: String, name: String, order: Int) { self.id = id; self.name = name; self.order = order }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id    = (try? c.decode(String.self, forKey: .id)) ?? UUID().uuidString
        name  = (try? c.decode(String.self, forKey: .name)) ?? "Unknown"
        order = (try? c.decode(Int.self, forKey: .order)) ?? 999
    }
}

struct CrewMember: Identifiable, Decodable {
    let id: String
    @Default var name: String
    @Default var role: String
    @Default var order: Int
    @Default var age: Int
    @Default var country: String
    @Default var description: String
    let department: Department
    let photoPath: String?

    private struct PathBox: Decodable { let path: String? }

    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case role
        case order
        case age            // ← add
        case country        // ← add
        case department
        case path, photo, image, avatar, files
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id         = (try? c.decode(String.self, forKey: .id)) ?? UUID().uuidString
        _name      = (try? c.decode(Default<String>.self, forKey: .name)) ?? Default()
        _role      = (try? c.decode(Default<String>.self, forKey: .role)) ?? Default()
        _order     = (try? c.decode(Default<Int>.self,   forKey: .order)) ?? Default()
        _age       = (try? c.decode(Default<Int>.self, forKey: .age)) ?? Default()
        _country   = (try? c.decode(Default<String>.self, forKey: .country)) ?? Default()
        department = (try? c.decode(Department.self, forKey: .department))
                     ?? Department(id: "unknown", name: "Unknown", order: 999)

        if let direct = try? c.decodeIfPresent(String.self, forKey: .path), !(direct.isEmpty) {
            photoPath = direct
        } else if let pb = try? c.decodeIfPresent(PathBox.self, forKey: .photo), let p = pb.path, !p.isEmpty {
            photoPath = p
        } else if let ib = try? c.decodeIfPresent(PathBox.self, forKey: .image), let p = ib.path, !p.isEmpty {
            photoPath = p
        } else if let ab = try? c.decodeIfPresent(PathBox.self, forKey: .avatar), let p = ab.path, !p.isEmpty {
            photoPath = p
        } else if let arr = try? c.decodeIfPresent([PathBox].self, forKey: .files),
                  let p = arr.first?.path, !(p.isEmpty) {
            photoPath = p
        } else {
            photoPath = nil
        }
    }

    var imageURL: URL? {
        guard let p = photoPath, !p.isEmpty else { return nil }
        if let u = URL(string: "https://collector-dev.superyachtapi.com/files/download/" + p) { return u }
        let encoded = p.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? p
        return URL(string: "https://collector-dev.superyachtapi.com/files/download/" + encoded)
    }
}

extension Array where Element == CrewMember {
    func sortedByBusinessOrder() -> [CrewMember] {
        sorted {
            $0.department.order != $1.department.order
            ? $0.department.order < $1.department.order
            : $0.order < $1.order
        }
    }
}

extension CrewMember {
    var flagEmoji: String? {
        let code = country.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        guard code.count == 2 else { return nil }
        let base: UInt32 = 0x1F1E6 // Regional Indicator Symbol Letter A
        var scalarView = String.UnicodeScalarView()
        for u in code.unicodeScalars {
            let v = u.value
            guard v >= 65 && v <= 90 else { return nil } // A-Z
            scalarView.append(UnicodeScalar(base + (v - 65))!)
        }
        return String(scalarView)
    }
}

