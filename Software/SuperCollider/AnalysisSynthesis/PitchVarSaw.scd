s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

s.waitForBoot({
	Routine {
		//Initialize variables and allocate synths
		SynthDef(\PitchVarSaw, { | out=0, in=0, mulFreq=1 |
			var input, generated, freq, hasFreq, amp;
	
			//Get sound input
			input = SoundIn.ar(in,1);
	
			//Track amplitude and pitch
			amp = PeakFollower.kr(input).linlin(0,1,0,1);
			#freq, hasFreq = Pitch.kr(input, ampThreshold: 0.02, median: 7);
	
			//Synthesize sound
			generated = VarSaw.ar(freq*mulFreq, 0, LFNoise1.kr(0.3,0.1,0.1), amp);

			6.do({
Ê Ê Ê Ê 			generated = AllpassN.ar(generated, 0.040, [0.040.rand,0.040.rand], 2);
Ê Ê 			});
		
			//Send to out
			Out.ar(out,generated);
		}).send(s);
		
		1.wait;
		//Execute synths
		s.sendMsg(\s_new, \PitchVarSaw, s.nextNodeID, 3, 1, \out, 0, \in, 0);
	}.play;
});