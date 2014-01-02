#encoding: utf-8
require 'rest_client'
require 'json'

def files_data(file_names)
    ret = []
    file_names.each do |file_name|
        #todo: get file type
        file_type = "other"
        file_name[$options[:visible_path]] = "/"
        suffix = File.extname(file_name).downcase
        puts "#{suffix} of #{file_name}"
        if(suffix == ".mp3" or suffix == ".ogg")
            file_type = "audio"
        elsif (suffix == ".mp4")
            file_type = "video"
        end
        ret << Hash[
            'sermonsFileType' => file_type,
            'sermonsFilePath' => file_name,
            'sermonsFileTitle' => ""
        ]
    end
    return ret
end
def ref_prepare(ref)
    hash = ref_data ref
    if(hash.nil?)
        return []
    else
        return [hash]
    end
end
def register(file_info)
    data = Hash[
        'title' => convert(file_info[:title]),
        'lang' => file_info[:lang],
        'groupName' => file_info[:group_name],
        'speaker' => convert(file_info[:speaker]),
        'date' => file_info[:date],
        'seriesName' => convert(file_info[:series]),
        'scriptures' => ref_prepare(file_info[:ref]),
        'files' => files_data(file_info[:remote_file_names])
    ]
    puts data.to_s
    begin
         echo "posting to #{$options[:api]}sermons-insert \n #{data.to_json.to_s}"
         RestClient.post $options[:api]+"sermons-insert",  data.to_json.to_s, {}  
    rescue => e
        puts e.response
        puts e.to_str
    end                               
    
end

