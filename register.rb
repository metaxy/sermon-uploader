#encoding: utf-8
require 'rest_client'
require 'json'
require 'securerandom'
require 'openssl'

def files_data(file_names)
    ret = []
    file_names.each do |file_name|
        file_type = "other"
        suffix = File.extname(file_name).downcase
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
def register(file_info)
    puts file_info.to_yaml
    random = SecureRandom.urlsafe_base64
    digest  = OpenSSL::Digest::Digest.new('sha1')
    hash = OpenSSL::HMAC.hexdigest(digest, $options[:secretKey], random)
    
    data = Hash[
        'title' => convert(file_info[:title]),
        'lang' => file_info[:lang],
        'groupName' => file_info[:group_name],
        'speaker' => convert(file_info[:speaker]),
        'date' => file_info[:date],
        'seriesName' => convert(file_info[:serie]),
        'scriptures' => refs_data(file_info[:ref]),
        'files' => files_data(file_info[:remote_file_names]),
        'random' => random,
        'hash' => hash,
        'notes' => '',
        'visibility' => 1
    ]
    puts "register() :: #{data.to_s}"
    begin
         RestClient.post $options[:api]+"sermons/insert",  data.to_json.to_s, {}  
    rescue => e
        puts e.response
        puts e.to_str
    end                               
    
end

