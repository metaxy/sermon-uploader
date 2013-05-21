# encoding: utf-8
require 'rubygems'

require './config.rb'
require './metadata.rb'
require './upload.rb'
require './api.rb'
require './parts/local.rb'
require 'logger'
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
    
        names = do_meta()

        api = Api.new(LocalPipe.new)
        u = Upload.new(api)
        u.up(names)
    end
    $logger.debug "done"
    # some error checking
   
end
main()