# DerivedSources

The `SPCredentials.swift` entries here, one per target that compiles it, are shown in red in Xcode and `Open Quickly` cannot find them.
The same goes for `ScreenshotsCredentials.swift` in the `SimplenoteScreenshots` group.
That is expected: they do not exist in the repository.

The `Copy Secret` build phase writes each into its own target's `$(DERIVED_FILE_DIR)`, from the decrypted credentials under `~/.configure/simplenote-ios/secrets/`, or, missing those, from the matching `*.external-contributors.swift` file.
Missing both fails the build.
See `Scripts/Build-Phases/copy-secret.sh`.

Do not delete the red references. The app will not compile without them!
