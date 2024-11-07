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

    it "renames and organises photos in daily folders" do
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
  end
end
