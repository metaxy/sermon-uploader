# encoding: utf-8
require 'date'
require 'net/http'
require 'json'

$book = Hash[0 => ['1.Mose','1Mo'],
1 => ['2.Mose','2Mo'],
2 => ['3.Mose','3Mo'],
3 => ['4.Mose','4Mo'],
4 => ['5.Mose','5Mo'],
5 => ['Josua',' Jos'],
6 => ['Richter','Ri'],
7 => ['Rut','Ru'],
8 => ['1.Samuel','1Sa'],
9 => ['2.Samuel','2Sa'],
10 => ['1.Könige','1Kön'],
11 => ['2.Könige','2Kön'],
12 => ['1.Chronik','1Ch'],
13 => ['2.Chronik','2Ch'],
14 => ['Esra','Esr'],
15 => ['Nehemia','Ne'],
16 => ['Ester','Es'],
17 => ['Hiob','Hio'],
18 => ['Psalmen','Ps'],
19 => ['Sprüche','Spr'],
20 => ['Prediger','Pred'],
21 => ['Hohelied','Hoh'],
22 => ['Jesaja','Jes'],
23 => ['Jeremia','Jer'],
24 => ['Klagelieder','Kla'],
25 => ['Hesekiel','Hes'],
26 => ['Daniel','Da'],
27 => ['Hosea','Hos'],
28 => ['Joel','Joe'],
29 => ['Amos','','Am'],
30 => ['Obadja','Ob'],
31 => ['Jona','Jon'],
32 => ['Micha','Mic'],
33 => ['Nahum','Na'],
34 => ['Habakuk','Hab'],
35 => ['Zefanja','Zef'],
36 => ['Haggai','Hag'],
37 => ['Sacharja','Sac'],
38 => ['Maleachi','Mal'],
39 => ['Matthäus','Mt'],
40 => ['Markus','Mk'],
41 => ['Lukas','Lk'],
42 => ['Johannes','Joh'],
43 => ['Apostelgeschichte','Apg'],
44 => ['Römer','Röm'],
45 => ['1.Korinther','1Kor'],
46 => ['2.Korinther','2Kor'],
47 => ['Galater','Gal'],
48 => ['Epheser','Eph'],
49 => ['Philipper','Phil'],
50 => ['Kolosser','Kol'],
51 => ['1.Thessalonicher','1Th'],
52 => ['2.Thessalonicher','2Th'],
53 => ['1.Timotheus','1Ti'],
54 => ['2.Timotheus','2Ti'],
55 => ['Titus','Tit'],
56 => ['Philemon','Phm'],
57 => ['Hebräer','Heb'],
58 => ['Jakobus','Jak'],
59 => ['1.Petrus','1Pe'],
60 => ['2.Petrus','2Pe'],
61 => ['1.Johannes','1Joh'],
62 => ['2.Johannes','2Joh'],
63 => ['3.Johannes','3Joh'],
64 => ['Judas','Jud'],
65 => ['Offenbarung','Offb']]

def trying(t, func, *args)
    t.times do
        begin
            return func.call(*args)
        rescue Exception => e  
            puts e.message  
            puts e.backtrace.inspect  
            puts "It failed"
        end
    end
    puts "it failed forever"
    return nil
end

class Api
    
    def initialize(pipe)
        @pipe = pipe
        @pipe.init()
    end
    
    def getSpeakers()
        res = Net::HTTP.get URI($options[:api] + "action=list_speakers")
        json = JSON.parse(res)
        json.map { |x| x[1]}
    end

    def getSeries()
        res = Net::HTTP.get URI($options[:api] + "action=list_series")
        json = JSON.parse(res)
        puts json
        json.map { |x| x[2]}
    end
    def getSpeakerID(name)
        res = Net::HTTP.get URI($options[:api] + "action=list_speakers")
        return near(res, name)
    end

    def getSeriesID(name)
        res = Net::HTTP.get URI($options[:api] + "action=list_series")
        return near(res, name)
    end

    def getCatID(name)
        res = Net::HTTP.get URI($options[:api] + "action=list_cats")
        return near(res, name)
     end
    
    def getBookNames
        a = []
        $book.each do |i,j|
            a << j[0] << j[1]
        end
        return a 
    end
    
    def bookName(bookName)
        $book.each do |i,n|
            n.each do |m|
                return (i+1) if(bookName == m)
            end       
        end
        return 1
    end
    
    
    def refToJson(ref)
        if(/(\w+)\s(\d+)\,(\d+)-(\d+)\,(\d+)/ =~ ref) # BookName 1,1-2,12
            puts "type 3";
            y = ref.scan(/(\w+)\s(\d+)\,(\d+)-(\d+)\,(\d+)/)  
            x = y[0]
            return Hash['book' => bookName(x[0]),
                    'cap1' => x[1],
                    'vers1' => x[2],
                    'cap2' => x[3],
                    'vers2' => x[4]
                    ].to_json.to_s
        end
        
        if(/(\w+)\s(\d+)\,(\d+)-(\d+)/ =~ ref) # BookName 1,1-12
            puts "type 2";
            y = ref.scan(/(\w+)\s(\d+)\,(\d+)/)   
            x = y[0]
            return Hash['book' => bookName(x[0]), 
                    'cap1' => x[1],
                    'vers1' => x[2],
                    'cap2' => '0',
                    'vers2' => x[3]
                    ].to_json.to_s
        end
        
        if(/(\w+)\s(\d+)\,(\d+)/ =~ ref)
            puts "type 1"
            y = ref.scan(/(\w+)\s(\d+)\,(\d+)/) # BookName 1,1
            x = y[0]
            return Hash['book' => bookName(x[0]),
                        'cap1' => x[1],
                        'vers1' => x[2],
                        'cap2' => x[1],
                        'vers2' => x[2]
                    ].to_json.to_s
        end
        
       
        
      
        
        return nil
    end
    
    
    def remotePath(local)
        ext = File.extname(local)
        cat = $paths[$options[:cat]]
        type =  case ext.downcase
                    when ".mp3"
                        "audio"
                    when ".mp4"
                        "video"
                    else
                        "extra" 
                end
        
        year = Date.parse($options[:date]).year.to_s
        
        return "#{cat}/#{type}/#{year}"
    end

    def upload(file)
        full = remotePath(file) + "/" + File.basename(file)
        puts "upload.rb :::: Uploading";
        puts "from #{file} to #{full}"
        
        @pipe.upload(file, $options[:home] +  full)
        
        return full
    end
    
    def closePipe()
        @pipe.close();
    end
    
    def writeData(data)
        @pipe.writeData(data)
    end
    def writeDataVerse(data)
        @pipe.writeDataVerse(data)
    end
    def execInsert()
        @pipe.execInsert()
    end
    
    def near(res, name)
        puts "register.rb :::: got resp " + res;
        # id, name, alias
        
        json = JSON.parse(res)
        
        json.each do |x|
            return x[0] if name == x[0]
        end
        json.each do |x|
            return x[0] if name.downcase == x[2].downcase
        end
        json.each do |x|
            return x[0] if name.downcase == x[1].downcase
        end
        puts "didn't found #{name}"
        return "0"
    end
    
end

