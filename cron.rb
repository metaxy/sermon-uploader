# encoding: utf-8
require 'rubygems'

require './config.rb'
require './metadata.rb'
require './upload.rb'
require './api.rb'
require './parts/local.rb'
# download/new/cat/title/date = stelle = preacher.mp3

# a folder
def addFile(path)
    #puts "cron.rb addFile #{path}"
    mp3 = nil
    files = []
    Dir.foreach(path) do |item|
        next if item == '.' or item == '..'
        #puts item
        mp3 = path + '/' + item if (File.extname(item) == ".mp3")
        files << item
    end
    return :failed if mp3 == nil
    reg = /\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)(\s*)=(\s*)([^\/=]+)(\s*)=(\s*)([^\/)=]+).mp3/
    puts mp3
    if(reg =~ mp3) 
        y = mp3.scan(reg)[0]
        puts y
        $options[:cat] = y[0]
        $options[:title] = y[1]
        $options[:date] = y[2]
        $options[:ref] = y[5]
        $options[:preacher] = y[8]
    else
        puts "didnt't match regexp"
        return :failed
    end
    $options[:files] = files
    puts "found one #{path}"
    return :ok
end

def main
    
    getOptions()
    
    # scan
    
    Dir.glob($options[:newHome] + "/**/*").each do |item|
        #puts "item #{item}"
        next if item == '.' or item == '..'
        next if(not File.directory? item)
        cleanOptions()
        puts item
        
        next if addFile(item) != :ok
        puts $options
        next if error_check($options) == :failed
    
        names = do_meta()

        api = Api.new(LocalPipe.new)
        u = Upload.new(api)
        u.up(names)
    end
    puts "done"
    # some error checking
   
end
main()