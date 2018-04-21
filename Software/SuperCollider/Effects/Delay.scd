s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

~recDur = 1;

s.waitForBoot({
	Routine {
		{
			var signal;
			var delaytime = MouseX.kr(0.05, 2, 1); // between 50 ms and 2 seconds - exponential.
			signal = AudioIn.ar(1);
			
			// compare DelayL, CombL and AllpassL
			
			//d =  DelayL.ar(signal, 0.6, delaytime);
			//d = CombL.ar(signal, 0.6, delaytime, MouseY.kr(0.1, 10, 1)); // decay using mouseY
			d =  AllpassL.ar(signal, 0.6, delaytime, MouseY.kr(0.1,10, 1));
			
			(signal+d).dup
		}.play(s);
	}.play;
});