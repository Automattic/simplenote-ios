import Foundation

struct DemoContent {
    static let singleNoteTitle = "Twelve Tone Serialism"
    static let singleNoteContent = "The twelve-tone technique is often closely related with the compositional style, serialism. Fundamentally, twelve-tone serialism is a compositional technique where all 12 notes of the chromatic scale are played with equal frequency throughout the piece without any emphasis on any one note. For this reason, twelve-tone serialism avoids being in any key. Arnold Schoenberg was arguably the most influential composers who embraced the twelve-tone technique. Schoenberg described the system as a “Method of composing with twelve tones which are related only with one another.”"
    static let singleNoteContentAlt = "- [] Check item one \n- [] check item two\n- [] check item three"
    static let singleNoteURL = URL(string: SimplenoteConstants.simplenoteScheme + "://")!

    static let demoURL = URL(string: SimplenoteConstants.simplenoteScheme + "://")!

    static let listTag = "Composition"
    static let listTitles = [
        "Twelve Tone Serialism",
        "Lorem Ipsum",
        "Post Draft",
        "Meeting Notes, Apr 21",
        "Brain Anatomy",
        "Color Quotes",
        "The Valet's Tragedy",
        "Lorem Ipsum"
    ]
    static let listProxies: [ListWidgetNoteProxy] = listTitles.map { (title) in
        ListWidgetNoteProxy(title: title, url: demoURL)
    }
}
