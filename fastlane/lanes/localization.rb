# frozen_string_literal: true

# List of locales used for the app strings (GlotPress code => `*.lproj` folder name`)
#
# TODO: Replace with `LocaleHelper` once provided by release toolkit (https://github.com/wordpress-mobile/release-toolkit/pull/296)
GLOTPRESS_TO_LPROJ_APP_LOCALE_CODES = {
  'ar' => 'ar',             # Arabic
  'cy' => 'cy',             # Welsh
  'de' => 'de',             # German
  'el' => 'el',             # Greek
  'es' => 'es',             # Spanish
  'fa' => 'fa',             # Persian
  'fr' => 'fr',             # French
  'he' => 'he',             # Hebrew
  'id' => 'id',             # Indonesian
  'it' => 'it',             # Italian
  'ja' => 'ja',             # Japanese
  'ko' => 'ko',             # Korean
  'nl' => 'nl',             # Dutch
  'pt-br' => 'pt-BR',       # Portuguese (Brazil)
  'ru' => 'ru',             # Russian
  'sv' => 'sv',             # Swedish
  'tr' => 'tr',             # Turkish
  'zh-cn' => 'zh-Hans-CN',  # Chinese (China)
  'zh-tw' => 'zh-Hant-TW'   # Chinese (Taiwan)
}.freeze

# Mapping of all locales which can be used for AppStore metadata (Glotpress code => AppStore Connect code)
#
# TODO: Replace with `LocaleHelper` once provided by release toolkit (https://github.com/wordpress-mobile/release-toolkit/pull/296)
GLOTPRESS_TO_ASC_METADATA_LOCALE_CODES = {
  'ar' => 'ar-SA',
  'de' => 'de-DE',
  'es' => 'es-ES',
  'fr' => 'fr-FR',
  'he' => 'he',
  'id' => 'id',
  'it' => 'it',
  'ja' => 'ja',
  'ko' => 'ko',
  'nl' => 'nl-NL',
  'pt-br' => 'pt-BR',
  'ru' => 'ru',
  'sv' => 'sv',
  'tr' => 'tr',
  'zh-cn' => 'zh-Hans',
  'zh-tw' => 'zh-Hant'
}.freeze

platform :ios do
  desc 'Updates the main `Localizable.strings` file — that will be imported by GlotPress'
  lane :generate_strings_file_for_glotpress do
    en_lproj_path = File.join(PROJECT_ROOT_FOLDER, 'Simplenote', 'en.lproj')
    ios_generate_strings_file_from_code(
      paths: [
        'Simplenote/',
        'SimplenoteIntents/',
        'SimplenoteShare/',
        'SimplenoteWidgets/',
        'Pods/Simperium/Simperium/',
        'Pods/Simperium/Simperium-iOS'
      ],
      output_dir: en_lproj_path
    )

    git_commit(
      path: en_lproj_path,
      message: 'Freeze strings for localization',
      allow_nothing_to_commit: true
    )
  end

  lane :download_localized_strings_and_metadata_from_glotpress do
    download_localized_strings_from_glotpress
    download_localized_metadata_from_glotpress
  end

  lane :download_localized_strings_from_glotpress do
    parent_dir_for_lprojs = File.join(PROJECT_ROOT_FOLDER, 'Simplenote')
    ios_download_strings_files_from_glotpress(
      project_url: GLOTPRESS_APP_STRINGS_PROJECT_URL,
      locales: GLOTPRESS_TO_LPROJ_APP_LOCALE_CODES,
      download_dir: parent_dir_for_lprojs
    )
    git_commit(
      path: File.join(parent_dir_for_lprojs, '*.lproj', 'Localizable.strings'),
      message: 'Update app translations – `Localizable.strings`',
      allow_nothing_to_commit: true
    )
  end

  lane :download_localized_metadata_from_glotpress do
    # FIXME: Replace this with a call to the future replacement of `gp_downloadmetadata` once it's implemented in the release-toolkit (see paaHJt-31O-p2).
    target_files = {
      "v#{release_version_current}-whats-new": { desc: 'release_notes.txt', max_size: 4000 },
      app_store_name: { desc: 'name.txt', max_size: 30 },
      app_store_subtitle: { desc: 'subtitle.txt', max_size: 30 },
      app_store_desc: { desc: 'description.txt', max_size: 4000 },
      app_store_keywords: { desc: 'keywords.txt', max_size: 100 }
    }
    gp_downloadmetadata(
      project_url: GLOTPRESS_STORE_METADATA_PROJECT_URL,
      target_files: target_files,
      locales: GLOTPRESS_TO_ASC_METADATA_LOCALE_CODES,
      download_path: STORE_METADATA_FOLDER
    )

    files_to_commit = [File.join(STORE_METADATA_FOLDER, '**', '*.txt')]

    ensure_default_metadata_are_not_overridden(metadata_files_hash: target_files)

    files_to_commit.append(*generate_gitkeep_for_empty_locale_folders)

    git_add(path: files_to_commit, shell_escape: false)
    git_commit(
      path: files_to_commit,
      message: 'Update App Store metadata translations',
      allow_nothing_to_commit: true
    )

    sanitize_appstore_keywords
  end

  # TODO: This ought to be part of the localized metadata download action, or of Fastlane itself.
  desc 'Updates the files with the localized keywords values for App Store Connect to match the 100 characters requirement'
  lane :sanitize_appstore_keywords do
    Dir[File.join(STORE_METADATA_FOLDER, '**')].each do |locale_dir|
      keywords_path = File.join(locale_dir, 'keywords.txt')

      unless File.exist?(keywords_path)
        UI.important "Could not find keywords file in #{locale_dir}. Skipping..."
        next
      end

      keywords = File.read(keywords_path)
      app_store_connect_keywords_length_limit = 100

      if keywords.length <= app_store_connect_keywords_length_limit
        UI.success "#{keywords_path} has less than #{app_store_connect_keywords_length_limit} characters."
        next
      end

      UI.important "#{keywords_path} has more than #{app_store_connect_keywords_length_limit} characters. Trimming it..."

      english_comma = ','
      arabic_comma = '،'
      locale_code = File.basename(locale_dir)
      keywords = keywords.gsub(arabic_comma, english_comma) if locale_code == 'ar-SA'

      keywords = keywords.split(english_comma)[0...-1].join(english_comma) until keywords.length <= app_store_connect_keywords_length_limit

      File.write(keywords_path, keywords)

      git_commit(
        path: keywords_path,
        message: "Trim #{locale_code} keywords to be less than #{app_store_connect_keywords_length_limit} characters",
        allow_nothing_to_commit: false
      )
    end
  end

  lane :lint_localizations do
    ios_lint_localizations(input_dir: APP_RESOURCES_DIR, allow_retry: true)
  end

  lane :check_translation_progress_all do
    check_translation_progress_strings
    check_translation_progress_release_notes
  end

  lane :check_translation_progress_strings do
    UI.message('Checking app strings translation status...')
    check_translation_progress(
      glotpress_url: GLOTPRESS_APP_STRINGS_PROJECT_URL,
      abort_on_violations: false
    )
  end

  lane :check_translation_progress_release_notes do
    UI.message('Checking release notes strings translation status...')
    check_translation_progress(
      glotpress_url: GLOTPRESS_STORE_METADATA_PROJECT_URL,
      abort_on_violations: false
    )
  end
end

# Ensure that none of the `.txt` files in `en-US` would accidentally override our originals in `default`
def ensure_default_metadata_are_not_overridden(metadata_files_hash:)
  metadata_files_hash.values.map { |t| t[:desc] }.each do |file|
    en_file_path = File.join(STORE_METADATA_FOLDER, 'en-US', file)

    override_not_allowed_message = <<~MSG
      File `#{en_file_path}` would override the same one in `#{STORE_METADATA_FOLDER}/default`.
      `default/` is the source of truth and we cannot allow it to change unintentionally.
      Delete `#{en_file_path}`, ensure the version in `default/` has the expected original copy, and try again.
    MSG
    UI.user_error!(override_not_allowed_message) if File.exist?(en_file_path)
  end
end

# Ensure even empty locale folders have an empty `.gitkeep` file.
# This way, if we don't have any translation ready for those locales, we'll still have the folders in Git for clarity.
def generate_gitkeep_for_empty_locale_folders
  gitkeeps = []

  GLOTPRESS_TO_ASC_METADATA_LOCALE_CODES.each_value do |locale|
    gitkeep = File.join(STORE_METADATA_FOLDER, locale, '.gitkeep')
    next if File.exist?(gitkeep)

    FileUtils.mkdir_p(File.dirname(gitkeep))
    FileUtils.touch(gitkeep)
    gitkeeps.append(gitkeep)
  end

  gitkeeps
end
