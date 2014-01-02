#encoding: utf-8

require 'russian'

def convert(string)
    return "" if string.nil?
    string.force_encoding('utf-8')
    # use this in ruby 1.8 
    #Iconv.conv('UTF-8//IGNORE', 'UTF-8', string + ' ')[0..-2]
end
def clean_filename(old)
    clean_ansi(old).gsub("?","").gsub(":", "").gsub("%","").gsub("\"","'").gsub("|","").gsub("+","")
end
def clean_ansi(old)
    Russian.translit(old.gsub("ä","ae").gsub("ö","oe").sub("ü","ue").gsub("ß", "ss"))
end
def clean_ref(old)
    Russian.translit(old.gsub("ä","a").gsub("ö","o").sub("ü","u").gsub("ß", "ss"))
end
def clean(old)
    clean_ansi(old.gsub(" ", "-").gsub(",", "-").gsub("(", "").gsub(")", "").gsub("#", ""))
end

def more_clean(old)
     a = clean(old)
     a.gsub( /[^0-9a-zA-Z\-]/, '' )
end
