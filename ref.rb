#encoding: utf-8

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
18 => ['Ps', 'Psalm'],
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
    "de" => $book_de.dup,
    "ru" => $book_ru.dup]

$ref_type4 = /(\p{Word}+)\s(\d+)-(\d+)/
$ref_type3 = /(\p{Word}+)\s(\d+)\,(\d+)-(\d+)\,(\d+)/
$ref_type2 = /(\p{Word}+)\s(\d+)\,(\d+)-(\d+)/
$ref_type1 = /(\p{Word}+)\s(\d+)\,(\d+)/
$ref_type0 = /(\p{Word}+)\s(\d+)/
# (\p{Word}+) == (\w+); only for unicode

def get_book_names
    ret = []
    $books[$options[:locale]].each do |id,book_names|
        book_names.each do |book_name|
            ret << book_name
        end
    end
    return ret 
end
# bookname to book id

def book_id(name)
    $books[$options[:locale]].each do |id,book_names|
        book_names.each do |book_name|
            if(name == book_name)
                return id + 1
            end
        end       
    end
    #puts "Api::book_id didn't found #{bookName} in books"
    return nil
end

def get_book_name(book_name, lang=[$options[:locale]])
    puts "Api::get_book_name [#{lang.first}][#{book_id(book_name)}][0]";
    $books[lang.first][book_id(book_name)-1][0]
end

def has_valid_book?(matches)
    return false if matches.nil?
    return true if not book_id(matches[0]).nil?
end

def get_matches(reg, ref)
    if(reg =~ ref)
        return ref.scan(reg)[0]
    else
        return nil
    end
end

def is_valid?(reg, ref)
    matches = get_matches(reg, ref)
    return has_valid_book?(matches)
end
def is_valid_refs?(refs)
    return false if ref.nil?
    return false if ref == ""
    
    refs.each do |x|
        return false if not is_valid_ref?(x.strip)
    end
    
    return true
end
def is_valid_ref?(ref)
    return true if is_valid?($ref_type4, ref)
    return true if is_valid?($ref_type3, ref)
    return true if is_valid?($ref_type2, ref)
    return true if is_valid?($ref_type1, ref)
    return true if is_valid?($ref_type0, ref)
   
    return false
end
def create_hash(book, cap_1, vers_1, cap_2, vers_2, ref)
      return Hash['sermonsScriptureBook' => book.to_i,
                'sermonsScriptureChapter1' => cap_1.to_i,
                'sermonsScriptureVerse1' => vers_1.to_i,
                'sermonsScriptureChapter2' => cap_2.to_i,
                'sermonsScriptureVerse2' => vers_2.to_i,
                'sermonsScriptureText' => ref 
                ]
    
end
def ref_data(ref)
    t4 = get_matches($ref_type4, ref)
    t3 = get_matches($ref_type3, ref)
    t2 = get_matches($ref_type2, ref)
    t1 = get_matches($ref_type1, ref)
    t0 = get_matches($ref_type0, ref)
    if(not t4.nil?)
        return create_hash(book_id(t4[0]),
                           t4[1],
                           '0',
                           t4[2],
                           '0',ref)
    end
    if(not t3.nil?)
        return create_hash(book_id(t3[0]),
                           t3[1],
                           t3[2],
                           t3[3],
                           t3[4],ref)
    end
    if(not t2.nil?)
        return create_hash(book_id(t2[0]),
                           t2[1],
                           t2[2],
                           '0',
                           t2[3],ref)
    end
    if(not t1.nil?)
        return create_hash(book_id(t1[0]),
                           t1[1],
                           t1[2],
                           '0',
                           '0',ref)
    end
    if(not t0.nil?)
        return create_hash(book_id(t0[0]),
                           t0[1],
                           '0',
                           '0',
                           '0',ref)
    end
    return nil
end
def refs_data(ref)
    ref.split(";").map! {|x| ref_data(x.strip)}
end

def refs_normalize(ref, lang=$options[:locale])
    ref.split(";").map! {|x| ref_normalize(x.strip,lang)}.join("; ")
end

def ref_normalize(ref, lang)
    if($ref_type4  =~ ref) # BookName 1,1-2,12
        y = ref.scan($ref_type4 )  
        x = y[0]
        return "#{get_book_name(x[0],lang)} #{x[1]}-#{x[2]}"
    end
    if($ref_type3  =~ ref) # BookName 1,1-2,12
        y = ref.scan($ref_type3 )  
        x = y[0]
        return "#{get_book_name(x[0],lang)} #{x[1]},#{x[2]}-#{x[3]},#{x[4]}"
    end
    
    if($ref_type2  =~ ref) # BookName 1,1-12
        y = ref.scan($ref_type2 )   
        x = y[0]
        return "#{get_book_name(x[0],lang)} #{x[1]},#{x[2]}-#{x[3]}"
    end
    
    if($ref_type1 =~ ref)
        y = ref.scan($ref_type1 ) # BookName 1,1
        x = y[0]
        return "#{get_book_name(x[0],lang)} #{x[1]},#{x[2]}"
    end
    if($ref_type0 =~ ref)
        y = ref.scan($ref_type0 ) # BookName 1
        x = y[0]
        return "#{get_book_name(x[0],lang)} #{x[1]}"
    end
    return ""
end
