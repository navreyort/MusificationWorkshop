s = Server.local.boot;
o = Server.local.options;
o.memSize_(32768);

~recDur = 1;

s.waitForBoot({
	Routine {
		
		SynthDef(\Chorus, { arg inbus=10, outbus=0, predelay=0.08, speed=0.05, depth=0.1, ph_diff=0.5;
			var in, sig, modulators, numDelays = 12;
			in = In.ar(inbus, 1);
			modulators = Array.fill(numDelays, {arg i;
		      	LFPar.kr(speed * rrand(0.94, 1.06), ph_diff * i, depth, predelay);}); 
			sig = DelayC.ar(in, 0.5, modulators);  
			sig = sig.sum; //Mix(sig); 
			Out.ar(outbus, sig!2); // output in stereo
		}).send(s);
		
		1.wait;
		
		{Out.ar(10, AudioIn.ar(1))}.play(s, addAction:\addToHead);
		c = Synth(\Chorus, addAction:\addToTail)
		
	}.play;
});

//c.set(\predelay, 0.02);
//c.set(\speed, 0.22);
//c.set(\depth, 0.5);
//c.set(\pd_diff, 0.7);
//c.set(\predelay, 0.2);