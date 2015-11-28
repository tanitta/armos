module armos.utils.fpscounter;
import core.time;
import core.thread;
class FpsCounter {
	private double targetFps_ = 60.0;
	private double currentFps = 60.0;
	private ulong  nFrameCount = 0;
	private int targetTime = 0;
	private MonoTime timer;
	double fpsUseRate = 0;
	this(double targetFps_ = 60){
		timer = MonoTime.currTime;
		this.targetFps_ = targetFps_;
		this.currentFps= targetFps_;
		targetTime = cast(int)(1.0/targetFps_*10000000);
	}
	
	void targetFps(double fps){
		targetFps_ = fps;
		targetTime = cast(int)(1.0/targetFps_*10000000);
	}

	double getTargetFps(){
		return targetFps_;
	}
	double getCurrentFps(){
		return currentFps;
	}

	void newFrame(){
		timer = MonoTime.currTime;
		nFrameCount++;
	}
	
	ulong getNumFrames(){return nFrameCount;};

	void adjust(){
		MonoTime after = MonoTime.currTime;
		auto def = ( after - timer );
		if( def.fracSec.hnsecs < targetTime){
			Thread.sleep( dur!("hnsecs")( targetTime - def.fracSec.hnsecs ) );
		}
		MonoTime after2 = MonoTime.currTime;
		auto def2 = after2 - timer;
		currentFps = 1.0/cast(double)(def2.fracSec.hnsecs)*10000000;
		fpsUseRate = cast(double)def.fracSec.hnsecs/cast(double)targetTime;
	}
}

