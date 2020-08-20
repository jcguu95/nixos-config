$1>=InitDate && $1<=EndDate {
	entry[$2] = entry[$2] "\n" $0		# sort the current row to entry[$2]
	total[$2] = total[$2] + $3		# add the money of the current row to total[$2]
	entry["ALL"] = entry["ALL"] "\n" $0	# sort the current row to entry["ALL"]
	total["ALL"] = total["ALL"] + $3	# add the money of the current row to ALL
}

END {
	# Standard Output the broken-down budget
	printf("\n\tBudget Breakdown\n\n")
	for (tag in entry) {
		printf("\t%-8s%6.2f\n", tag, total[tag])
	}
	printf("\n")

	#  Generate temporary files "tmp.*.csv"
	## Output sorted files (ALL/Food/Transpotation/Housing/Other/investment/salary/duplicate/?)
	for (tag in entry) {
		print "Total of," tag "," total[tag] ",from," InitDate ",to," EndDate entry[tag] "\n" > "tmp."InputFile"."tag"."InitDate"--"EndDate".csv"
	}
}
