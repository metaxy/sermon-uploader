# encoding: utf-8
require 'rubygems'

require './config.rb'
require './metadata.rb'
require './upload.rb'
require './api.rb'
require './parts/local.rb'
# download/new/cat/title/date - stelle - preacher.mp3

# a folder
def addFile(path)
    puts "cron.rb addFile #{path}"
    Dir.foreach(path) do |item|
        next if item == '.' or item == '..'
        //get metadata
    end
end

def main
    
    getOptions()
    
    # scan
    Dir.foreach('/path/to/dir') do |item|
        next if item == '.' or item == '..'
        puts path
        addFile(path) if(File.directory? item)
    end
    
    # some error checking
    return if error_check($options) == :failed
    
    names = do_meta()

    api = Api.new(LocalPipe.new)
    u = Upload.new(api)
    u.up(names)
end
main()