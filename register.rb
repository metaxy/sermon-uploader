#encoding: utf-8
require 'rest_client'
require 'json'

def register(file_info)
    data = Hash[
        'title' => convert(file_info[:title]),
        'lang' => file_info[:lang],
        'groupName' => file_info[:groupName],
        'speaker' => convert(file_info[:speaker]),
        'date' => file_info[:date],
        'seriesName' => convert(file_info[:series])].to_json
                                    
    RestClient.put $options[:api]+"sermons-insert", data, {:content_type => :json}                          
end

