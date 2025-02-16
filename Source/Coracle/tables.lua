function tableConcat(table1,table2)
		for i=1,#table2 do
				table1[#table1+1] = table2[i]
		end
		return table1
end
