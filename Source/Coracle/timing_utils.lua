function bpmTo1_4Ms(bpm)
	return 60000/bpm
end

function bpmTo1_16Ms(bpm)
	return 60000/(bpm*2)
end

function bpmTo1_32Ms(bpm)
	return 60000/(bpm*4)
end

function bpmTo1_64Ms(bpm)
	return 60000/(bpm*8)
end

function msToBPM(ms)
 return 60000/ms
end