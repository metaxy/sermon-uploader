#encoding: utf-8

require_relative 'ref'

def writeid3_mp3(file_name, file_info)
    begin
        frame_factory = TagLib::ID3v2::FrameFactory.instance
        frame_factory.default_text_encoding = TagLib::String::UTF8
        TagLib::MPEG::File.open file do |file_name|
            tag = file.id3v2_tag
            tag.album = file_info[:serie]
            tag.year = Date.parse(file_info[:date]).year
            tag.comment = "Aufnahme der ECG Berlin http://ecg-berlin.de"
            tag.artist = file_info[:speaker]
            if is_valid_ref? file_info[:ref]
                tag.title  = "#{refs_normalize(file_info[:ref], file_info[:lang])} #{file_info[:title]}"
            else
                tag.title = file_info[:title]
            end
            file.save
        end
    rescue => e
        puts e
        $logger.warn "writing id3-tags failed on #{file_name}"
    end
end
      
def writemeta_mp4(file_name, file_info)
    begin
        frame_factory = TagLib::MP4::FrameFactory.instance
        frame_factory.default_text_encoding = TagLib::String::UTF8
        TagLib::MP4::File.open file do |file_name|
            tag = file.tag
            tag.setAlbum(file_info[:serie]);
            tag.setYear(Date.parse(file_info[:date]).year);
            tag.setComment("Aufnahme der ECG Berlin http://ecg-berlin.de");
            tag.setArtist(file_info[:speaker])
            if is_valid_ref? file_info[:ref]
                tag.setTitle("#{refs_normalize(file_[:ref], file_info[:lang])} #{file_info[:title]}")
            else
                tag.setTitle(file_info[:title])
            end
            
            file.save
        end
    rescue
        $logger.warn "writing tags failed on #{file_name}"
    end
end
# gets a Path to a file and some info about it, and renames it to be pretty
def rename(file_name, file_info)
    new_file_name = file_name.dup
    
    ref = ""
    if is_valid_ref?(file_info[:ref]) 
        ref = "["+refs_normalize(file_info[:ref], file_info[:lang]) + "] "
    end
    suffix = File.extname(file_name).downcase
    dir = File.dirname file_name
    if(suffix == ".mp3" || suffix == ".ogg" || suffix == ".mp4")
        new_file_name = 
                dir + 
                "/#{file_info[:date]} #{clean_filename(file_info[:title])} (#{clean_filename(file_info[:speaker])})" + 
                suffix

    else
        new_file_name = dir + "/" + clean(File.basename(file_name))
    end
    File.rename(file_name, new_file_name)
    return new_file_name
end

def prepare_file(file_name, file_info)
    suffix =  File.extname(file_name).downcase
    writeid3_mp3(file_name, file_info)  if suffix == ".mp3" 
    writemeta_mp4(file_name, file_info) if suffix == ".mp4" 
    rename(file_name, file_info)
end
    
def prepare_files(file_info)
    file_info[:new_file_names] = []
    file_info[:files].each do |file|
        file_info[:new_file_names] << prepare_file(file, file_info)
    end
    return file_info
end

   