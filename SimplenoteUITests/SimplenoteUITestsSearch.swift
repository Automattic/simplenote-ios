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
		AllNotes.waitForLoad()
		AllNotes.clearAllNotes()
		Trash.empty()
		Sidebar.open()
		Sidebar.tagsDeleteAll()
		AllNotes.open()

		AllNotes.createNoteAndLeaveEditor(noteName: godzillaNoteName + "\n\n" + godzillaInfo,
										  tagsOptional: ["sea-monster", "reptile", "prehistoric"])
		AllNotes.createNoteAndLeaveEditor(noteName: kingKongNoteName + "\n\n" + kingKongInfo,
										  tagsOptional: ["ape", "prehistoric"])
		AllNotes.createNoteAndLeaveEditor(noteName: mechagodzillaNoteName + "\n\n" + mechagodzillaInfo,
										  tagsOptional: ["man-made", "robot"])
		AllNotes.createNoteAndLeaveEditor(noteName: diacriticNoteName + "\n\n" + diacriticInfo,
										  tagsOptional: ["language", "diacritic"])
	}

	override func setUpWithError() throws {
		AllNotes.searchForText(text: "")
		AllNotes.searchCancel()
	}

	func testClearingSearchFieldUpdatesFilteredNotes() throws {
		trackTest()

		trackStep()
		AllNotes.open()
		AllNotesAssert.notesExist(names: [godzillaNoteName, kingKongNoteName, mechagodzillaNoteName, diacriticNoteName])
		AllNotesAssert.notesNumber(expectedNotesNumber: 4)

		trackStep()
		AllNotes.searchForText(text: "Japan")
		AllNotesAssert.notesExist(names: [godzillaNoteName, mechagodzillaNoteName])

		trackStep()
		AllNotes.searchCancel()
		AllNotesAssert.notesExist(names: [godzillaNoteName, kingKongNoteName, mechagodzillaNoteName, diacriticNoteName])
		AllNotesAssert.notesNumber(expectedNotesNumber: 4)

		trackStep()
		AllNotes.searchForText(text: "weapon")
		AllNotesAssert.noteExists(noteName: mechagodzillaNoteName)
		AllNotesAssert.notesNumber(expectedNotesNumber: 1)

		trackStep()
		AllNotes.searchForText(text: "")
		AllNotesAssert.notesExist(names: [godzillaNoteName, kingKongNoteName, mechagodzillaNoteName, diacriticNoteName])
		AllNotesAssert.notesNumber(expectedNotesNumber: 4)
	}

	func testTagsTapping() throws {
		trackTest()
		
		trackStep()
		Sidebar.tagSelect(tagName: "ape")
		AllNotesAssert.noteExists(noteName: kingKongNoteName)

		trackStep()
		Sidebar.tagSelect(tagName: "reptile")
		AllNotesAssert.noteExists(noteName: godzillaNoteName)

		trackStep()
		Sidebar.tagSelect(tagName: "robot")
		AllNotesAssert.noteExists(noteName: mechagodzillaNoteName)
	}

	func testCanSearchByKeyword() throws {
		trackTest()

		trackStep()
		AllNotes.open()
		AllNotesAssert.notesExist(names: [godzillaNoteName, kingKongNoteName, mechagodzillaNoteName, diacriticNoteName])
		AllNotesAssert.notesNumber(expectedNotesNumber: 4)

		trackStep()
		AllNotes.searchForText(text: "Godzilla")
		AllNotesAssert.notesExist(names: [godzillaNoteName, kingKongNoteName, mechagodzillaNoteName])
		AllNotesAssert.notesNumber(expectedNotesNumber: 3)

		trackStep()
		AllNotes.searchForText(text: "Gorilla")
		AllNotesAssert.notesExist(names: [kingKongNoteName])
		AllNotesAssert.notesNumber(expectedNotesNumber: 1)

		trackStep()
		AllNotes.searchForText(text: "Gaelic")
		AllNotesAssert.notesExist(names: [diacriticNoteName])
		AllNotesAssert.notesNumber(expectedNotesNumber: 1)
	}

	func testCanSeeExcerpts() throws {
		trackTest()

		trackStep()
		AllNotes.open()
		AllNotesAssert.notesExist(names: [godzillaNoteName, kingKongNoteName, mechagodzillaNoteName, diacriticNoteName])
		AllNotesAssert.notesNumber(expectedNotesNumber: 4)

		trackStep()
		AllNotes.searchForText(text: "Hepburn")
		AllNotesAssert.noteContentIsShownInSearch(noteName: godzillaNoteName, expectedContent: "Godzilla (Japanese: ゴジラ, Hepburn: Gojira, /ɡɒdˈzɪlə/; [ɡoꜜdʑiɾa] (About this soundlisten)) is a fictional monster, or kaiju, originating from a series of Japanese films. The character first appeared in the 1954 film Godzilla and became a worldwide pop culture icon, appearing in various media, including 32 films produced by Toho")

		trackStep()
		AllNotes.searchForText(text: "1962")
		AllNotesAssert.noteContentIsShownInSearch(noteName: kingKongNoteName, expectedContent: "…King Kong vs. Godzilla (1962), pitting a larger Kong against Toho's own Godzilla, and King Kong Escapes (1967), based on The King Kong Show (1966–1969) from Rankin/Bass Productions. In 1976, Dino De Laurentiis produced a modern remake of the original film directed by John Guillermin")

		trackStep()
		AllNotes.searchForText(text: "archenemy")
		AllNotesAssert.noteContentIsShownInSearch(noteName: mechagodzillaNoteName, expectedContent: "…commonly considered to be an archenemy of Godzilla")
	}
}
