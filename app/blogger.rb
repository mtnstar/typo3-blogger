require_relative "photos/processor"

class Blogger

  LOCAL_BLOG_ENTRIES_DIR = File.expand_path("../blog-entries", File.dirname(__FILE__)) 

  def initialize(output: $stdout, blog_entries_dir: LOCAL_BLOG_ENTRIES_DIR)
    @output = output
    @blog_entries_dir = blog_entries_dir
    @new_local_blog_entries = fetch_new_local_blog_entries
  end

  def process
    @new_local_blog_entries.each do |entry|
      photos_processor.process(entry)
    end
    remove_empty_new_folders
  end

  def upload_photos
  end

  def create_blog_entries
  end

  def status
    @output.print("Blog entries to be proccessed: \n")

    @new_local_blog_entries.each do |entry|
      @output.print("#{entry[:year_month]} #{entry[:name]}\n")
    end
  end

  private

  def remove_empty_new_folders
    Dir.entries(new_blog_entries_dir).each do |dir|
      full_path = File.join(new_blog_entries_dir, dir)
      if Dir.empty?(full_path)
        FileUtils.rmdir(full_path)
      end
    end
  end

  def photos_processor
    @photos_processor ||=
      Photos::Processor.new(output: @output,
                            blog_entries_dir: @blog_entries_dir)
  end

  def fetch_new_local_blog_entries
    fetch_new_local_blog_directories.map do |entry|
      if entry =~ /^(\d{4}-\d{2}) (.+)/
        { year_month: $1, name: $2 }
      end
    end.compact
  end

  def new_blog_entries_dir
    File.join(@blog_entries_dir, "new")
  end

  def fetch_new_local_blog_directories
    Dir.entries(new_blog_entries_dir).select do |dir|
      # Check if it's a directory and matches the schema
      full_path = File.join(new_blog_entries_dir, dir)
      File.directory?(full_path) && dir.match?(/^\d{4}-\d{2} .+/)
    end
  end
end
