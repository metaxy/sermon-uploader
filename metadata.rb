# encoding: utf-8
require 'taglib'
def writeid3(file)
    begin
        frame_factory = TagLib::ID3v2::FrameFactory.instance
        frame_factory.default_text_encoding = TagLib::String::UTF8
        TagLib::MPEG::File.open file do |file|
            tag = file.id3v2_tag
            tag.album = $options[:serie]
            tag.year = Date.parse($options[:date]).year
            tag.comment = "Aufnahme der ECG Berlin http://ecg-berlin.de"
            tag.artist = $options[:preacher]
            tag.title = $options[:title]
            file.save
        end
    rescue
    end
end

def rename(old)
    newName = old
    cat = $catNames[$options[:cat]]
    ref = ""
    (ref = $options[:ref] + " ") if $options[:ref] != ""
    if(File.extname(old).downcase == ".mp3" || File.extname(old).downcase == ".ogg" || File.extname(old).downcase == ".mp4")
        newName = File.dirname(old) + 
                "/#{$options[:date]} #{clean_ansi(ref.gsub("Röm","Rom"))}#{clean_ansi($options[:title])} (#{clean_ansi($options[:preacher])})" + 
                File.extname(old).downcase
    else
        newName = File.dirname(old) + "/" + clean(File.basename(old))
    end
    File.rename(old, newName)
    newName
end
def do_meta
    puts "metadata.rb do_meta()";
    newNames = []
    $options[:files].each do |x|
        puts "main.tb :::: processing filename = " + x
            
        newName = rename(x)
        writeid3(newName) if File.extname(newName) == ".mp3" || File.extname(newName) == ".ogg" # || File.extname(newName) == ".mp4" 
        newNames << newName
    end
    newNames
end
