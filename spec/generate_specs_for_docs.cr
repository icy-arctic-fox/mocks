#!/usr/bin/env crystal

# This script extracts example code from the documentation
# and produces test specs for them.

files = %w[README.md]
files += Dir.glob("doc/**/*.md")

# Regular expression that looks for Markdown code blocks with Crystal syntax.
# Captures any HTML comments before the code block, which may contain a directive.
# Match group 1 - HTML comment text
# Match group 2 - Code snippet
code_block_regex = /^(?:<!-- ([^>]+) -->\n)?```cr(?:ystal)?\n(?!```)(.*?)```$/m

def spec_file_name(source_file, id)
  File.join("spec", "doc", "#{File.basename(source_file).tr(".", "_")}_#{id}_spec.cr")
end

def write_spec_file(path, code)
  File.open(path, "w") do |file|
    file.puts "require \"../spec_helper\""
    file.puts
    file.puts code
  end
end

def wrap_snippet_with_location(snippet, file, line = 1, char = 1)
  <<-END_SNIPPET
  #<loc:push>#<loc:"#{file}",#{line},#{char}>
  #{snippet}
  #<loc:pop>
  END_SNIPPET
end

files.each do |file|
  content = File.read(file)
  snippets = [] of String

  content.scan(code_block_regex) do |match|
    directive = match[1]?.try &.downcase
    snippet = match[2].strip

    # Get the line number of the snippet.
    start = match.begin(2)
    before_snippet = content[0...start]
    line = before_snippet.count('\n')

    # Modify locations to reference original file.
    snippet = wrap_snippet_with_location(snippet, file, line)

    case directive
    when "no-spec"       then next
    when "continue-spec" then snippets[-1] += "\n#{snippet}"
    else                      snippets << snippet
    end
  end

  snippets.each_with_index do |snippet, i|
    file_name = spec_file_name(file, i)
    dir_name = File.dirname(file_name)
    Dir.mkdir_p(dir_name) unless Dir.exists?(dir_name)
    write_spec_file(file_name, snippet)
    i += 1
  end
end
