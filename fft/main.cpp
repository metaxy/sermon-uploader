#include <iostream>
#include <complex>

#include "lib/ooura/fft4g.c"

#include "aquila/transform/FftFactory.h"
#include "aquila/source/WaveFile.h"
#include "aquila/source/FramesCollection.h"

#include <gsl/gsl_vector.h>
#include <gsl/gsl_statistics.h>

#include "anyoption.h"

using namespace std;
std::vector<double> calcAmp(Aquila::FramesCollection frames)
{
    std::vector<double> ret;
    auto fft = Aquila::FftFactory::getFft(frames.getSamplesPerFrame());
    for (auto it = frames.begin(); it != frames.end(); ++it)
    {
        std::vector<Aquila::ComplexType> s = fft->fft(it->toArray());
        double sum = 0.0;
        for (auto it2 = s.begin(); it2 != s.end(); ++it2) {
            sum += abs(*it2);
        }
        ret.push_back(sum);
    }
    return ret;
}

int main(int argc, char *argv[])
{
    AnyOption *opt = new AnyOption();
   opt->addUsage("fft");
   opt->addUsage("Usage: ");
   opt->addUsage("");
   opt->addUsage(" -h  --help");
   opt->addUsage(" --main       The main wav file");
   opt->addUsage(" --cmp        Where should we search?");
   opt->addUsage("");

   opt->setFlag("help", 'h');
   opt->setOption("main");
   opt->setOption("cmp");

   opt->processCommandArgs(argc, argv);
   if(opt->getValue("help") != NULL || opt->getValue("main") == NULL || opt->getValue("cmp") == NULL) {
       opt->printUsage();
       return 0;
   }

    const unsigned int packetSize = 1024*4;
    // input signal parameters
    Aquila::WaveFile small("/home/paul/coding/sermon-uploader/s_mono_3k.wav");
    Aquila::FramesCollection s;
    s.divideFrames(small, packetSize, 0);

    Aquila::WaveFile big("/home/paul/coding/sermon-uploader/b_mono_3k.wav");
    Aquila::FramesCollection b;
    b.divideFrames(big, packetSize, 0);
    std::vector<double> small_amp = calcAmp(s);
    std::vector<double> big_amp = calcAmp(b);

    std::vector<double> res;

    int sizeDiff = b.count() - s.count();

    for(int i = 0; i < sizeDiff; i++) {
        gsl_vector_const_view gsl_x = gsl_vector_const_view_array( &small_amp[0], small_amp.size() );
        gsl_vector_const_view gsl_y = gsl_vector_const_view_array( &big_amp[i], small_amp.size() );

        double pearson = gsl_stats_correlation( (double*) gsl_x.vector.data, sizeof(double),
                                                (double*) gsl_y.vector.data, sizeof(double),
                                                200 );
        res.push_back(pearson);
    }

    vector<double>::iterator pos = std::max_element(res.begin(), res.end());

    cout << "max: " << *pos << endl;

    int start_index = std::distance(res.begin(), pos);
    double bc = b.count();
    double lc = start_index;
    double len = big.getAudioLength();
    cout << "secs: " << (len/1000) * (lc/bc);

    return 0;
}

