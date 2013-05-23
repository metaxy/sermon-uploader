# encoding: utf-8
require 'ruby-audio'
require "fftw3"
#mplayer yourmovie.mov -vo null -vc null -ao pcm:fast

# mp3 to wav
# ffmpeg -i 1.mp3  1.wav

#gen dat 
#sox out.wav -r30 out.dat 
$slice_size = 30
$time = 2975;
$audio = 'out.wav'
$video = 'out2.wav'
def main
    audioSeq = nil
    audioSeq2 = nil
    fft_2 = Array.new($slice_size/2,[])
    fft_1 = Array.new($slice_size/2,[])
    RubyAudio::Sound.open($audio) do |snd|
        snd.read(:double, 400)
        audioSeq = snd.read(:double, $slice_size)
        audioSeq2 = snd.read(:double, $slice_size)

        fft_slice = FFTW3.fft(NArray.to_na(audioSeq.to_a)).to_a[0, $slice_size/2]
        j=0
        fft_slice.each { |x| fft_1[j] << x; j+=1 }
                

        fft_slice = FFTW3.fft(NArray.to_na(audioSeq2.to_a)).to_a[0, $slice_size/2]
        j=0
        fft_slice.each { |x| fft_2[j] << x; j+=1 }
    end
    
    vbuf = RubyAudio::Buffer.double(($slice_size+1)*2)
    wave = Array.new
    puts fft_1
    RubyAudio::Sound.open($video) do |snd|
        i = 0
        while snd.read(vbuf) != 0
            copy = vbuf.to_a
            i2 = 0
            while copy.size >= $slice_size 
                sl = copy.take($slice_size)
                
                fft = Array.new($slice_size/2,[])
                fft_slice = FFTW3.fft(NArray.to_na(sl)).to_a[0, $slice_size/2]
                j=0
                fft_slice.each { |x| fft[j] << x; j+=1 }
                
                copy = copy.drop(1)
                i2 += 1
            end
            puts "iter #{i}"
            i += 1
        end
    end
end
def fft_(x)
   
end
def sum(x)
    ret = 0
    x.each {|y| ret += y[0].abs}
    return ret
end

def suma(x)
    x.inject{|sum,x| sum + x.abs }
end

def diff(x,y)
    x.each {|x| puts x}
    #x.zip(y).map {|a,b| a + b }
end

def contains(input,seek)
end
def te
    RubyAudio::Sound.open($audio) do |snd|
        audioSeq = snd.read(:double, $slice_size)
        audioSeq2 = snd.read(:double, $slice_size)
        sum1 = sum(audioSeq)
        puts sum1
    end
    
end

main() 