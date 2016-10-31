module armos.audio.spectrumanalyzer;

import std.typecons:Tuple;
import armos.audio.spectrum;

/++
+/
enum BpmDetectionSource {
    Beats,
    // Tones
    Volumes, 
}//enum BpmDetectionSource

///
Tuple!(F, F) analyzeBpmAndPhase(F = double, T)(in T[] sample, in size_t samplingRate, in size_t bufferSize, in BpmDetectionSource sourceType)
in{
    assert(0<sample.length);
}
body{
    //Calc difference between current frame and previous one.
    F[] differedSample = new F[](sample.length);
    differedSample[0] = 0;
    for (int i = 1; i < sample.length; i++) {
        import std.algorithm:max;
        differedSample[i] = max(0.0, sample[i] - sample[i-1]);
    }
    
    //Calculate each frame spectrums.
    Spectrum!F[] spectrums = new Spectrum!F[](sample.length/bufferSize);
    for (int i = 0; i < sample.length/bufferSize; i++) {
        import std.stdio;
        import std.conv:to;
        writeln("analyzing... ", (i*bufferSize).to!F/sample.length.to!F*100f, "%");
        
        F[] bufferSizedsample = new F[](bufferSize*2);

        for (size_t j = 0; j < bufferSize*2; j++) {
            size_t k = 0;
            if(j + i*bufferSize < bufferSize*2){
                bufferSizedsample[j] = 0;
            }else{
                k = j + i*bufferSize - bufferSize*2;
                bufferSizedsample[j] = differedSample[k];
            }
        }
        
        spectrums[i] = analyzeSpectrum!F(bufferSizedsample, samplingRate);
    }
    
    //Select tone range by sourceType.
    auto filteredSample = new F[](sample.length/bufferSize); 
    switch (sourceType) {
        case BpmDetectionSource.Beats:
            foreach (size_t i, ref s; spectrums) {
                import std.algorithm:sum;
                filteredSample[i] = s.powers[0..$/108].sum;
                import std.math;
                assert(!isNaN(filteredSample[i]));
            }
            break;
            
        case BpmDetectionSource.Volumes:
            foreach (size_t i, ref s; spectrums) {
                import std.algorithm:sum;
                filteredSample[i] = s.powers[0..$].sum;
                import std.math;
                assert(!isNaN(filteredSample[i]));
            }
            break;
        default:
            assert(false);
    }
    
    auto bpmSpectrum = analyzeSpectrum!F(filteredSample, samplingRate/bufferSize);
    
    //filter by common bpm range.
    auto filteredSpectrum = Spectrum!F();
    {
        auto r = bpmSpectrum.frequencyRange.arrayRange!("60<=a*60", "a*60<=150");
        immutable first = r[0];
        immutable last= r[1]+1;
        filteredSpectrum.samplingRate = bpmSpectrum.samplingRate;
        filteredSpectrum.frequencyRange = bpmSpectrum.frequencyRange[first..last];
        filteredSpectrum.powers = bpmSpectrum.powers[first..last];
        filteredSpectrum.phases = bpmSpectrum.phases[first..last];
    }
    
    //Sort by power.
    import std.range:zip;
    import std.algorithm:sort;
    zip(filteredSpectrum.frequencyRange, filteredSpectrum.powers, filteredSpectrum.phases).sort!"a[1]>b[1]";
    
    //Set bpm.
    immutable resultBpm = filteredSpectrum.frequencyRange[0]*60.0;
    
    //Set phase.
    immutable theta = filteredSpectrum.phases[0];
    import std.math:PI;
    immutable resultPhase = ((theta<0.0)?theta+2.0*PI:theta)/(2.0*PI*filteredSpectrum.frequencyRange[0]);
    
    return Tuple!(F, F)(resultBpm, resultPhase);
}

///
Spectrum!R analyzeSpectrum(R, T)(in T[] sample, in size_t samplingRate)
in{
    import std.math:isNaN;
    import std.conv;
    foreach (size_t i, ref e; sample) {
        assert(!isNaN(e), i.to!string);
    }
}
out(spectrum){
    import std.math:isNaN;
    foreach (e; spectrum.powers) {
        assert(!isNaN(e));
    }
    foreach (e; spectrum.phases) {
        assert(!isNaN(e));
    }
    foreach (e; spectrum.frequencyRange) {
        assert(!isNaN(e));
    }
}
body{
    import std.numeric:fft;
    import std.range:iota;
    import std.algorithm:map, fill;
    import std.array:array;
    import std.conv:to;
    version(DigitalMars){
        import std.math:nextPow2;
    }
    
    auto fixedLengthSample = new T[](sample.length.nextPow2);
    if((sample.length-1).nextPow2 != sample.length){
        auto zeroSlice = new T[](sample.length.nextPow2 - sample.length);
        zeroSlice.fill(T(0));
        fixedLengthSample = zeroSlice ~ sample;
    }else{
        fixedLengthSample = sample.dup;
    }
    
    
    immutable windowLength = fixedLengthSample.length;
    immutable transformLength = windowLength;//TODO
    
    auto frequencyRange = transformLength.iota.map!(x=>x.to!float*(samplingRate.to!float/transformLength.to!float).to!R)[0..$/2].array;
    
    const fx = fft(fixedLengthSample)[0..$/2];

    Spectrum!R powerSpectrum;

    powerSpectrum.samplingRate = samplingRate;
    powerSpectrum.powers = fx.map!(x=>(x*typeof(x)(x.re, -x.im)).re/transformLength).array;
    import std.math:atan2;
    powerSpectrum.phases = fx.map!(x=>atan2(x.im, x.re)).array;
    powerSpectrum.frequencyRange = frequencyRange;
    return powerSpectrum;
}

private{
    version(LDC){
        size_t nextPow2(size_t val) pure nothrow @nogc @safe
        {
            size_t res = 1;
            while (res < val)
                res <<= 1;
            return res;
        }
    }
    
    import std.typecons:Tuple;
    Tuple!(size_t, size_t) arrayRange(string Cl, string Cu, T)(in T[] r){
        import std.algorithm:find, filter;
        import std.array:array;
        immutable first = r.length - r.find!(Cl).length;
        immutable last = r.filter!(Cu).array.length-1;
        return Tuple!(size_t, size_t)(first, last);
    }
}
