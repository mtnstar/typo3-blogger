require 'mini_exiftool'
require 'fileutils'

module Photos
  class Processor

    def initialize(output: $stdout, blog_entries_dir:)
      @output = output
      @new_photos_dir = new_photos_dir(blog_entries_dir)
      @processed_photos_dir = proccessed_photos_dir(blog_entries_dir)
    end

    def process(entry)
      date_times = []
      Dir.glob(File.join(@new_photos_dir, "*", "*.{jpg,jpeg}")).each do |photo|
        image = MiniExiftool.new(photo)
        date_time = image.date_time_original
        if date_time.nil?
          output(entry, "Photo #{File.basename(photo)} has no date time\n")
        else
          move_proccessed(photo, date_time, entry)
        end
      end
    end

    private

    def move_proccessed(photo, date_time, entry)
      target_dir = create_day_dir(entry, date_time.to_date.strftime("%Y-%m-%d"))
      target_file_name = "#{date_time.strftime("%Y%m%d_%H%M%S")}.jpg"
      FileUtils.mv(photo, File.join(target_dir, target_file_name))
      output(entry, "moved #{target_file_name} to processed\n")
    end

    def output(entry, message)
      @output.print("#{entry[:year_month]} #{entry[:name]}: #{message}")
    end

    def dir_name(entry)
      "#{entry[:year_month]} #{entry[:name]}"
    end

    def create_day_dir(entry, day)
      dir_path = File.join(@processed_photos_dir, dir_name(entry), day)
      FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)
      dir_path
    end

    def proccessed_photos_dir(blog_entries_dir)
      dir_path = File.join(blog_entries_dir, "processed")
      Dir.mkdir(dir_path) unless Dir.exist?(dir_path)
      dir_path
    end

    def new_photos_dir(blog_entries_dir)
      File.join(blog_entries_dir, "new")
    end

  end
end
