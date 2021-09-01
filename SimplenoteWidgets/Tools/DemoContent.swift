import Foundation

struct DemoContent {
    static let singleNoteTitle = "Lorem ipsum dolor sit amet"
    static let singleNoteContent = ", consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nulla facilisi nullam vehicula ipsum a arcu cursus. Cursus risus at ultrices mi tempus imperdiet nulla malesuada. Vitae aliquet nec ullamcorper sit amet risus nullam eget felis. Ultrices sagittis orci a scelerisque. Et ligula ullamcorper malesuada proin libero nunc. Ut diam quam nulla porttitor massa. Quam nulla porttitor massa id neque aliquam. Urna cursus eget nunc scelerisque viverra mauris in aliquam. Turpis nunc eget lorem dolor. Ac turpis egestas maecenas pharetra convallis posuere. Gravida in fermentum et sollicitudin ac. Tempor orci eu lobortis elementum nibh tellus molestie. Nec tincidunt praesent semper feugiat nibh sed pulvinar proin. Interdum velit laoreet id donec ultrices tincidunt. Aliquam vestibulum morbi blandit cursus risus at ultrices mi. Aliquet lectus proin nibh nisl condimentum id venenatis. Consequat ac felis donec et odio pellentesque. Lobortis elementum nibh tellus molestie. Sed velit dignissim sodales ut eu sem integer vitae justo.”"
    static let singleNoteContentAlt = "- [] Check item one \n- [] check item two\n- [] check item three"
    static let singleNoteURL = URL(string: .simplenotePath())!

    static let demoURL = URL(string: .simplenotePath())!

    static let listTag = "Cursus"
    static let listTitles = [
        "Urna cursus eget nunc scelerisque",
        "Lorem Ipsum",
        "Interdum velit laoreet id donec ultrices",
        "Nec tincidunt praesent semper",
        "porttitor massa id neque aliquam",
        "Gravida in fermentum et sollicitudin ac",
        "Lobortis elementum nibh tellus molestie.",
        "Lorem Ipsum"
    ]
    static let listProxies: [ListWidgetNoteProxy] = listTitles.map { (title) in
        ListWidgetNoteProxy(title: title, url: demoURL)
    }
}
