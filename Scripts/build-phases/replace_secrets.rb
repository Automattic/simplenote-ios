#!/usr/bin/env ruby
##
## This Script loads a collection of (JSON Encoded) secrets, and performs replacement operations
## over a given Template.
##
##  Note that in order for the Replacement OP's to work, your placeholders should look like this:
##
##	%{SIMPLENOTE_CREDENTIALS}
##
require 'json'
require 'optparse'


## Parse Input Parameters
##
options = {}

optparse = OptionParser.new do |opts|
  opts.on('-s', '--secrets file', 'Secrets filename (must be in JSON format!)') do |secrets|
    options[:secrets] = secrets
  end

  opts.on('-i', '--input file', 'Input filename') do |input|
    options[:input] = input
  end
end

optparse.parse!


## Validate Parameters
##
for parameter in [:secrets, :input]
	filename = options[parameter]

	if filename.nil? == true || File.exists?(filename) == false then
		puts optparse
		exit
	end
end


## Loads the Secrets at the specified Path. This must be a JSON Valid file!
##
def load(secrets_path)
	raw_secrets = File.read(secrets_path)
	output = JSON.parse(raw_secrets, :symbolize_names => true)
    output[:timestamp] = Time.now.strftime("%b %d, %Y at %H:%M:%S")

    return output
end


## Loads the Template at the specified path, and applies Placeholder Replacement OP's, with the secrets 
## located at a given path.
##
def process(template_path, secrets_path)
	secrets = load(secrets_path)
	template = File.open(template_path, "r")

	template.each_line { |line|
		puts line % secrets
	}

	template.close
end


## Main!
##
process(options[:input], options[:secrets])
