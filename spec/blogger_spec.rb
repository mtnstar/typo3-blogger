require 'tmpdir'
require_relative "../app/blogger"

describe Blogger do
  let(:output) { double(puts: nil, print: nil) }
  subject(:blogger) { described_class.new(output: output, blog_entries_dir: test_blog_entries_dir) }
  let(:fixture_blog_entries_dir) { File.join(File.expand_path(__dir__), "fixtures", "blog-entries") }
  let(:tmp_dir) { Dir.mktmpdir }
  let(:test_blog_entries_dir) do
    FileUtils.cp_r(fixture_blog_entries_dir, tmp_dir)
    "#{tmp_dir}/blog-entries"
  end

  around do |example|
    example.run

    FileUtils.rm_rf(tmp_dir)
  end

  context "#status" do
    it "lists all new and processed blog entries" do
      expected_output = ["Blog entries to be proccessed: \n"]
      expected_output << "2024-08 Piz Bernina\n"
      expected_output << "2022-11 Queen Charlotte Track\n"
      # TODO list also processed entries

      expected_output.each do |output_line|
        expect(output).to receive(:print).with(output_line)
      end

      blogger.status
    end
  end

  context "#process" do
    let(:processed_photos_dir) { File.join(test_blog_entries_dir, "processed") }
    let(:bernina_target_day_file_names) do
      {
        "2024-08-06" => [
          "20240806_101105.jpg", "20240806_115847.jpg", "20240806_135242.jpg", "20240806_151318.jpg"
        ],
        "2024-08-07" => [
          "20240807_071732.jpg", "20240807_083524.jpg", "20240807_055134.jpg", "20240807_060047.jpg",
          "20240807_062005.jpg", "20240807_072555.jpg", "20240807_074153.jpg", "20240807_074435.jpg",
          "20240807_075944.jpg", "20240807_081218.jpg", "20240807_081219.jpg", "20240807_092756.jpg",
          "20240807_092806.jpg", "20240807_094927.jpg", "20240807_061338.jpg", "20240807_090404.jpg"
        ],
        "2024-08-08" => [
          "20240808_061917.jpg", "20240808_061921.jpg", "20240808_072551.jpg", "20240808_071754.jpg",
          "20240808_073355.jpg", "20240808_074606.jpg", "20240808_075409.jpg", "20240808_082357.jpg",
          "20240808_082401.jpg", "20240808_083316.jpg", "20240808_091159.jpg", "20240808_061308.jpg"
        ]
      }
    end

    # the Piz Bernina fixture keeps 20240806_101105.jpg in "drone" and
    # 20240807_092756.jpg in "drone/day2", so sub folders are covered here
    it "renames and organises photos from the entry and its sub folders in daily folders" do
      target_file_names = bernina_target_day_file_names.values.flatten

      failed_output_messages = [
        "2022-11 Queen Charlotte Track: Photo boat1.jpg has no date time\n",
      ]

      expected_output = []
      expected_output.concat(failed_output_messages)

      target_file_names.each do |file_name|
        expected_output << "2024-08 Piz Bernina: moved #{file_name} to processed\n"
      end

      expected_output.each do |output_line|
        expect(output).to receive(:print).with(output_line)
      end

      blogger.process

      ["2024-08-06", "2024-08-07", "2024-08-08"].each do |day|
        day_folder = File.join(processed_photos_dir, "2024-08 Piz Bernina", day)
        expect(Dir.exist?(day_folder)).to be true

        file_names = Dir.entries(day_folder).select { |f| !File.directory?(f) }
        expected_file_names = bernina_target_day_file_names[day]
        expect(file_names.size).to eq(expected_file_names.size)

        file_names.each do |file_name|
          expect(expected_file_names).to include(file_name)
        end
      end

    end

    # the Queen Charlotte fixture keeps photos without any date time in their
    # meta data, so the file name fallback is covered here
    it "falls back to the date time in the file name" do
      file_name_date_photos = {
        "2022-11-26" => "20221126_143012.jpg", # IMG_20221126_143012_675.jpg
        "2022-11-27" => "20221127_081542.jpg"  # 2022-11-27-08-15-42-123.jpg
      }

      file_name_date_photos.each_value do |file_name|
        expect(output).to receive(:print)
          .with("2022-11 Queen Charlotte Track: moved #{file_name} to processed\n")
      end

      blogger.process

      file_name_date_photos.each do |day, file_name|
        day_folder = File.join(processed_photos_dir, "2022-11 Queen Charlotte Track", day)
        expect(File.exist?(File.join(day_folder, file_name))).to be true
      end
    end

    it "removes new folder if all photos are processed or keeps them if not" do
      blogger.process

      expect(Dir.exist?(File.join(test_blog_entries_dir, "new", "2024-08 Piz Bernina"))).to be false
      expect(Dir.exist?(File.join(test_blog_entries_dir, "new", "2022-11 Queen Charlotte Track"))).to be true
    end

    it "removes empty sub folders but keeps the entry folder with unprocessed photos" do
      blogger.process

      queen_charlotte_dir = File.join(test_blog_entries_dir, "new", "2022-11 Queen Charlotte Track")
      expect(Dir.exist?(File.join(queen_charlotte_dir, "ridge"))).to be false
      expect(File.exist?(File.join(queen_charlotte_dir, "boat1.jpg"))).to be true
    end
  end
end
