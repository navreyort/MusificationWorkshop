s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

s.waitForBoot({
	Routine {
		//Initialize variables and allocate synths
		SynthDef(\BuzzSynth, { | out=0, in=0 |
			var input, generated, freq, hasFreq, amp;
			
			//Get sound input
			input = SoundIn.ar(in,1);
			
			//Track amplitude and pitch
			amp = PeakFollower.kr(input,0.95).linlin(0,1,0,1);
			#freq, hasFreq = Pitch.kr(input, ampThreshold: 0.02, median: 7);
							
			//Synthesize sound
			generated = Blip.ar(freq*0.125+LFNoise1.ar(2000,add:freq))*amp;
								
			//Send to out
			Out.ar(out,generated);
		}).send(s);
	
		//Wait for synth allocation
		1.wait;
		
		//Execute synths
		s.sendMsg(\s_new, \BuzzSynth, s.nextNodeID, 3, 1, \out, 0, \in, 0);
	}.play;
});