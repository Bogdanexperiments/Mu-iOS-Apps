import Foundation

struct SCPIncidentDoc: Identifiable, Hashable {
    let id: String
    let title: String
    let relatedSCP: String
    let dateLabel: String
    let summary: String
    let sourceURLString: String

    var sourceURL: URL? {
        URL(string: sourceURLString)
    }
}

enum SCPIncidentRepository {
    static let docs: [SCPIncidentDoc] = [
        SCPIncidentDoc(
            id: "096-1-A",
            title: "Containment Breach and SCRAMBLE Failure",
            relatedSCP: "SCP-096",
            dateLabel: "Date redacted",
            summary: "Containment failed during lab operations, followed by a long pursuit operation. The SCRAMBLE headset concept failed because even a split-second facial view was enough to trigger SCP-096.",
            sourceURLString: "https://scp-wiki.wikidot.com/incident-096-1-a"
        ),
        SCPIncidentDoc(
            id: "AMN-C227-939",
            title: "Memory-Treatment Linked Missing Persons Spike",
            relatedSCP: "SCP-939",
            dateLabel: "1992-01-30",
            summary: "A major rise in missing-person cases was detected in civilians who had received AMN-C227. Use of the treatment was suspended and field investigation began the next day.",
            sourceURLString: "https://scp-wiki.wikidot.com/incident-report-amn-c227-939"
        ),
        SCPIncidentDoc(
            id: "682-1548",
            title: "Research Unit Breach and Unauthorized Transmission",
            relatedSCP: "SCP-682 + SCP-1548",
            dateLabel: "Date redacted",
            summary: "SCP-682 breached containment, reached a communications unit, and transmitted messages to SCP-1548. After the exchange, additional security casualties occurred before recontainment.",
            sourceURLString: "https://scp-wiki.wikidot.com/incident-682-1548"
        ),
        SCPIncidentDoc(
            id: "239-B",
            title: "Site-17 High-Damage Incident",
            relatedSCP: "SCP-239",
            dateLabel: "Date redacted",
            summary: "Post-incident assessment reported heavy infrastructure damage at Site-17 and severe security losses, followed by emergency relocation and staffing proposals.",
            sourceURLString: "https://scp-wiki.wikidot.com/incident-239-b-clef-kondraki"
        ),
        SCPIncidentDoc(
            id: "049.3",
            title: "Fatal Interview Event in Test Chamber",
            relatedSCP: "SCP-049",
            dateLabel: "2017-04-16",
            summary: "During a routine interview cycle, SCP-049 became hostile and killed Dr. Hamm. Due to delayed discovery, the victim was converted before response teams intervened.",
            sourceURLString: "https://scp-wiki.wikidot.com/scp-049"
        ),
        SCPIncidentDoc(
            id: "079-682",
            title: "Cross-Containment Event",
            relatedSCP: "SCP-079 + SCP-682",
            dateLabel: "Date redacted",
            summary: "Following a separate breach, SCP-079 and SCP-682 were held in the same chamber for 43 minutes. This event is recorded as a major containment concern.",
            sourceURLString: "https://scp-wiki.wikidot.com/scp-079"
        ),
        SCPIncidentDoc(
            id: "106-RP",
            title: "Repeated Breach Pattern and Recall Protocol",
            relatedSCP: "SCP-106",
            dateLabel: "Multiple events",
            summary: "The record describes repeated breach cycles and the use of Recall Protocol for recontainment. Procedure revisions were reported to reduce escape frequency.",
            sourceURLString: "https://scp-wiki.wikidot.com/scp-106"
        )
    ]
}
