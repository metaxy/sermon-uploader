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
    
    vbuf = RubyAudio::Buffer.double(($slice_size+1)*2)

    RubyAudio::Sound.open($video) do |snd|
        i = 0
        while snd.read(vbuf) != 0
            copy = vbuf.to_a
            i2 = 0
            while copy.size >= $slice_size 
                sl = copy.take($slice_size)

                fft_slice = FFTW3.fft(NArray.to_na(sl)).to_a[0, $slice_size/2]
                
                copy = copy.drop(1)
                i2 += 1
            end
            puts "iter #{i}"
            i += 1
        end
    end
end

main() 