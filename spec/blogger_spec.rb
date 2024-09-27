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

  context "photo processing" do
    it "renames and organises photos in daily folders" do
    end
  end
end
