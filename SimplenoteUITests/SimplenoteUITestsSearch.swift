import XCTest

let godzillaNoteName = "Godzilla"
let godzillaInfo = "Godzilla (Japanese: ゴジラ, Hepburn: Gojira, /ɡɒdˈzɪlə/; [ɡoꜜdʑiɾa] (About this soundlisten)) is a fictional monster, or kaiju, originating from a series of Japanese films. The character first appeared in the 1954 film Godzilla and became a worldwide pop culture icon, appearing in various media, including 32 films produced by Toho, four Hollywood films and numerous video games, novels, comic books and television shows. Godzilla has been dubbed the'King of the Monsters', a phrase first used in Godzilla, King of the Monsters! (1956), the Americanized version of the original film."

let kingKongNoteName = "King Kong"
let kingKongInfo = "King Kong is a film monster, resembling an enormous gorilla, that has appeared in various media since 1933. He has been dubbed The Eighth Wonder of the World, a phrase commonly used within the films. The character first appeared in the novelization of the 1933 film King Kong from RKO Pictures, with the film premiering a little over two months later. The film received universal acclaim upon its initial release and re-releases. A sequel quickly followed that same year with The Son of Kong, featuring Little Kong. In the 1960s, Toho produced King Kong vs. Godzilla (1962), pitting a larger Kong against Toho's own Godzilla, and King Kong Escapes (1967), based on The King Kong Show (1966–1969) from Rankin/Bass Productions. In 1976, Dino De Laurentiis produced a modern remake of the original film directed by John Guillermin."

let mechagodzillaNoteName = "Mechagodzilla"
let mechagodzillaInfo = "Mechagodzilla (メカゴジラ, Mekagojira) is a fictional mecha character that first appeared in the 1974 film Godzilla vs. Mechagodzilla. In its debut appearance, Mechagodzilla is depicted as an extraterrestrial villain that confronts Godzilla. In subsequent iterations, Mechagodzilla is usually depicted as a man-made weapon designed to defend Japan from Godzilla. In all incarnations, the character is portrayed as a robotic doppelgänger with a vast array of weaponry, and along with King Ghidorah, is commonly considered to be an archenemy of Godzilla."

let diacriticNoteName = "Diacritic"
let diacriticInfo = "A diacritic (also diacritical mark, diacritical point, diacritical sign, or accent) is a glyph added to a letter or basic glyph. The term derives from the Ancient Greek διακριτικός (diakritikós, \"distinguishing\"), from διακρίνω (diakrī́nō, \"to distinguish\"). Some diacritical marks, such as the acute ( ´ ) and grave ( ` ), are often called accents. Examples are the diaereses in the borrowed French words naïve and Noël, which show that the vowel with the diaeresis mark is pronounced separately from the preceding vowel; the acute and grave accents, which can indicate that a final vowel is to be pronounced, as in saké and poetic breathèd; and the cedilla under the \"c\" in the borrowed French word façade, which shows it is pronounced /s/ rather than /k/. In other Latin-script alphabets, they may distinguish between homonyms, such as the French là (\"there\") versus la (\"the\") that are both pronounced /la/. In Gaelic type, a dot over a consonant indicates lenition of the consonant in question."

class SimplenoteUISmokeTestsSearch: XCTestCase {

    override class func setUp() {
        app.launch()
        let _ = attemptLogOut()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        NoteList.waitForLoad()
        NoteList.trashAllNotes()
        Trash.empty()
        Sidebar.open()
        Sidebar.tagsDeleteAll()
        NoteList.openAllNotes()
        NoteList.createNoteAndLeaveEditor(noteName: godzillaNoteName + "\n\n" + godzillaInfo, tags: ["sea-monster", "reptile", "prehistoric"])
        NoteList.createNoteAndLeaveEditor(noteName: kingKongNoteName + "\n\n" + kingKongInfo, tags: ["ape", "prehistoric"])
        NoteList.createNoteAndLeaveEditor(noteName: mechagodzillaNoteName + "\n\n" + mechagodzillaInfo, tags: ["man-made", "robot"])
        NoteList.createNoteAndLeaveEditor(noteName: diacriticNoteName + "\n\n" + diacriticInfo, tags: ["language", "diacritic"])
}

    override func setUpWithError() throws {
        NoteList.searchForText(text: "")
        NoteList.searchCancel()
    }

    func testClearingSearchFieldUpdatesFilteredNotes() throws {
        trackTest()

        trackStep()
        NoteList.openAllNotes()
        NoteListAssert.notesExist(names: [godzillaNoteName, kingKongNoteName, mechagodzillaNoteName, diacriticNoteName])
        NoteListAssert.notesNumber(expectedNotesNumber: 4)

        trackStep()
        NoteList.searchForText(text: "Japan")
        NoteListAssert.notesExist(names: [godzillaNoteName, mechagodzillaNoteName])

        trackStep()
        NoteList.searchCancel()
        NoteListAssert.notesExist(names: [godzillaNoteName, kingKongNoteName, mechagodzillaNoteName, diacriticNoteName])
        NoteListAssert.notesNumber(expectedNotesNumber: 4)

        trackStep()
        NoteList.searchForText(text: "weapon")
        NoteListAssert.noteExists(noteName: mechagodzillaNoteName)
        NoteListAssert.notesNumber(expectedNotesNumber: 1)

        trackStep()
        NoteList.searchForText(text: "")
        NoteListAssert.notesExist(names: [godzillaNoteName, kingKongNoteName, mechagodzillaNoteName, diacriticNoteName])
        NoteListAssert.notesNumber(expectedNotesNumber: 4)
    }

    func testCanFilterByTagWhenClickingOnTagInTagDrawer() throws {
        trackTest()
        var testedTag = String()

        trackStep()
        testedTag = "prehistoric"
        Sidebar.tagSelect(tagName: testedTag)
        NoteListAssert.noteListShown(forSelection: testedTag)
        NoteListAssert.notesExist(names: [godzillaNoteName, kingKongNoteName])
        NoteListAssert.notesNumber(expectedNotesNumber: 2)

        trackStep()
        testedTag = "reptile"
        Sidebar.tagSelect(tagName: testedTag)
        NoteListAssert.noteListShown(forSelection: testedTag)
        NoteListAssert.noteExists(noteName: godzillaNoteName)
        NoteListAssert.notesNumber(expectedNotesNumber: 1)

        trackStep()
        testedTag = "robot"
        Sidebar.tagSelect(tagName: testedTag)
        NoteListAssert.noteListShown(forSelection: testedTag)
        NoteListAssert.noteExists(noteName: mechagodzillaNoteName)
        NoteListAssert.notesNumber(expectedNotesNumber: 1)
    }

    func testClickingOnDifferentTagsOrAllNotesOrTrashImmediatelyUpdatesFilteredNotes() throws {
        trackTest()
        var testedTag = String()

        trackStep()
        testedTag = "prehistoric"
        Sidebar.tagSelect(tagName: testedTag)
        NoteListAssert.noteListShown(forSelection: testedTag)
        NoteListAssert.notesExist(names: [godzillaNoteName, kingKongNoteName])
        NoteListAssert.notesNumber(expectedNotesNumber: 2)

        trackStep()
        NoteList.openAllNotes()
        NoteListAssert.allNotesShown()
        NoteListAssert.notesExist(names: [godzillaNoteName, kingKongNoteName, mechagodzillaNoteName, diacriticNoteName])
        NoteListAssert.notesNumber(expectedNotesNumber: 4)

        trackStep()
        Trash.open()
        NoteListAssert.trashShown()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        trackStep()
        testedTag = "language"
        Sidebar.tagSelect(tagName: testedTag)
        NoteListAssert.noteListShown(forSelection: testedTag)
        NoteListAssert.noteExists(noteName: diacriticNoteName)
        NoteListAssert.notesNumber(expectedNotesNumber: 1)
    }

    func testCanSearchByKeyword() throws {
        trackTest()

        trackStep()
        NoteList.openAllNotes()
        NoteListAssert.notesExist(names: [godzillaNoteName, kingKongNoteName, mechagodzillaNoteName, diacriticNoteName])
        NoteListAssert.notesNumber(expectedNotesNumber: 4)

        trackStep()
        NoteList.searchForText(text: "Godzilla")
        NoteListAssert.notesExist(names: [godzillaNoteName, kingKongNoteName, mechagodzillaNoteName])
        NoteListAssert.notesNumber(expectedNotesNumber: 3)

        trackStep()
        NoteList.searchForText(text: "Gorilla")
        NoteListAssert.notesExist(names: [kingKongNoteName])
        NoteListAssert.notesNumber(expectedNotesNumber: 1)

        trackStep()
        NoteList.searchForText(text: "Gaelic")
        NoteListAssert.notesExist(names: [diacriticNoteName])
        NoteListAssert.notesNumber(expectedNotesNumber: 1)
    }

    func testTagSuggestionsSuggestTagsRegardlessOfCase() throws {
        trackTest()

        trackStep()
        NoteList.searchForText(text: "robot")
        NoteListAssert.tagsSearchHeaderShown()
        NoteListAssert.tagSuggestionExists(tag: "tag:robot")
        NoteListAssert.tagsSuggestionsNumber(number: 1)
        NoteListAssert.notesSearchHeaderShown()
        NoteListAssert.noteExists(noteName: mechagodzillaNoteName)
        NoteListAssert.notesNumber(expectedNotesNumber: 1)

        trackStep()
        NoteList.searchForText(text: "ROBOT")
        NoteListAssert.tagsSearchHeaderShown()
        NoteListAssert.tagSuggestionExists(tag: "tag:robot")
        NoteListAssert.tagsSuggestionsNumber(number: 1)
        NoteListAssert.notesSearchHeaderShown()
        NoteListAssert.noteExists(noteName: mechagodzillaNoteName)
        NoteListAssert.notesNumber(expectedNotesNumber: 1)

        trackStep()
        NoteList.searchForText(text: "PrEhIsToRiC")
        NoteListAssert.tagsSearchHeaderShown()
        NoteListAssert.tagSuggestionExists(tag: "tag:prehistoric")
        NoteListAssert.tagsSuggestionsNumber(number: 1)
        NoteListAssert.notesSearchHeaderNotShown()
        NoteListAssert.notesNumber(expectedNotesNumber: 0)
    }

    func testTagAutoCompletesAppearWhenTypingInSearchField() throws {
        trackTest()

        trackStep()
        NoteList.searchForText(text: "t")
        NoteListAssert.tagsSearchHeaderShown()
        NoteListAssert.tagSuggestionsExist(tags: ["tag:diacritic", "tag:prehistoric", "tag:reptile", "tag:robot", "tag:sea-monster"])
        NoteListAssert.tagsSuggestionsNumber(number: 5)
        NoteListAssert.notesSearchHeaderShown()

        trackStep()
        NoteList.searchForText(text: "a")
        NoteListAssert.tagsSearchHeaderShown()
        NoteListAssert.tagSuggestionsExist(tags: ["tag:ape", "tag:diacritic", "tag:language", "tag:man-made", "tag:sea-monster"])
        NoteListAssert.tagsSuggestionsNumber(number: 5)
        NoteListAssert.notesSearchHeaderShown()

        trackStep()
        NoteList.searchForText(text: "ic")
        NoteListAssert.tagsSearchHeaderShown()
        NoteListAssert.tagSuggestionsExist(tags: ["tag:diacritic", "tag:prehistoric"])
        NoteListAssert.tagsSuggestionsNumber(number: 2)
        NoteListAssert.notesSearchHeaderShown()

        trackStep()
        NoteList.searchForText(text: "abc")
        NoteListAssert.tagsSearchHeaderNotShown()
        NoteListAssert.notesSearchHeaderNotShown()
        NoteListAssert.notesNumber(expectedNotesNumber: 0)
    }

    func testTypingTagAndSomethingElseResultsInAutocompleteTagResultsIncludingThatSomethingElse() throws {
        trackTest()

        trackStep()
        NoteList.searchForText(text: "tag:re")
        NoteListAssert.tagsSearchHeaderShown()
        NoteListAssert.tagSuggestionsExist(tags: ["tag:prehistoric", "tag:reptile"])
        NoteListAssert.tagsSuggestionsNumber(number: 2)
        NoteListAssert.notesSearchHeaderNotShown()
        NoteListAssert.notesNumber(expectedNotesNumber: 0)

        trackStep()
        NoteList.searchForText(text: "tag:-")
        NoteListAssert.tagsSearchHeaderShown()
        NoteListAssert.tagSuggestionsExist(tags: ["tag:man-made", "tag:sea-monster"])
        NoteListAssert.tagsSuggestionsNumber(number: 2)
        NoteListAssert.notesSearchHeaderNotShown()
        NoteListAssert.notesNumber(expectedNotesNumber: 0)
    }

    func testSearchFieldUpdatesWithResultsOfTagFormatSearchString() throws {
        trackTest()
        let testedTag = "tag:prehistoric"

        trackStep()
        NoteList.searchForText(text: "pre")
        NoteListAssert.tagsSearchHeaderShown()
        NoteListAssert.tagSuggestionExists(tag: testedTag)

        trackStep()
        NoteList.tagSuggestionTap(tag: testedTag)
        NoteListAssert.searchStringIsShown(searchString: testedTag + " ")
        NoteListAssert.notesSearchHeaderShown()
        NoteListAssert.notesExist(names: [godzillaNoteName, kingKongNoteName])
        NoteListAssert.notesNumber(expectedNotesNumber: 2)
    }

    func testCanSeeExcerpts() throws {
        trackTest()

        trackStep()
        NoteList.openAllNotes()
        NoteListAssert.notesExist(names: [godzillaNoteName, kingKongNoteName, mechagodzillaNoteName, diacriticNoteName])
        NoteListAssert.notesNumber(expectedNotesNumber: 4)

        trackStep()
        NoteList.searchForText(text: "Hepburn")
        NoteListAssert.noteContentIsShownInSearch(noteName: godzillaNoteName, expectedContent: "Godzilla (Japanese: ゴジラ, Hepburn: Gojira, /ɡɒdˈzɪlə/; [ɡoꜜdʑiɾa] (About this soundlisten)) is a fictional monster, or kaiju, originating from a series of Japanese films. The character first appeared in the 1954 film Godzilla and became a worldwide pop culture icon, appearing in various media, including 32 films produced by Toho")

        trackStep()
        NoteList.searchForText(text: "1962")
        NoteListAssert.noteContentIsShownInSearch(noteName: kingKongNoteName, expectedContent: "…King Kong vs. Godzilla (1962), pitting a larger Kong against Toho's own Godzilla, and King Kong Escapes (1967), based on The King Kong Show (1966–1969) from Rankin/Bass Productions. In 1976, Dino De Laurentiis produced a modern remake of the original film directed by John Guillermin")

        trackStep()
        NoteList.searchForText(text: "archenemy")
        NoteListAssert.noteContentIsShownInSearch(noteName: mechagodzillaNoteName, expectedContent: "…commonly considered to be an archenemy of Godzilla")
    }
}
