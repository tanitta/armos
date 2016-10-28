module armos.audio.spectrum;

/++
+/
struct Spectrum(T){
    public{
        T   samplingRate;
        T[] powers;
        T[] frequencyRange;
        
        T power(in T frequency){
            //TODO
            return 0;
        }
    }//public

    private{
    }//private
}//struct Spectrum
