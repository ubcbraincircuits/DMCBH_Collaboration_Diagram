# DMCBH_Collaboration_Diagram
This repository includes code and directions for creating a chord diagram that visualizes the collaborations between faculty working at the Djavad Mowafaghian Centre for Brain Health (DMCBH). 

## File Descriptions. 
`Grouped_Chord_R`: This R script creates a chord diagram that separates each researcher into their primary area of study and then shows the collaborations between researchers. This script is designed to receive two different excel data tables as input. The first is a table that shows the collaboration between PIs and the second is a table that shows which primary category/group each PI falls under.
The collaboration table must have the same format as the `DMCBH Members Survey 2020_as of August 12, 2021` data file provided in this repository or the code will need to be manually altered. 
The primary category/group data must have the same format as the `EDITED_Primary_Category_for_each_PI` data file provided in this repository or the code will need to be manually altered. 
**NOTE:** Line 32 of the code must be altered in order to switch from creating a chord graph of PIs active collaborations to a chord graph of the PIs publications. details of the alteration are explained in comments above the code. 

`DMCBH Members Survey 2020_as of August 12, 2021.xlxs`: A data table created as part of a survey given out to DMCBH members in Summer 2021. This table has been minimally edited as described in the "Altering data files" section of the ReadMe. 

`RAW_Primary_Category_for_each_PI.xlsx`: An unedited data table that shows the primary category that each PI working with the DMCBH falls into. This file must be altered into `EDITED_Primary_Category_for_each_PI` before it can be used in `Grouped_Chord.R`

`EDITED_Primary_Category_for_each_PI`: An edited version of the group data table that has undergone the alterations discussed in the "Altering data files" section of the ReadMe. 

`group_excel_macro`: a plain text file that shows the excel macro code necessary for completing the alterations to the group data table described in the "Altering data files" section of the ReadMe. 


## Altering data files. 
There are a few alterations that may need to be made to both the collaboration survey data and the Primary category/group data before the R file can be run and the chord diagram can be made.

### For the survey data.
Make sure that there are no people in the survey with the same last name or with first names matching someone else’s last name (e.g. Lynn Raymond and Raymond Lam). If this situation arises it can be easily fixed by using the find and replace function in excel to create an alias (e.g. switch all mentions of Raymond Lam to R. Lam). 

### For the primary category/group data.
There are several steps you will need to follow to get from the raw excel file to an edited file: 
* Delete all of the columns that contain categories you are not interested in (e.g. I only kept the integrated research program categories)
* Delete the very first row of the excel file (the one that contains the category group names)
* Create a macro by going to the view tab of excel, clicking the macro record button, naming your macro, and then immediately stopping the macro recording. 
* Click on the view macros button and then choose to edit the macro you just made. copy the contents of `group_excel_macro` into the macro editor. This macro will delete the contents of any cell that is not highlighted in yellow since we only want to keep the main category that each PI falls into. 
* You may want to change the range of your selection in the macro if you are trying to look at something other than the integrated research programs. 
* Run the macro you just created.

