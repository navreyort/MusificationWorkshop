s = Server.local.boot;
o = Server.local.options;
o.memSize_(32768);

~recDur = 1;

s.waitForBoot({
	Routine {
		
		SynthDef(\Distortion,{ | out=0, in=1 |
			var input = AudioIn.ar(in);
			var gain = MouseX.kr(1,100);
			input=input.abs;
			Out.ar(out, Pan2.ar(((input.squared + (gain*input))/(input.squared + ((gain-1)*input) + 1))));
		}).send(s);
		
		1.wait;
		
		Synth(\Distortion);
		
	}.play;
});