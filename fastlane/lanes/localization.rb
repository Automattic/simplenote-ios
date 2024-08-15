# frozen_string_literal: true

# List of locales used for the app strings (GlotPress code => `*.lproj` folder name`)
#
# TODO: Replace with `LocaleHelper` once provided by release toolkit (https://github.com/wordpress-mobile/release-toolkit/pull/296)
GLOTPRESS_TO_LPROJ_APP_LOCALE_CODES = {
  'ar' => 'ar',             # Arabic
  'cy' => 'cy',             # Welsh
  'de' => 'de',             # German
  'el' => 'el',             # Greek
  'en' => 'en',             # English
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
    UI.important('TODO: Not yet implemented!')
  end
end
