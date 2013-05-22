#encoding: utf-8

def convert(string)
    string.force_encoding('utf-8')
     #Iconv.conv('UTF-8//IGNORE', 'UTF-8', string + ' ')[0..-2]
end

class Register
    def initialize(api)
        @api = api
    end                           
    def register(newPaths)
        speaker_id = @api.getSpeakerID(convert($options[:preacher]))
        series_id = @api.getSeriesID($options[:serie])
        cat_id = @api.getCatID($options[:cat])

        audiofile = ""
        videofile = ""
        addfile = ""
        newPaths.each do |x|
            ext = File.extname(x) rescue ""
            case ext
                when ".mp3"
                    audiofile = x
                when ".mp4"
                    videofile = x
                else
                    addfile = x
            end
        end
        data = Hash['speaker_id' => speaker_id,
                    'series_id' => series_id,
                    'audiofile' => convert(audiofile),
                    'videofile' => convert(videofile),
                    'sermon_title' => convert($options[:title]),
                    'alias' => convert($options[:title]),
                    'addfile' => addfile,
                    'addfileDesc' => convert($options[:addfileDesc]),
                    'catid' => cat_id,
                    'language' => $options[:lang],
                    'sermon_date' => $options[:date],
                    'sermon_time' => ""
                ]
        puts data
        
        j = data.to_json.to_s
        @api.writeData(j);
    
        
        if $options[:ref] != nil
            ref = @api.refToJson($options[:ref])
            if(ref != nil)
                puts "ref json = " + ref
                @api.writeDataVerse(ref)
            end
        end
        @api.execInsert()
        
    end
end
