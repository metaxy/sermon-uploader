# encoding: utf-8
require 'taglib'
def writeid3_mp3(file)
    lang = $defLoc
    lang = "ru" if(Russian.translit($options[:title]) != $options[:title])
    begin
        frame_factory = TagLib::ID3v2::FrameFactory.instance
        frame_factory.default_text_encoding = TagLib::String::UTF8
        TagLib::MPEG::File.open file do |file|
            tag = file.id3v2_tag
            tag.album = $options[:serie]
            tag.year = Date.parse($options[:date]).year
            tag.comment = "Aufnahme der ECG Berlin http://ecg-berlin.de"
            tag.artist = $options[:preacher]
              if $options[:ref] != ""
                tag.title = $options[:title];
            else
                tag.title  = "#{clean_ref($options[:ref], lang)} #{$options[:title]}";
            end
            file.save
        end
    rescue
    end
end
def writemeta_mp4(file)
    lang = $defLoc
    lang = "ru" if(Russian.translit($options[:title]) != $options[:title])
    begin
        frame_factory = TagLib::MP4::FrameFactory.instance
        frame_factory.default_text_encoding = TagLib::String::UTF8
        TagLib::MP4::File.open file do |file|
            tag = file.tag
            tag.setAlbum($options[:serie]);
            tag.setYear(Date.parse($options[:date]).year);
            tag.setComment("Aufnahme der ECG Berlin http://ecg-berlin.de");
            tag.setArtist($options[:preacher])
            if $options[:ref] != ""
                tag.setTitle($options[:title]);
            else
                tag.setTitle("#{clean_ref($options[:ref], lang)} #{$options[:title]}");
            end
            
            file.save
        end
    rescue
    end
end
def rename(old)
    lang = $defLoc
    lang = "ru" if(Russian.translit($options[:title]) != $options[:title])
    puts "metadat.rb rename langh = #{lang}"
    newName = old
    cat = $catNames[$options[:cat]]
    
    ref = ""
    (ref =  normalizeRef($options[:ref], lang) + " ") if $options[:ref] != ""
    if(File.extname(old).downcase == ".mp3" || File.extname(old).downcase == ".ogg" || File.extname(old).downcase == ".mp4")
        newName = File.dirname(old) + 
                "/#{$options[:date]} #{clean_ref(ref, lang)}#{clean_ansi($options[:title])} (#{clean_ansi($options[:preacher])})" + 
                File.extname(old).downcase
    else
        newName = File.dirname(old) + "/" + clean(File.basename(old))
    end
    File.rename(old, newName)
    return newName
end
def do_meta
    puts "metadata.rb do_meta()";
    newNames = []
    $options[:files].each do |x|
        puts "main.tb :::: processing filename = " + x
            
        newName = rename(x)
        writeid3_mp3(newName) if File.extname(newName).downcase == ".mp3" 
        writemeta_mp4(newName) if File.extname(newName).downcase == ".mp4" 
        newNames << newName
    end
    newNames
end
