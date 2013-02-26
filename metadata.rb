require 'taglib'

def writeid3(file)
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
end
def clean(old)
    old.sub(" ", "-").sub(",", "-").sub("(", "").sub(")", "")
end
def rename(old)
    newName = old
    cat = $catNames[$options[:cat]]
    ref = ""
    ref = " " + ref + " " if $options[:ref] != "" and $options[:ref] != nil
    if(File.extname(old) == ".mp3" || File.extname(old) == ".mp4")
        newName = File.dirname(old) + 
                "/#{$options[:date]} #{cat} - #{ref}#{$options[:title]} (#{$options[:preacher]})" + 
                File.extname(old)
    else
        newName = File.dirname(old) + clean(File.basename(old)) + File.extname(old)
    end
    File.rename(old, newName)
    newName
end