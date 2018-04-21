MIDIIn.connectAll;

s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

s.waitForBoot({
	Routine {
		//Initialize variables and allocate synths
		SynthDef(\BuzzSynth, { | out=0, in=0, multFreq=0.125, addFreq=2000, gate=0, attack=1, release=1 |
			var input, generated, freq, hasFreq, amp;

			//Get sound input
			input = SoundIn.ar(in,1);

			//Track amplitude and pitch
			amp = PeakFollower.kr(input,0.95).linlin(0,1,0,1);
			#freq, hasFreq = Pitch.kr(input, ampThreshold: 0.02, median: 7);

			//Synthesize sound
			generated = Blip.ar(freq*multFreq+LFNoise1.ar(addFreq,add:freq),addFreq*10)*amp;

			generated = (generated + input)*amp;
			5.do({
				generated = AllpassN.ar(generated, 0.01, 0.01.rand, 2);
 			});
 			
			generated = generated * Linen.kr(gate,attack,1,release,doneAction:0);
			//Send to out
			Out.ar(out,[generated,generated]);
		}).send(s);


		SynthDef(\CombDelay, { | out=0, in=0, multFreq=2, addFreq=4, gate=0, attack=1, release=1 |
			var input, generated, freq, hasFreq, amp;

			//Get sound input
			input = SoundIn.ar(in,1);

			//Track amplitude and pitch
			amp = PeakFollower.kr(input,0.999).linlin(0,1,0,1);
			#freq, hasFreq = Pitch.kr(input, ampThreshold: 0.02, median: 7);

			//Synthesize sound
			generated = CombN.ar(input, 2, LFNoise1.kr(LFNoise1.kr(multFreq,1,addFreq),0.5,1));

			generated = (generated + input)*amp;
			5.do({
				generated = AllpassN.ar(generated, 0.01, 0.01.rand, 2);
 			});

			generated = generated * Linen.kr(gate, attack,1,release,doneAction:0);

			//Send to out
			Out.ar(out,[generated,generated]);
		}).send(s);

		SynthDef(\FormantSynth, { | out=0, in=0, multFreq=0.125, bwFreq=200, gate=0, attack=1, release=1 |
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
			generated = Formant.ar(freq*0.125, SpecCentroid.kr(fft)*0.1,freq+bwFreq)*amp;

			6.do({
				generated = AllpassN.ar(generated, 0.010, [0.010.rand,0.010.rand], 1);
			});

			generated = generated * Linen.kr(gate,attack,1,release,doneAction:0);

			//Send to out
			Out.ar(out,[generated,generated]);
		}).send(s);


		SynthDef(\PitchVarSaw, { | out=0, in=0, mulFreq=1, width=0.1, gate=0, attack=1, release=1 |
			var input, generated, freq, hasFreq, amp;

			//Get sound input
			input = SoundIn.ar(in,1);

			//Track amplitude and pitch
			amp = PeakFollower.kr(input).linlin(0,1,0,1);
			#freq, hasFreq = Pitch.kr(input, ampThreshold: 0.02, median: 7);

			//Synthesize sound
			generated = VarSaw.ar(freq*mulFreq, 0, LFNoise1.kr(0.3,0.1,width), amp);

			6.do({
				generated = AllpassN.ar(generated, 0.040, [0.040.rand,0.040.rand], 2);
			});

			generated = generated * Linen.kr(gate,attack,1,release,doneAction:0);

			//Send to out
			Out.ar(out,[generated,generated]);
		}).send(s);

		//Wait for synth allocation
		1.wait;

		//Execute synths
		~buzz = Synth(\BuzzSynth);
		~comb = Synth(\CombDelay);
		~formant = Synth(\FormantSynth);
		~saw = Synth(\PitchVarSaw);

		//MIDI mapping
		~control = { | src, chan, num, val |
			["Control", src, chan, num, val].postln;
			switch(num,
				1, {
					~buzz.set("multFreq", 1.0/val.linlin(0, 127, 0.125, 2));
				},
				2, {
					~comb.set("multFreq", val.linlin(0, 127, 0.1, 4));
				},
				3, {
					~formant.set("multFreq", 1.0/val.linlin(0, 127, 1, 20));
				},
				4, {
					~saw.set("multFreq", 1.0/val.linlin(0, 127, 1, 20));
				},
				5, {
					~buzz.set("addFreq", val.linlin(0, 127, 0.1, 20));
				},
				6, {
					~comb.set("addFreq", val.linlin(0, 127, 0.1, 8));
				},
				7, {
					~formant.set("bwFreq", val.linlin(0, 127, 200, 2000));
				},
				8, {
					~saw.set("width", 1.0/val.linlin(0, 127, 0.1, 0.4));
				}
			);
		};
		MIDIIn.addFuncTo(\control,~control);
    		~program = { | src, chan, val |
	    		["Program", src, chan, val].postln;
	    		switch(val,
				0, {
					~buzz.set("gate", 1);
				},
				1, {
					~comb.set("gate", 1);
				},
				2, {
					~formant.set("gate", 1);
				},
				3, {
					~saw.set("gate", 1);
				},
				4, {
					~buzz.set("gate", 0);
					"stop".postln;
				},
				5, {
					~comb.set("gate", 0);
				},
				6, {
					~formant.set("gate", 0);
				},
				7, {
					~saw.set("gate", 0);
				},
			);
    		};
    		MIDIIn.addFuncTo(\program,~program);
	}.play;
});