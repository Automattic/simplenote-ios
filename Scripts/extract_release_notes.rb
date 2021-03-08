# Parses the release notes file to extract the current version information and
# puts it to STDOUT.
#
# To update the release notes for localization:
#
# ruby ./this_script >| Simplenote/Resources/release_notes.txt
#
# To generate the GitHub release copy:
#
# ruby ./this_script -k | pbcopy

RELEASE_NOTES_FILE = 'RELEASE-NOTES.txt'
NOTES = File.read(RELEASE_NOTES_FILE)
lines = NOTES.lines

# This is a very bare bone option parsing. It does the job for this simple use
# case, but it should not be built upon.
#
# If you plan to add more options, please consider using a gem to manage them
# properly.
mode = ARGV[0] == '-k' ? :keep_pr_links : :strip_pr_links

# Format:
#
# 1.23
# -----
#
# 1.22
# -----
# -   something #123
# -   something #234
#
# 1.21
# -----
# -   something something #345

# Skip the first three lines: the next version header
lines = lines[3...]

# Isolate the current version by looking for the first new line
release_lines = []
lines[2...].each do |line|
  break if line.strip == ''
  release_lines.push line
end

formatted_lines = release_lines.
    map { |l| l.gsub(/-   /, '- ') }

if mode == :strip_pr_links
  formatted_lines = formatted_lines.
    map { |l| l.gsub(/ \#\d*$/, '') }
end

# TODO: It would be good to either add overriding of the file where the parsed
# release notes should go. I haven't done it yet because I'm using this script
# also to generate the text for the release notes on GitHub, where I want to
# keep the PR links. See info on the usage a the start of the file.
puts formatted_lines
