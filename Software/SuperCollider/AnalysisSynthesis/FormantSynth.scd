s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

s.waitForBoot({
	Routine {
		//Initialize variables and allocate synths
		SynthDef(\FormantSynth, { | out=0, in=0 |
			var input, generated, freq, hasFreq, amp, fft;
			var x, y, env, delayTime = 2, clk, moreProcess;
		
			//Get sound input
			input = SoundIn.ar(in,1);

			//Track amplitude and pitch
			amp = PeakFollower.kr(input,0.95).linlin(0,1,0,1);
			#freq, hasFreq = Pitch.kr(input, ampThreshold: 0.02, median: 7);
	
			//Further Analsys with FFT
			fft = FFT(LocalBuf(2048),input);
			
			//Synthesize sound
			generated = Formant.ar(freq*0.125, SpecCentroid.kr(fft)*0.1,freq+200)*amp;
	
			6.do({
Ê Ê Ê Ê 		generated = AllpassN.ar(generated, 0.010, [0.010.rand,0.010.rand], 1);
Ê Ê 		});

			//Send to out
			Out.ar(out,generated);
		}).send(s);

		//Wait for synth allocation
		1.wait;
		
		//Execute synths
		s.sendMsg(\s_new, \FormantSynth, s.nextNodeID, 3, 1, \out, 0, \in, 0);
	}.play;
});