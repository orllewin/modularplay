function round(number, decimalPlaces)
		local mult = 10^(decimalPlaces or 0)
		return math.floor(number * mult + 0.5)/mult
end

function map(value, start1, stop1, start2, stop2)
	return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1))
end