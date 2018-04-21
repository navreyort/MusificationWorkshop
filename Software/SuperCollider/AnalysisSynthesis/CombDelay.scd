s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

s.waitForBoot({
	Routine {
		//Initialize variables and allocate synths
		SynthDef(\CombDelay, { | out=0, in=0 |
			var input, generated, freq, hasFreq, amp;
			
			//Get sound input
			input = SoundIn.ar(in,1);
			
			//Track amplitude and pitch
			amp = PeakFollower.kr(input,0.999).linlin(0,1,0,1);
			#freq, hasFreq = Pitch.kr(input, ampThreshold: 0.02, median: 7);
							
			//Synthesize sound
			generated = CombN.ar(input, 2, LFNoise1.kr(LFNoise1.kr(2,1,4),0.5,1));
			
			generated = (generated + input)*amp;	
			5.do({
Ê Ê Ê Ê 			generated = AllpassN.ar(generated, 0.01, 0.01.rand, 2);
Ê Ê 			});

			//Send to out
			Out.ar(out,generated);
		}).send(s);
	
		//Wait for synth allocation
		1.wait;
		
		//Execute synths
		s.sendMsg(\s_new, \CombDelay, s.nextNodeID, 3, 1, \out, 0, \in, 0);
	}.play;
});