# encoding: utf-8
require './register.rb'

class Upload
    def initialize(api)
        @api = api
    end
    def up(files)
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