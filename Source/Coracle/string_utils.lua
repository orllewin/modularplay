function startswith(str, start)
	 return str:sub(1, #start) == start
end

function dropFirst(str)
	return str:sub(2)
end

function endswith(s, ending)
		return ending == "" or s:sub(-#ending) == ending
end

function replace(s, old, new)
		local search_start_idx = 1

		while true do
				local start_idx, end_idx = s:find(old, search_start_idx, true)
				if (not start_idx) then
						break
				end

				local postfix = s:sub(end_idx + 1)
				s = s:sub(1, (start_idx - 1)) .. new .. postfix

				search_start_idx = -1 * postfix:len()
		end

		return s
end

function leftPad(number)
	return string.format("%02d", number)
end