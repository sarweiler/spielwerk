# spielwerk

spielwerk is a sequencer for monome norns + crow (arc optional) providing three independent euclidean rhythms and a CV, that is derived from these rhythms.

_it's a work in progress, so handle with care. there will be a thread in the lines library category when it has reached a release worthy state._

## norns

enc 1: navigate
enc 2: set pulses for active euclidean sequence
enc 3: set steps for active euclidean sequence
hold key 1 + enc 1: set bpm for active sequence

## crow

output 1: triggers for euclidean rhythm 1
output 2: triggers for euclidean rhythm 2
output 3: triggers for euclidean rhythm 3
output 4: cv sequence generated from the three euclidean rhythms

## arc

the rings display the euclidean sequences and the generated cv value on ring 4.

encoder: change bpm for sequence
norns key 2 + encoder: change pulses for euclidean sequence
norns key 3 + encoder: change steps for euclidean sequence

## ii

if you have a mannequins just friends connected to crow via ii, you can activate sequencing for just friends in the parameters menu.