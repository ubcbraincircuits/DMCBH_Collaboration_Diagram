# Libraries
library(tidyverse)
library(viridis)
library(patchwork)
library(circlize)
library(readxl)

##### Set up #####

# Define the names of the collaboration survey data and the Primary Category/group data
collab_excel_file = "DMCBH Members Survey 2020_as of August 12, 2021.xlsx"
group_excel_file = "EDITED_Primary_Category_for_each_PI.xlsx"

# Define the title, Primary categroy names, and the colour pallete you want to use 
title = "Active Collaborators"
Primary_c = c("Mental Health & Addictions",
              "Brain Development & Neurodevelopmental Disorders",
              "Learning/ Memory & Dementias",
              "Sensory/ Motor Systems & Movement Disorders",
              "Brain Injury & Repair")
c_pallete = c("red","green","blue","cyan","magenta")

# load in collaboration survey data
df = read_xlsx(collab_excel_file)

# renaming the columns that include the first and last names of participants for simplicity
df = rename(df, first_name = Q36_1, last_name = Q36_2)

# Renaming the column that contains the collaborators. 
# This line of code must be altered depending on if you want to see the publications or 
# the active collaborators by using Q4 for publications and Q7_2 for active collaborations
df = rename(df, collab = Q7_2)

# creating a subset of our survey data that extracts the useful columns. 
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

# cleaning up the edge list by removing self connections. 
for (i in 1:nrow(edge_l)) {
  if (identical(edge_l$origin[i],edge_l$destination[i]) == TRUE) {
    edge_l = edge_l[-i,]
  }
}

##### download and set up the group names #####
# loading in the group names
df_group = read_xlsx(group_excel_file)

# creating a group column by pivoting 
df_group = df_group %>%
  pivot_longer(Primary_c,
               names_to = "group",
               values_to = "junk")

df_group = na.omit(df_group)

# Assigning a colour to each group. 
color =  c()

for (i in 1:nrow(df_group)) {
  for (j in 1:length(Primary_c)) {
    if(df_group$group[i] == Primary_c[j]) {
      color = append(color,c_pallete[j])
    }
  }
}

# adding the color column to the dataframe.
df_group$color = color

##### Integrating the grouping data into the collaboration data #####

# Making the naming of the groups dataframe the same the naming 
#of the collaboration dataframe
df_group$name = paste(substr(df_group$`First Name`, 1, 1), df_group$`Last Name`, sep=". ")
df_group =  subset(df_group, select = c("name", "group", "color"))

# removing any names from our group list not found in the collaboration list.
all_edges = data.frame(stack(edge_l))
nodes = semi_join(df_group, all_edges, by = c("name"="values"))

# Removing any colaborations that involve names not found on the group list. 
links = semi_join(edge_l, nodes, by = c("origin"="name"))
links = semi_join(links, nodes, by = c("destination"="name"))

# cleaning up nodes
nodes = data.frame(nodes)

# creating the groupings
group_ind = structure(nodes$group, names = nodes$name)

# creating colors for the groupings
color_ind = structure(nodes$color, names = nodes$name)

# create an adjacency list. 
adjacencyData = data.frame(with(links, table(origin, destination)))

##### creating the chord diagram #####

# set up the parameters
circos.clear()
circos.par(start.degree = 90, gap.degree = 4, track.margin = c(-0.1, 0.1), 
           points.overflow.warning = FALSE, canvas.xlim = c(-1.3,1.3),
           canvas.ylim = c(-1.3,1.3))
par(mar = c(0,0,2,0),xpd = TRUE, cex.main = 1.5)

# create the chord diagram
chordDiagram(adjacencyData, group = group_ind, grid.col = color_ind,
             transparency = 0.25,
             diffHeight  = -0.04,
             annotationTrack = "grid", 
             annotationTrackHeight = c(0.05, 0.1),
             link.sort = TRUE, 
             link.largest.ontop = FALSE)

# Add the text and the axis surrounding the diagram.
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
      cex = 0.8,
    )
    
     #Add graduation on axis
    circos.axis(
      h = "top", 
      labels.cex = 0.001,
      minor.ticks = 2, 
      major.tick.length = 0.1, 
      labels.niceFacing = FALSE)
  }
)

# Add a title
title(title,outer=FALSE)
