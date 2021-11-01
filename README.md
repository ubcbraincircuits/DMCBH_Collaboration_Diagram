# DMCBH_Collaboration_Diagram
This repository includes code and directions for creating a chord diagram that visualizes the collaborations between faculty working at the Djavad Mowafaghian Centre for Brain Health

File Descriptions.

Grouped_Chord_Collaborators.ipynb: A Jupyter Notebook in R that creates a chord diagram that separates each researcher into their primary area of study and then shows the collaborations between researchers. 
This script is designed to receive two different excel data tables as input. The first is a table that shows the collaboration between PIs (DMCBH Members Survey 2020_as of September 20, 2021.xlxs) and the 
second is a table that shows which primary category/group each PI falls under (EDITED_Primary_Category_for_each_PI.xlsx). 
NOTE: The 8 lines after the comment "# # Renaming the column that contains the collaborators." of the code must be altered in order to switch from creating a chord graph of PIs active collaborations to a 
chord graph of the PIs publications (or combined). details of the alteration are explained in comments above the code.

SubGroup_Chord_Collaborators.ipynb: A Jupyter Notebook in R that creates a chord diagram of subgroups of researchers. This script allows you to specify the research category/group and create a chord diagram 
with collaborations between PIs in that group. Note: The 8 lines after the comment "# # Renaming the column that contains the collaborators." of the code must be altered in order to switch from creating a chord graph of PIs active collaborations to a 
chord graph of the PIs publications (or combined). Note: The lines after the comment "# !!! Filter for subgroup" must be altered in order to switch research category/group. 

DMCBH Members Survey 2020_as of September 20, 2021.xlxs: A data table created as part of a survey given out to DMCBH members in Summer 2021. 

EDITED_Primary_Category_for_each_PI: An edited version of the group data table that specifies the research group/category for each PI.

For the survey data.
Make sure that there are no people in the survey with the same last name or with first names matching someone else’s last name (e.g. Lynn Raymond and Raymond Lam). If this situation arises it can be easily fixed by using the find and replace function in excel to create an alias (e.g. switch all mentions of Raymond Lam to R. Lam).

