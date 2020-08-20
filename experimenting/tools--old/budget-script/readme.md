Execute the following to analyze a budget.csv file for year 2018.

$ budget.sh file.csv --options

The script will read the time span right after this.





Options:
+ -d (Detail Mode. Parameters: DetailCategory)
	For example,
	$ budget.sh file.csv -dF
	gives details about "F" (Food)

	$ budget.sh file.csv -d
	gives details about "ALL" [default]

+ -g (Generating Mode. Either on or off, which determines if the temp files are saved or removed.)

+ -t (Threshold. Currently only works when the detail mode is on. Entries with absolute values less than threshold will not be displayed in detail mode)

+ -a (Append. Have not been done. # TODO)


Example:
$ budget.sh file.csv -dF -g -t100
analyzes with generating mode on, detail mode on. Details are displayed for "F", and the threshold is set as 100.








The input .csv file should store dates in the first column, categories in the second column, and amount of money in the third column.
