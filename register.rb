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
        #puts "Register.register()";
        speaker_id = @api.getSpeakerID(convert($options[:preacher]))
        new_speaker = convert($options[:preacher])
        new_speaker_alias = convert($options[:preacher])

        series_id = @api.getSeriesID($options[:serie])
        cat_id = @api.getCatID($options[:cat])

        audiofile = ""
        videofile = ""
        addfile = ""
        oggfile = ""
        newPaths.each do |x|
            ext = File.extname(x) rescue ""
            case ext
                when ".mp3"
                    audiofile = x
                when ".mp4"
                    videofile = x
                when ".ogg"
                    oggfile = x
                else
                    addfile = x
            end
        end
        data = Hash['speaker_id' => speaker_id,
                    'series_id' => series_id,
                    'audiofile' => convert(audiofile),
                    'videofile' => convert(videofile),
                    'title' => convert($options[:title]),
                    'alias' => more_clean(convert($options[:title])),
                    'addfile' => addfile,
                    'addfileDesc' => convert($options[:addfileDesc]),
                    'catid' => cat_id,
                    'language' => $options[:lang],
                    'sermon_date' => $options[:date],
                    'sermon_time' => "",
                    'new_speaker' => new_speaker,
                    'new_speaker_alias' => new_speaker_alias
                ]
        #puts data
        
        j = data.to_json.to_s
        @api.writeData(j);
    
        
        if @api.hasRef?($options[:ref])
            ref = @api.refToJson($options[:ref])
            @api.writeDataVerse(ref)
        end
        @api.execInsert()
        
    end
end
