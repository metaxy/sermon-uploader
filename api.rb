# encoding: utf-8
require 'date'
require 'net/http'
require 'json'
require 'taglib'

$book_de = Hash[0 => ['1Mo','1.Mose'],
1 => ['2Mo','2.Mose'],
2 => ['3Mo','3.Mose'],
3 => ['4Mo','4.Mose'],
4 => ['5Mo','5.Mose'],
5 => ['Jos','Josua'],
6 => ['Ri','Richter'],
7 => ['Ru','Rut'],
8 => ['1Sam','1.Samuel'],
9 => ['2Sam','2.Samuel'],
10 => ['1Kön','1.Könige'],
11 => ['2Kön','2.Könige'],
12 => ['1Chr','1.Chronik'],
13 => ['2Chr','2.Chronik'],
14 => ['Esra','Esr'],
15 => ['Nehemia','Ne'],
16 => ['Ester','Es'],
17 => ['Hiob','Hi'],
18 => ['Ps', 'Psalmen'],
19 => ['Spr', 'Sprüche'],
20 => ['Pred', 'Prediger'],
21 => ['Hohelied','Hoh'],
22 => ['Jes', 'Jesaja'],
23 => ['Jer', 'Jeremia'],
24 => ['Kla', 'Klagelieder'],
25 => ['Hes','Hesekiel'],
26 => ['Dan', 'Daniel'],
27 => ['Hosea','Hos'],
28 => ['Joel','Joe'],
29 => ['Amos','Am'],
30 => ['Obadja','Ob'],
31 => ['Jona','Jon'],
32 => ['Micha','Mic'],
33 => ['Nahum','Na'],
34 => ['Habakuk','Hab'],
35 => ['Zefanja','Zef'],
36 => ['Haggai','Hag'],
37 => ['Sacharja','Sac'],
38 => ['Mal', 'Maleachi'],
39 => ['Mt', 'Matthäus'],
40 => ['Mk', 'Markus'],
41 => ['Lk', 'Lukas'],
42 => ['Joh', 'Johannes'],
43 => ['Apg', 'Apostelgeschichte'],
44 => ['Röm', 'Römer'],
45 => ['1Kor', '1.Korinther'],
46 => ['2Kor', '2.Korinther'],
47 => ['Gal', 'Galater'],
48 => ['Eph', 'Epheser'],
49 => ['Phil', 'Philipper'],
50 => ['Kol', 'Kolosser'],
51 => ['1Th','1.Thessalonicher', '1Thess'],
52 => ['2Th', '2.Thessalonicher', '2Thess'],
53 => ['1Tim', '1.Timotheus'],
54 => ['2Tim', '2.Timotheus'],
55 => ['Tit', 'Titus'],
56 => ['Philemon','Phm'],
57 => ['Heb', 'Hebräer'],
58 => ['Jak', 'Jakobus'],
59 => ['1Petr', '1.Petrus'],
60 => ['2Petr', '2.Petrus'],
61 => ['1Joh', '1.Johannes'],
62 => ['2Joh', '2.Johannes'],
63 => ['3Joh', '3.Johannes'],
64 => ['Jud', 'Judas'],
65 => ['Offb', 'Offenbarung']]

$book_ru = Hash[0 => ['1Mo','Бытие'],
1 => ['Исход'],
2 => ['Левит'],
3 => ['Числа'],
4 => ['Второзаконие'],
5 => ['Иисус Навин'],
6 => ['Книга Судей'],
7 => ['Руфь'],
8 => ['1-я Царств'],
9 => ['2-я Царств'],
10 => ['3-я Царств'],
11 => ['4-я Царств'],
12 => ['1-я Паралипоменон'],
13 => ['2-я Паралипоменон'],
14 => ['Ездра'],
15 => ['Неемия'],
16 => ['Есфирь'],
17 => ['Иов'],
18 => ['Псалтирь'],
19 => ['Притчи'],
20 => ['Екклесиаст'],
21 => ['Песни Песней'],
22 => ['Исаия'],
23 => ['Иеремия'],
24 => ['Плач Иеремии'],
25 => ['Иезекииль'],
26 => ['Даниил'],
27 => ['Осия'],
28 => ['Иоиль'],
29 => ['Амос'],
30 => ['Авдия'],
31 => ['Иона'],
32 => ['Михей'],
33 => ['Наум'],
34 => ['Аввакум'],
35 => ['Софония'],
36 => ['Аггей'],
37 => ['Захария'],
38 => ['Малахия'],
39 => ['От Матфея'],
40 => ['От Марка'],
41 => ['От Луки'],
42 => ['От Иоанна'],
43 => ['Деяния'],
44 => ['К Римлянам'],
45 => ['1-е Коринфянам'],
46 => ['2-е Коринфянам'],
47 => ['К Галатам'],
48 => ['К Ефесянам'],
49 => ['К Филиппийцам'],
50 => ['К Колоссянам'],
51 => ['1-е Фессалоникийцам'],
52 => ['2-е Фессалоникийцам'],
53 => ['1-е Тимофею'],
54 => ['2-е Тимофею'],
55 => ['К Титу'],
56 => ['К Филимону'],
57 => ['К Евреям'],
58 => ['Иакова'],
59 => ['1-e Петра'],
60 => ['2-e Петра'],
61 => ['1-e Иоанна'],
62 => ['2-e Иоанна'],
63 => ['3-e Иоанна'],
64 => ['Иуда'],
65 => ['Откровение']]

$books = Hash[
    "de-DE" => $book_de.dup,
    "ru-RU" => $book_ru.dup,
    "de-DE,ru-RU" => $book_de.dup,
    "ru-RU,en-GB" => $book_ru.dup,
    "de-DE,en-GB" => $book_de.dup,
    "ru-RU,de-DE" => $book_ru.dup]

$ref_type4 = /(\p{Word}+)\s(\d+)-(\d+)/
$ref_type3 = /(\p{Word}+)\s(\d+)\,(\d+)-(\d+)\,(\d+)/
$ref_type2 = /(\p{Word}+)\s(\d+)\,(\d+)-(\d+)/
$ref_type1 = /(\p{Word}+)\s(\d+)\,(\d+)/
$ref_type0 = /(\p{Word}+)\s(\d+)/
# (\p{Word}+) == (\w+); only for unicode
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
    exit
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
        #puts json
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
    def near(res, name)
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
        puts "Api::near didn't found #{name}"
        return "0"
    end
    # for ui
    def getBookNames
        a = []
        $books[$defLoc].each do |i,j|
            j.each do |m|
                a << m
            end
        end
        return a 
    end
    # bookname to book id
    def bookID(bookName)
        $books[$defLoc].each do |i,n|
            n.each do |m|
                return (i+1) if(bookName == m)
            end       
        end
        puts "Api::bookID didn't found #{bookName} in books"
        return nil
    end

    def getBookName(i, lang=$defLoc)
        puts "Api::getBookName [#{lang}][#{bookID(i)}][0]";
        $books[lang][bookID(i)-1][0]
    end
    
    def hasRef?(ref)
        return false if ref == nil
        return false if ref == ""
        if($ref_type4  =~ ref)
            y = ref.scan($ref_type4 )  
            x = y[0]
            return true if bookID(x[0]) != nil
        end
        if($ref_type3  =~ ref)
            y = ref.scan($ref_type3 )  
            x = y[0]
            return true if bookID(x[0]) != nil
        end
        
        if($ref_type2  =~ ref)
            y = ref.scan($ref_type2 )   
            x = y[0]
            return true if bookID(x[0]) != nil
        end
        
        if($ref_type1 =~ ref)
            y = ref.scan($ref_type1 ) # BookName 1,1
            x = y[0]
            return true if bookID(x[0]) != nil
        end
        if($ref_type0 =~ ref)
            y = ref.scan($ref_type0 ) # BookName 1,1
            x = y[0]
            return true if bookID(x[0]) != nil
        end
        return false
    end
    def refToJson(ref)
        if($ref_type4  =~ ref) # BookName 1-2
            puts "type 4";
            y = ref.scan($ref_type4 )  
            x = y[0]
            return Hash['book' => bookID(x[0]),
                    'cap1' => x[1],
                    'vers1' => '0',
                    'cap2' => x[2],
                    'vers2' => '0'
                    ].to_json.to_s
        end
        if($ref_type3  =~ ref) # BookName 1,1-2,12
            puts "type 3";
            y = ref.scan($ref_type3 )  
            x = y[0]
            return Hash['book' => bookID(x[0]),
                    'cap1' => x[1],
                    'vers1' => x[2],
                    'cap2' => x[3],
                    'vers2' => x[4]
                    ].to_json.to_s
        end
        
        if($ref_type2  =~ ref) # BookName 1,1-12
            puts "type 2";
            y = ref.scan($ref_type2 )   
            x = y[0]
            return Hash['book' => bookID(x[0]), 
                    'cap1' => x[1],
                    'vers1' => x[2],
                    'cap2' => '0',
                    'vers2' => x[3]
                    ].to_json.to_s
        end
        
        if($ref_type1 =~ ref)
            puts "type 1"
            y = ref.scan($ref_type1 ) # BookName 1,1
            x = y[0]
            return Hash['book' => bookID(x[0]),
                        'cap1' => x[1],
                        'vers1' => x[2],
                        'cap2' => '0',
                        'vers2' => '0'
                    ].to_json.to_s
        end
        if($ref_type0 =~ ref)
            puts "type 0"
            y = ref.scan($ref_type0 ) # BookName 1,1
            x = y[0]
            return Hash['book' => bookID(x[0]),
                        'cap1' => x[1],
                        'vers1' => '0',
                        'cap2' => '0',
                        'vers2' => '0'
                    ].to_json.to_s
        end
        return nil
    end
    def normalizeRef(ref, lang=$defLoc)
        if($ref_type4  =~ ref) # BookName 1,1-2,12
            y = ref.scan($ref_type4 )  
            x = y[0]
            return "#{getBookName(x[0],lang)} #{x[1]}-#{x[2]}"
        end
        if($ref_type3  =~ ref) # BookName 1,1-2,12
            y = ref.scan($ref_type3 )  
            x = y[0]
            return "#{getBookName(x[0],lang)} #{x[1]},#{x[2]}-#{x[3]},#{x[4]}"
        end
        
        if($ref_type2  =~ ref) # BookName 1,1-12
            y = ref.scan($ref_type2 )   
            x = y[0]
            return "#{getBookName(x[0],lang)} #{x[1]},#{x[2]}-#{x[3]}"
        end
        
        if($ref_type1 =~ ref)
            y = ref.scan($ref_type1 ) # BookName 1,1
            x = y[0]
            return "#{getBookName(x[0],lang)} #{x[1]},#{x[2]}"
        end
        if($ref_type0 =~ ref)
            y = ref.scan($ref_type0 ) # BookName 1
            x = y[0]
            return "#{getBookName(x[0],lang)} #{x[1]}"
        end
        return ""
    end
    
    def writeid3_mp3(file)
        begin
            frame_factory = TagLib::ID3v2::FrameFactory.instance
            frame_factory.default_text_encoding = TagLib::String::UTF8
            TagLib::MPEG::File.open file do |file|
                tag = file.id3v2_tag
                tag.album = $options[:serie]
                tag.year = Date.parse($options[:date]).year
                tag.comment = "Aufnahme der ECG Berlin http://ecg-berlin.de"
                tag.artist = $options[:preacher]
                if hasRef? $options[:ref]
                    tag.title  = "#{normalizeRef($options[:ref], $options[:lang])} #{$options[:title]}"
                else
                    tag.title = $options[:title]
                end
                file.save
            end
        rescue
        end
    end
    def writemeta_mp4(file)
        begin
            frame_factory = TagLib::MP4::FrameFactory.instance
            frame_factory.default_text_encoding = TagLib::String::UTF8
            TagLib::MP4::File.open file do |file|
                tag = file.tag
                tag.setAlbum($options[:serie]);
                tag.setYear(Date.parse($options[:date]).year);
                tag.setComment("Aufnahme der ECG Berlin http://ecg-berlin.de");
                tag.setArtist($options[:preacher])
                if hasRef? $options[:ref]
                    tag.setTitle("#{normalizeRef($options[:ref], $options[:lang])} #{$options[:title]}")
                else
                    tag.setTitle($options[:title])
                end
                
                file.save
            end
        rescue
        end
    end
    def rename(old)
        newName = old
        cat = $catNames[$options[:cat]]
        
        ref = ""
        if hasRef?($options[:ref]) 
            ref = normalizeRef($options[:ref], $options[:lang]) + " "
        end
        if(File.extname(old).downcase == ".mp3" || File.extname(old).downcase == ".ogg" || File.extname(old).downcase == ".mp4")
            newName = File.dirname(old) + 
                    "/#{$options[:date]} #{clean_ref(ref)}#{clean_ansi($options[:title])} (#{clean_ansi($options[:preacher])})" + 
                    File.extname(old).downcase
        else
            newName = File.dirname(old) + "/" + clean(File.basename(old))
        end
        File.rename(old, newName)
        return newName
    end
    def do_meta
        puts "metadata.rb do_meta()";

        newNames = []
        $options[:files].each do |x|
            puts "api.rb do_meta :::: processing filename = " + x
                
            newName = rename(x)
            writeid3_mp3(newName) if File.extname(newName).downcase == ".mp3" 
            writemeta_mp4(newName) if File.extname(newName).downcase == ".mp4" 
            newNames << newName
        end
        return newNames
    end

    def remotePath(local)
        ext = File.extname(local)
        cat = $paths[$options[:cat]]
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
        
        year = Date.parse($options[:date]).year.to_s
        
        return "#{cat}/#{type}/#{year}"
    end

    def upload(file)
        full = remotePath(file) + "/" + File.basename(file)
        puts "api.rb upload :::: Uploading";
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

end

