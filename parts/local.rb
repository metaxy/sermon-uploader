# encoding: utf-8
require 'fileutils'
 
def local_upload(local_name, remote_name, call)
    if(not File.exists?(File.dirname(remote_name)))
        FileUtils.mkdir_p(File.dirname(remote_name))
    end
    
    FileUtils.cp local_name, remote_name
end