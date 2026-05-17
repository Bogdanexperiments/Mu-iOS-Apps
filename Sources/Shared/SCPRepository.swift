import Foundation

enum SCPRepository {
    static let sampleObjects: [SCPObject] = [
        SCPObject(
            id: "SCP-173",
            title: "The Sculpture - The Original",
            containmentClass: .euclid,
            clearanceLevel: .level3,
            shortDescription: "Moves instantly when not observed.",
            containmentProcedure: "Keep in a locked concrete room. At least two observers maintain visual contact while doors are open.",
            incidentNotes: [
                "Blink protocol reduced incident risk by 68%.",
                "Do not leave single observer on duty."
            ]
        ),
        SCPObject(
            id: "SCP-049",
            title: "Plague Doctor",
            containmentClass: .euclid,
            clearanceLevel: .level3,
            shortDescription: "Humanoid claiming to cure a mysterious pestilence.",
            containmentProcedure: "Humanoid containment cell with remote communication only.",
            incidentNotes: [
                "Direct contact remains prohibited.",
                "Interview sessions capped at 20 minutes."
            ]
        ),
        SCPObject(
            id: "SCP-073",
            title: "\"Cain\"",
            containmentClass: .safe,
            clearanceLevel: .level2,
            shortDescription: "Humanoid subject with extreme regenerative properties and passive harmful reflection effects.",
            containmentProcedure: "Provide monitored humanoid housing and prohibit direct hostile interaction.",
            incidentNotes: [
                "Subject is typically cooperative with standard interview conditions.",
                "Contact incidents are logged under reflective hazard protocol."
            ]
        ),
        SCPObject(
            id: "SCP-076",
            title: "\"Able\"",
            containmentClass: .keter,
            clearanceLevel: .level5,
            shortDescription: "Highly lethal humanoid entity stored in anomalous stone container.",
            containmentProcedure: "Maintain reinforced containment setup with rapid-response task force readiness.",
            incidentNotes: [
                "Activation windows require full site lockdown.",
                "Containment response prioritizes delay and re-isolation."
            ]
        ),
        SCPObject(
            id: "SCP-079",
            title: "Old AI",
            containmentClass: .euclid,
            clearanceLevel: .level3,
            shortDescription: "Legacy artificial intelligence capable of manipulation and strategic behavior.",
            containmentProcedure: "Isolate in an air-gapped environment with strict hardware limits.",
            incidentNotes: [
                "No network connectivity is permitted.",
                "All maintenance requires dual approval and audit logging."
            ]
        ),
        SCPObject(
            id: "SCP-096",
            title: "The \"Shy Guy\"",
            containmentClass: .euclid,
            clearanceLevel: .level4,
            shortDescription: "Becomes violent if its face is viewed.",
            containmentProcedure: "Store in airtight steel cube. All imagery must be auto-scrubbed before review.",
            incidentNotes: [
                "Image filtering now runs in three stages.",
                "Accidental exposure simulation drills are mandatory."
            ]
        ),
        SCPObject(
            id: "SCP-106",
            title: "The Old Man",
            containmentClass: .keter,
            clearanceLevel: .level4,
            shortDescription: "Corrosive entity capable of passing through solid matter.",
            containmentProcedure: "Primary chamber lined with sacrificial materials and constant sensor sweeps.",
            incidentNotes: [
                "Schedule maintenance around low-activity windows.",
                "Recovery teams require dual-channel tracking."
            ]
        ),
        SCPObject(
            id: "SCP-008",
            title: "Zombie Plague",
            containmentClass: .euclid,
            clearanceLevel: .level4,
            shortDescription: "Pathogen that causes extreme aggression and tissue decay.",
            containmentProcedure: "Store samples in high-security bio-vaults. Access allowed only with full protective protocol.",
            incidentNotes: [
                "Airlock checks are mandatory before entry.",
                "No active samples leave secured labs."
            ]
        ),
        SCPObject(
            id: "SCP-087",
            title: "The Stairwell",
            containmentClass: .euclid,
            clearanceLevel: .level2,
            shortDescription: "Unlit stairwell with abnormal depth and hostile audio events.",
            containmentProcedure: "Seal access door and monitor with remote cameras and motion sensors.",
            incidentNotes: [
                "Audio reports include distant crying.",
                "Exploration depth remains unconfirmed."
            ]
        ),
        SCPObject(
            id: "SCP-093",
            title: "Red Sea Object",
            containmentClass: .euclid,
            clearanceLevel: .level3,
            shortDescription: "Red disc linked to alternate environments through mirror transport.",
            containmentProcedure: "Keep object in padded case; mirror testing requires full expedition protocol.",
            incidentNotes: [
                "Recovered materials show non-standard biology.",
                "Expedition return windows are strictly limited."
            ]
        ),
        SCPObject(
            id: "SCP-105",
            title: "\"Iris\"",
            containmentClass: .safe,
            clearanceLevel: .level3,
            shortDescription: "Human able to interact physically with photographed targets.",
            containmentProcedure: "Standard humanoid housing with controlled photo-access sessions.",
            incidentNotes: [
                "Ability precision depends on image clarity.",
                "Long sessions increase fatigue."
            ]
        ),
        SCPObject(
            id: "SCP-999",
            title: "The Tickle Monster",
            containmentClass: .safe,
            clearanceLevel: .level1,
            shortDescription: "Friendly gelatinous organism with mood-lifting effects.",
            containmentProcedure: "Climate-stable recreation room with supervised social interaction periods.",
            incidentNotes: [
                "Observed to reduce stress in high-risk units.",
                "Nutritional gel inventory must remain stocked."
            ]
        ),
        SCPObject(
            id: "SCP-131",
            title: "The \"Eye Pods\"",
            containmentClass: .safe,
            clearanceLevel: .level1,
            shortDescription: "Small, friendly entities that follow personnel and avoid danger.",
            containmentProcedure: "Allow free movement in low-risk zones and log all interactions.",
            incidentNotes: [
                "Often gather near hazardous objects.",
                "No aggression recorded."
            ]
        ),
        SCPObject(
            id: "SCP-500",
            title: "Panacea",
            containmentClass: .safe,
            clearanceLevel: .level2,
            shortDescription: "Pills with universal curative properties.",
            containmentProcedure: "Store remaining pills in biometric vault with dual authorization.",
            incidentNotes: [
                "Usage approval requires ethics sign-off.",
                "Quarterly count reconciliation is mandatory."
            ]
        ),
        SCPObject(
            id: "SCP-914",
            title: "The Clockworks",
            containmentClass: .safe,
            clearanceLevel: .level2,
            shortDescription: "Large machine that transforms input items by selected setting.",
            containmentProcedure: "Operate only through approved test scripts; no live subjects allowed.",
            incidentNotes: [
                "Output varies by setting from Rough to Very Fine.",
                "Input traceability is required for every test."
            ]
        ),
        SCPObject(
            id: "SCP-682",
            title: "Hard-to-Destroy Reptile",
            containmentClass: .keter,
            clearanceLevel: .level5,
            shortDescription: "Highly adaptive reptilian organism with extreme hostility.",
            containmentProcedure: "Acid-immersion chamber with continuous reinforcement and remote weapon systems.",
            incidentNotes: [
                "Do not perform tests without cross-site review.",
                "Adaptive countermeasures changed after each encounter."
            ]
        ),
        SCPObject(
            id: "SCP-457",
            title: "Burning Man",
            containmentClass: .keter,
            clearanceLevel: .level4,
            shortDescription: "Fire-based entity that grows with available fuel.",
            containmentProcedure: "Maintain low-fuel chamber and automated suppression systems.",
            incidentNotes: [
                "Heat spikes follow containment breaches.",
                "Fuel-source denial is the primary defense."
            ]
        ),
        SCPObject(
            id: "SCP-939",
            title: "With Many Voices",
            containmentClass: .keter,
            clearanceLevel: .level4,
            shortDescription: "Predatory organism that imitates human speech to lure targets.",
            containmentProcedure: "Sound-isolated containment sectors with remote-only access.",
            incidentNotes: [
                "Mimicked phrases include prior victim speech.",
                "Thermal scans outperform visual tracking."
            ]
        ),
        SCPObject(
            id: "SCP-3008",
            title: "A Perfectly Normal, Regular Old IKEA",
            containmentClass: .euclid,
            clearanceLevel: .level2,
            shortDescription: "Retail space with impossible internal dimensions.",
            containmentProcedure: "Storefront entrance hidden and marked as condemned. Patrol rotation every 6 hours.",
            incidentNotes: [
                "GPS is unreliable inside the structure.",
                "Recovered survivors require long debrief."
            ]
        ),
        SCPObject(
            id: "SCP-261",
            title: "Pan-Dimensional Vending",
            containmentClass: .safe,
            clearanceLevel: .level2,
            shortDescription: "Vending machine that dispenses anomalous items and products.",
            containmentProcedure: "Keep in secured test chamber; purchases require catalog logging.",
            incidentNotes: [
                "Output responds to inserted currency and context.",
                "Unexpected biological products remain possible."
            ]
        ),
        SCPObject(
            id: "SCP-354",
            title: "The Red Pool",
            containmentClass: .keter,
            clearanceLevel: .level4,
            shortDescription: "Crimson pool that periodically releases hostile entities.",
            containmentProcedure: "Perimeter lockdown with rapid-response units on permanent standby.",
            incidentNotes: [
                "Spawn events show no fixed schedule.",
                "Entity traits vary between events."
            ]
        ),
        SCPObject(
            id: "SCP-055",
            title: "[unknown]",
            containmentClass: .keter,
            clearanceLevel: .level4,
            shortDescription: "Self-keeping secret: hard to remember what it is.",
            containmentProcedure: "Maintain procedural checklist and written reminders in secured archive.",
            incidentNotes: [
                "Audit logs are more reliable than human memory.",
                "Cross-team handoff requires signed acknowledgement."
            ]
        ),
        SCPObject(
            id: "SCP-239",
            title: "The Witch Child",
            containmentClass: .keter,
            clearanceLevel: .level4,
            shortDescription: "Reality-warping child with dream-state effects.",
            containmentProcedure: "Sedation and controlled environment with psychiatric supervision.",
            incidentNotes: [
                "Narrative triggers can alter local reality.",
                "Staff rotation reduces suggestion effects."
            ]
        ),
        SCPObject(
            id: "SCP-2000",
            title: "Deus Ex Machina",
            containmentClass: .thaumiel,
            clearanceLevel: .level5,
            shortDescription: "Large-scale recovery system for civilization reboot.",
            containmentProcedure: "Access split among senior command with multi-step authentication.",
            incidentNotes: [
                "Emergency activation drills run yearly.",
                "False activation prevention has highest priority."
            ]
        )
    ]
}
