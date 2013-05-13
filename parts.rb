
# Progress Bar parts

class GuiBar 
    def update(name, sent, total)
        $w.update(send.to_i, total.to_i)
        print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
    end
end

class CmdBar 
    def update(name, sent, total)
        print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
    end
end

# Pipe Parts

class SshPipe
    def init()
    end
    def upload(localName, remoteName)
    end
    def close()
    end
end

class FtpPipe
    
end

class LocalPipe
end
