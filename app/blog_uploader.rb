class BlogUploader

  LOCAL_BLOG_ENTRY_DIR = File.expand_path("../blog-entries", File.dirname(__FILE__)) 

  def initialize
    @local_blog_entries = fetch_local_blog_entries
  end

  def process_photos
  end

  def upload_photos
  end

  def create_blog_entries
  end

  private

  def fetch_local_blog_entries
  end
end
