# encoding: utf-8
require 'rubygems'
require 'logger'
require 'time'

require_relative 'config'
require_relative 'metadata'
require_relative 'upload'
require_relative 'api'
require_relative 'parts/local'

# download/new/cat/title/date = stelle = preacher.mp3
$logger = Logger.new('logfile.log')
    
# a folder
def addFile(path)
    mp3 = nil
    files = []
    Dir.foreach(path) do |item|
        next if item == '.' or item == '..'
        mp3 = path + '/' + item if (File.extname(item) == ".mp3")
        files <<  path + '/' + item
    end
    return :failed if mp3 == nil
    reg = /\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)(\s*)=(\s*)([^\/=]+)(\s*)=(\s*)([^\/)=]+).mp3/
    if(reg =~ mp3) 
        y = mp3.scan(reg)[0]
        $options[:cat] = y[0]
        $options[:title] = y[1]
        $options[:date] = y[2]
        $options[:ref] = y[5]
        $options[:preacher] = y[8]
    else
        $logger.warn "didnt't match regexp"
        return :failed
    end
    $options[:files] = files
    $logger.debug "found one #{path}"
    return :ok
end


def addVideo()
    puts "add videos()";
    date = Date.parse($options[:date])
    puts "we need #{date.year} #{date.yday}";
    Dir.foreach($options[:videoPath]).each do |item|
        fileTime = File.mtime($options[:videoPath]+"/"+item)
        if(item == "ecg_source_155.mp4")
            puts "#{fileTime.year} #{fileTime.yday}";
        end
        if(fileTime.year == date.year && fileTime.yday == date.yday)
            $logger.debug "found right day #{item}"
        end
    end
end
def main
    
    getOptions()
    
    # scan
    
    Dir.glob($options[:newHome] + "/**/*").each do |item|
        next if item == '.' or item == '..'
        next if(not File.directory? item)
        cleanOptions()
        $logger.debug  item
        
        next if addFile(item) != :ok
        $logger.debug  $options
        next if error_check($options) == :failed
        
        # add audio files
        names = []
       # names << do_meta()
        # add Video file
       # if($options[:autoVideo])
            $logger.debug "add videos"
            puts "add videos"
            names << addVideo()
      #  end
     #   api = Api.new(LocalPipe.new)
  #      u = Upload.new(api)
  #      u.up(names)
    end
    $logger.debug "done"
    # some error checking
   
end
main()