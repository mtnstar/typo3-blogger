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
      # TODO list also processed entries

      expected_output.each do |output_line|
        expect(output).to receive(:print).with(output_line)
      end

      blogger.status
    end
  end

  context "#proccess_photos" do
    let(:proccessed_photos_dir) { File.join(test_blog_entries_dir, "processed") }

    it "renames and organises photos in daily folders" do
      expected_output = ["2024-08 Piz Bernina: Photo 2024-08-07-09-04-04-000.jpg has no date time"]
      #expected_output << "2024-08 Piz Bernina\n"

      expected_output.each do |output_line|
        expect(output).to receive(:print).with(output_line)
      end

      blogger.process_photos

      ["2024-08-06", "2024-08-07", "2024-08-08"].each do |day|
        expect(Dir.exist?(File.join(proccessed_photos_dir, "2024-08 Piz Bernina", day))).to be true
      end
    end
  end
end
