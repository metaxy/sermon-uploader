# encoding: utf-8
require 'ruby-audio'
require "fftw3"
require 'gnuplot'
#require 'gsl'
#mplayer yourmovie.mov -vo null -vc null -ao pcm:fast

# mp3 to wav
# ffmpeg -i 1.mp3  1.wav

#gen dat 
#sox out.wav -r30 out.dat 
$slice_size = 20000
$time = 2975;
$audio = 's_mono_2k.wav'
$video = 'b_mono_2k.wav'
def main
    audioSeq = nil
    audioSeq2 = nil

    sums_b = []
    sums_s = []
    pos_s = []
    pos_b = []
    vbuf = RubyAudio::Buffer.float($slice_size)

    RubyAudio::Sound.open($video) do |snd|
	l = snd.info.length * snd.info.samplerate
	i = 0;
        while snd.read(vbuf) != 0
	    sums_b << fft_s(vbuf)
	    pos_b << i;
	    puts "iter #{i/l}"
	    i += $slice_size
	end
    end
    RubyAudio::Sound.open($audio) do |snd|
	l = snd.info.length * snd.info.samplerate
	i = 0;
	while snd.read(vbuf) != 0
	    sums_s << fft_s(vbuf)
	    pos_s << (i + $time * snd.info.samplerate);
	    puts "iter #{i/l}"
	    i += $slice_size
	end
    end
  #  v1 = Vector[sums_b]
 #   v2 = Vector[sums_s]

 #   puts GSL::Stats::correlation(v1,v2)

    Gnuplot.open do |gp|
	Gnuplot::Plot.new( gp ) do |plot|
	    plot.title  "Array Plot Example"
	    plot.xlabel "x"
	    plot.ylabel "x^2"

	    plot.data << Gnuplot::DataSet.new( [pos_b,sums_b] ) do |ds|
		ds.with = "linespoints"
		ds.notitle
	    end
	     plot.data << Gnuplot::DataSet.new( [pos_s,sums_s]  ) do |ds|
		ds.with = "linespoints"
		ds.notitle
            end
        end
    end
end

def fft_s(vbuf)
    fft_slice = FFTW3.fft(NArray.to_na(vbuf.to_a)).to_a[0, $slice_size/2]
    fft_slice.map!{|x| x.abs}
    s = sum(fft_slice)
end

def sum(a)
    a.inject(:+)
end
main() 