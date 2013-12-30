# encoding: utf-8
require_relative 'register'
require_relative 'parts/ssh'

class Upload
    def initialize(api)
        @api = api
    end
    def up(files)
        #puts "uploading #{files}"
        reg = Register.new(@api)
        newPaths = []
        files.each do |file|
            n = trying(3, method(:uploadFile), file)
            return nil if(n == nil)
            newPaths << n
        end
        reg.register(newPaths)
        @api.closePipe();
        return newPaths
    end
    def uploadFile(file)
        @api.upload(file)
    end
end
def remote_path(local, file_info)
    ext = File.extname(local)
    grp = $paths[file_info[:group_name]]
    type =  case ext.downcase
                when ".mp3"
                    "audio"
                when ".ogg"
                    "audio"
                when ".mp4"
                    "video"
                else
                    "extra" 
            end
    
    year = Date.parse(file_info[:date]).year.to_s
    
    return "#{grp}/#{type}/#{year}"
end

def upload(file_info, upload_method, call) 
    file_info[:remote_file_names] = []
    file_info[:new_file_names].each do |file|
        full = remote_path(file, file_info) + "/" + File.basename(file)
        upload_method.call(file, $options[:filesHome] +  full, call)
      #  n = trying(3, method(:upload_method), file, $options[:filesHome] +  full, nil)
        file_info[:remote_file_names] << $options[:filesHome] +  full
    end
    return file_info
end