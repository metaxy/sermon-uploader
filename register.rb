#encoding: utf-8

class Register
    def initialize(api)
        @api = api
    end                           
    def register(newPaths)
        speaker_id = @api.getSpeakerID($options[:preacher].force_encoding('utf-8'))
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
                    'audiofile' => audiofile.force_encoding('utf-8'),
                    'videofile' => videofile.force_encoding('utf-8'),
                    'sermon_title' => $options[:title].force_encoding('utf-8'),
                    'alias' => $options[:title].force_encoding('utf-8'),
                    'addfile' => addfile,
                    'addfileDesc' => $options[:addfileDesc].force_encoding('utf-8'),
                    'catid' => cat_id,
                    'language' => $options[:lang],
                    'sermon_date' => $options[:date],
                    'sermon_time' => ""
                ]
        puts data
        
        j = data.to_json.to_s
        @pipe.writeData(j);
    
        
        if $options[:ref] != nil
            ref = @api.refToJson($options[:ref])
            if(ref != nil)
                puts "ref json = " + ref
                @pipe.writeDataVerse(ref)
            end
        end
        @pipe.execInsert()
        
    end
end
