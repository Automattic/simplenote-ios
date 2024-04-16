//
//  SPContactsManager.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 12/23/16.
//  Copyright © 2016 Automattic. All rights reserved.
//

import Foundation
import Contacts

/// Contacts Helper
///
class SPContactsManager: NSObject {

    /// Checks if we've got permission to access the Contacts Store, or not
    ///
    @objc var authorized: Bool {
        return status == .authorized
    }

    /// All of the contacts!
    ///
    fileprivate var peopleCache: [PersonTag]?

    /// Contacts Store Reference
    ///
    fileprivate let store = CNContactStore()

    /// Returns the current Authorization Status
    ///
    fileprivate var status: CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }

    /// Deinitializer
    ///
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Designed Initializer
    ///
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(resetCache), name: .CNContactStoreDidChange, object: nil)
    }

    /// Whenever the Auth Status is undetermined, this helper will request access!
    ///
    @objc func requestAuthorizationIfNeeded(completion: ((Bool) -> Void)?) {
        guard status == .notDetermined else {
            return
        }

        store.requestAccess(for: .contacts) { (success, error) in
            completion?(success)
        }
    }

    /// Returns the subset of Persons that contain a specified keyword, in either their email or name
    ///
    @objc func people(with keyword: String) -> [PersonTag] {
        guard let people = loadPeopleIfNeeded() else {
            return []
        }

        let normalizedKeyword = keyword.lowercased()
        return people.filter { person in
            return person.email.lowercased().contains(normalizedKeyword) ||
                person.name.lowercased().contains(normalizedKeyword)
        }
    }
}

/// Contacts Helper
///
private extension SPContactsManager {

    /// Returns a collection of all of the PersonTag's.
    ///
    func loadPeopleIfNeeded() -> [PersonTag]? {
        guard authorized else {
            return nil
        }

        guard peopleCache == nil else {
            return peopleCache
        }

        peopleCache = loadPeople(with: loadContacts())

        return peopleCache
    }

    /// Given a collection of Contacts, this helper will return a collection of PersonTag matching instances
    ///
    private func loadPeople(with contacts: [CNContact]) -> [PersonTag] {
        var persons = [PersonTag]()

        for contact in contacts {
            let fullname = CNContactFormatter.string(from: contact, style: .fullName) ?? String()

            for email in contact.emailAddresses {
                guard let person = PersonTag(name: fullname as String, email: email.value as String) else {
                    continue
                }

                persons.append(person)
            }
        }

        return persons
    }

    /// Returns a collection of all of the contacts: Only Fullname + Email will be loaded
    ///
    private func loadContacts() -> [CNContact] {
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey as CNKeyDescriptor
        ]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        var contacts = [CNContact]()

        do {
            try store.enumerateContacts(with: request) { (contact, _) in
                contacts.append(contact)
            }
        } catch {
            NSLog("## Error while loading contacts: \(error)")
        }

        return contacts
    }

    /// Nukes the People Cache. Useful to deal with "Contacts Updated" Notifications
    ///
    @objc func resetCache() {
        peopleCache = nil
    }
}
