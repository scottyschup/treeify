#!/usr/bin/env ruby

class IndexBuilder
  attr_accessor :current_path

  def initialize(root: Dir.pwd)
    @root_dir = root.gsub(' ', '\ ')
    @output_file = 'index.html'
    @file_count = 0
    @dir_count = 0

    if overwrite_index?
      `rm #{@root_dir}/index.html`
    else
      `mv #{@root_dir}/index.html #{@root_dir}/index2.html`
    end if index_file_exists?
  end

  def build_index(relative_links: true)
    @relative = relative_links
    @last_update = Time.now
    add_top_html
    add_body_header
    add_iframe
    add_buttons
    add_subdirs_and_files(@root_dir)
    add_bottom_html
    write_files
  end

  private

  def add_body_header
    @output += "<header><h1>Index for #{@root_dir}</h1></header>"
  end

  def add_bottom_html
    @output += '<script src="./treeify_assets/main.js" type="text/javascript"></script></body></html>'
  end

  def add_buttons
    @output += '<div id="tree-viewer">'
    @output += '<div class="all-buttons">'
    @output += '<button id="expand-all">Expand All</button>'
    @output += '<button id="collapse-all">Collapse All</button></div>'
  end

  def add_files(dir)
    # TODO: add file size info; potentially return agg size too for dir size
    result = %x(ls '#{dir}' 2>&1)
    unless $? == 0
      puts "Error (in add_subdirs_and_files) while processing: #{dir}"
    end

    files = result.split("\n").select do |item|
      File.file?("#{dir}/#{item}")
    end

    files.each do |file|
      path = @relative ? dir.gsub(@root_dir, '.') : dir
      @output += "<li class=\"file\" id=\"#{dir}/#{file}\">"
      @output += "<a href=\"#{path}/#{file}\" target=\"file-viewer\">#{file}</a></li>"
      @file_count += 1
    end
  end

  def add_iframe
    @output += "<div id=\"file-viewer\">"
    @output += "<button id=\"show-tree\">Back to Tree View</button>"
    @output += "<iframe name=\"file-viewer\" src=\"\"></iframe></div>"
  end

  def add_subdir(dir, subdir)
    curr_dir = "#{dir}/#{subdir}"
    @output += "<li class=\"directory\" id=\"#{curr_dir}\">"
    @output += "<button class=\"toggle\">+</button>#{subdir}"
    add_subdirs_and_files(curr_dir)
    @output += '</li>'
    @dir_count += 1
  end

  def add_subdirs_and_files(dir)
    result = %x(ls '#{dir}' 2>&1)
    unless $? == 0
      puts "Error (in add_subdirs_and_files) while processing: #{dir}"
    end

    subdirs = result.split("\n").select do |item|
      File.directory?("#{dir}/#{item}")
    end

    @output += "<ul id=\"root\">"
    subdirs.each do |subdir|
      subdir.gsub!(' ', '\ ')
      add_subdir(dir, subdir)
    end

    add_files(dir)
    @output += '</ul>'

    progress_report
    # eventually return bubbled up dir size here
  end

  def add_top_html
    @output = "<!DOCTYPE html><html><head><meta charset=\"utf-8\">"
    @output += "<title>Tree Index for #{@root_dir}</title>"
    @output += "<link rel=\"stylesheet\" type=\"text/css\" href=\"./treeify_assets/main.css\" />"
    @output += "</head><body>"
  end

  def index_file_exists?
    File.exists?("#{@root_dir}/index.html")
  end

  def overwrite_index?
    puts 'Rename and keep existing index.html file? (y/n)'
    gets[0].downcase != 'y'
  end

  def progress_report
    if (Time.now - @last_update) > 2
      puts "Directories processed: #{@dir_count}"
      puts "Files processed: #{@file_count}"
      @last_update = Time.now
    end
  end

  def write_files
    File.write("#{@root_dir}/#{@output_file}", @output)
    if File.exist?("#{@root_dir}/treeify_assets")
      puts "treeify_assets directory already exists"
    else
      `cp -r ./treeify_assets #{@root_dir}`
    end
  end
end

if $PROGRAM_NAME == __FILE__
  puts 'Build index for current directory? (y/n)'
  use_pwd = gets[0].downcase == 'y'

  if use_pwd
    ib = IndexBuilder.new
  else
    puts 'Provide path for target directory:'
    resp = gets.chomp
    root = resp[0] == '/' ? resp : Dir.pwd + '/' + resp
    ib = IndexBuilder.new(root: root)
  end

  puts 'Use absolute or relative paths for file links? (a/r)'
  relative = gets[0].downcase == 'r'
  ib.build_index(relative_links: relative)
end
