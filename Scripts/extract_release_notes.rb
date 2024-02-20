# Parses the release notes file to extract the current version information and
# puts it to STDOUT.
#
# To update the release notes for localization:
#
# ruby ./this_script >| Simplenote/Resources/release_notes.txt
#
# To generate the App Store Connect release message:
#
# ruby ./this_script | pbcopy
#
# To generate the GitHub and App Center release message:
#
# ruby ./this_script -k | pbcopy

GITHUB_URL = 'https://github.com/Automattic/simplenote-ios'

RELEASE_NOTES_FILE = 'RELEASE-NOTES.txt'
NOTES = File.read(RELEASE_NOTES_FILE)
lines = NOTES.lines

def replace_pr_number_with_markdown_link(string)
  string.gsub(/\#\d*$/) do |pr_number|
    "[#{pr_number}](#{GITHUB_URL}/pull/#{pr_number.gsub('#', '')})"
  end
end

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

# Find the start of the releases by looking for the line with the '-----'
# sequence. This accounts for the edge case in which more new lines make it
# into the release notes file than expected.
index = 0
index += 1 until lines[index].start_with? '-----'

lines[(index + 1)...].each do |line|
  break if line.strip == ''

  release_lines.push line
end

formatted_lines = release_lines
                  .map { |l| l.gsub('-   ', '- ') }

case mode
when :strip_pr_links
  formatted_lines = formatted_lines
                    .map { |l| l.gsub(/ \#\d*$/, '') }
when :keep_pr_links
  formatted_lines = formatted_lines.
                    # The PR "links" are not actually links, but PR "ids". On GitHub, they'll
                    # be automatically parsed into links to the corresponding PR, but outside
                    # GitHub, such as in our internal posts or on App Center, they won't.
                    #
                    # It's probably best to update the convention in writing the release notes
                    # but in the meantime let's compensate with more automation.
                    map { |l| replace_pr_number_with_markdown_link(l) }
end

# It would be good to either add overriding of the file where the parsed
# release notes should go. I haven't done it yet because I'm using this script
# also to generate the text for the release notes on GitHub, where I want to
# keep the PR links. See info on the usage a the start of the file.
puts formatted_lines
