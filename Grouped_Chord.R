# Libraries
library(tidyverse)
library(viridis)
library(patchwork)
library(circlize)
library(readxl)

# Define the names of the collaboration survey data and the Primary Category/group data
collab_excel_file = "DMCBH Members Survey 2020_as of August 12, 2021.xlsx"
group_excel_file = "EDITED_Primary_Category_for_each_PI.xlsx"

# load in collaboration survey data
df = read_xlsx(collab_excel_file)

# alter dataset to only include the first and last names of the survey subjects
# along with any collaborators.
df$first_name = df$Q36_1
df$last_name = df$Q36_2
df$collab = str_c(df$Q4, df$Q7_2, sep = " ")
df_collab = subset(df, select = c(first_name, last_name, collab))

# remove the uneccesary first row and get rid of rows containing NAs
df_collab = df_collab[-c(1),]
df_collab=df_collab[rowSums(is.na(df_collab)) != ncol(df_collab), ]

##### create an edge list using for loop. ####
origin = c()
destination = c()

for (i in 1:nrow(df_collab)) {
  x = df_collab$last_name[i]
  y = df_collab$first_name[i]
  for (n in 1:nrow(df_collab)) {
    if(is.na(df_collab$collab[n]) == FALSE) {
      if(str_detect(df_collab$collab[n], x) == TRUE) {
        origin = append(origin, paste(paste(substr(df_collab$first_name[n], 1, 1),
                                            ".", sep = ""), df_collab$last_name[n]))
        destination = append(destination, paste(paste(substr(y, 1, 1), ".", sep = ""), x)) 
      }
    }
  }
}

edge_l = data.frame(origin, destination)

# cleaning up the edge list by removing duplicates
edge_l = unique(edge_l)

edge_l$temp = apply(edge_l, 1, function(x) paste(sort(x), collapse=""))

edge_l = edge_l[!duplicated(edge_l$temp), 1:2]

##### download and set up the group names #####
# loading in the group names
df_collab = read_xlsx(group_excel_file)

# creating a group column by pivoting 
df_group = df_collab %>%
  pivot_longer(c("Mental Health & Addictions",
                 "Brain Development & Neurodevelopmental Disorders",
                 "Learning/ Memory & Dementias",
                 "Sensory/ Motor Systems & Movement Disorders",
                 "Brain Injury & Repair"),
               names_to = "group",
               values_to = "junk")

df_group = na.omit(df_group)

# numbering the groups to help with colouration later
number =  c()

for (i in 1:nrow(df_group)) {
  if(df_group$group[i] == "Mental Health & Addictions") {
    number = append(number,2)
  }
  if(df_group$group[i] == "Brain Development & Neurodevelopmental Disorders") {
    number = append(number,3)
  }
  if(df_group$group[i] == "Learning/ Memory & Dementias") {
    number = append(number,4)
  }
  if(df_group$group[i] == "Sensory/ Motor Systems & Movement Disorders") {
    number = append(number,5)
  }
  if(df_group$group[i] == "Brain Injury & Repair") {
    number = append(number,6)
  }
}

# adding the color number to the dataframe.
df_group$number = number

##### Integrating the grouping data into the collaboration data #####

# Making the naming of the groups dataframe the same the naming 
#of the collaboration dataframe
df_group$name = paste(substr(df_group$`First Name`, 1, 1), df_group$`Last Name`, sep=". ")
df_group =  subset(df_group, select = c("name", "group", "number"))

# removing any names from our group list not found in the collaboration list.
all_edges = data.frame(stack(edge_l))
nodes = semi_join(df_group, all_edges, by = c("name"="values"))

# Removing any colaborations that involve names not found on the group list. 
links = semi_join(edge_l, nodes, by = c("origin"="name"))
links = semi_join(links, nodes, by = c("destination"="name"))

# cleaning up nodes
nodes = data.frame(nodes)

# creating the groupings
group = structure(nodes$group, names = nodes$name)

# creating colors for the groupings
color = structure(nodes$number, names = nodes$name)

# create an adjacency list. 
adjacencyData = data.frame(with(links, table(origin, destination)))

##### creating the chord diagram #####

# parameters
circos.clear()
circos.par(start.degree = 90, gap.degree = 4, track.margin = c(-0.1, 0.1), 
           points.overflow.warning = FALSE, canvas.xlim = c(-1.3,1.3),
           canvas.ylim = c(-1.3,1.3))
par(mar = rep(0, 4))

# alright, now I just need the grid colors and some of the other wording changes.
chordDiagram(adjacencyData, group = group, grid.col = color,
             transparency = 0.25,
             diffHeight  = -0.04,
             annotationTrack = "grid", 
             annotationTrackHeight = c(0.05, 0.1),
             link.sort = TRUE, 
             link.largest.ontop = FALSE)

circos.trackPlotRegion(
  track.index = 1, 
  bg.border = NA, 
  panel.fun = function(x, y) {
    
    xlim = get.cell.meta.data("xlim")
    sector.index = get.cell.meta.data("sector.index")
    
    # Add names to the sector. 
    circos.text(
      x = mean(xlim), 
      y = 5.2, 
      labels = sector.index, 
      facing = "clockwise", 
      niceFacing = TRUE,
      cex = 0.8
    )
    
     #Add graduation on axis
    circos.axis(
      h = "top", 
      #major.at = seq(from = 0, to = xlim[2], by = ifelse(test = xlim[2]>10, yes = 2, no = 1)),
      labels.cex = 0.001,
      minor.ticks = 2, 
      major.tick.length = 0.1, 
      labels.niceFacing = FALSE)
  }
)
