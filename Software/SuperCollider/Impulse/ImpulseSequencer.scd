s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

s.waitForBoot({
	Routine {
		var numChan = 2;
		//Initialize variables and allocate synths
		SynthDef(\ImpulseSequencer, { | out=0, ampOut=0.2 |
			var env = EnvGen.kr(Env.perc(0.001,0.05), doneAction: 2);
			Out.ar(out,LFPulse.ar(0.01))*env*ampOut;
		}).send(s);
	
		//Wait for synth allocation
		1.wait;
		
		//Execute synths
		loop{ |i|
			s.sendMsg(\s_new, \ImpulseSequencer, s.nextNodeID, 3, 1, \out, 0, \ampOut, 1);
			//Or sequence it on different channels
			//s.sendMsg(\s_new, \ImpulseSequencer, s.nextNodeID, 3, 1, \out, i%numChan, \ampOut, 1);
			1.wait;
		}
	}.play;
});