###############
##WORLD_SCALE##
###############

# clear workspace
rm(list = ls())

# set working directory
setwd("F:/phylocov/DEFINITIVE/World_W1")

# import all packages
list.of.packages <- c("adephylo","tidyverse", "lubridate", "glue",
                      "ape", "phytools", "tidytree", "ggplot2",
                      "treeio", "data.table", "dplyr",
                      "parallel", "foreach", "doParallel", "sqldf",
                      "ggtree", "zoo")

new.packages <- list.of.packages[!(list.of.packages %in%
                                     installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(list.of.packages, require, character.only = TRUE)

#import metadata
metadata <- readxl::read_xlsx("metadata_file4.xlsx", sheet = "Feuil1") %>%
  mutate(geo_loc=continent_wave)

#you can limit the number of replicates because the program is time-consuming
n_replicates <- 10

for(replicat in 1:n_replicates){
  print(replicat)
  #import the tree
  my_tree = read.nexus(file = gsub(" ", "", paste(replicat, ".nexus")))
  #convert to binary tree
  my_tree = multi2di(my_tree)
  
  #get tips
  my_tips = my_tree$tip.label
  metadata_sub = metadata[metadata$gisaid_id %in% my_tips,]
  
  tree_table <- as_tibble(my_tree) %>%
    left_join(select(metadata_sub, c('gisaid_id', 'geo_loc', 'Clade')), by = c('label' = 'gisaid_id'))
  
  as.treedata(tree_table) -> tree_data
    
  #list of the territories investigated
  list_region=c("Europe", "France", "North.America", "South.America", "Asia", "Africa")
  #compute all pairwise distances and convert as dataframe
  distances = distTips(as.phylo(tree_table), tips="all")
  distances = as.data.frame(as.matrix(distances))
  
  #calculate for each region
  for(a_region in list_region){
    #get metadata for a specific region
    metadata_temp = metadata_sub[metadata_sub$continent_wave==a_region,]
    #initialize vector of distances
    distances_region=c()
    print(a_region)
    #we compare distances in the matrix for a same region
    for(i in 1:nrow(distances)){
      #print(i)
      for(j in 1:nrow(distances)){
        if(rownames(distances)[i] %in% metadata_temp$gisaid_id){
          if(colnames(distances)[i] %in% metadata_temp$gisaid_id){
            if(rownames(distances)[i]!=colnames(distances)[j]){
              distances_region=c(distances_region, distances[i,j])
            }
          }
        }
      }
    }
    
    #we convert results as a dataframe and identify the region
    current_table = as.data.frame(distances_region)
    current_table$continent_wave = metadata_temp$continent_wave[1]
    
    #if the variable does not exist, we must initialize it
    if(exists("final_distances")){
      final_distances = rbind(final_distances, current_table)
    }else{
      final_distances = data.frame(distances_region=double(), continent_wave=character())
      final_distances = current_table
    }
  }
}

#plot the results
ggplot(final_distances, aes(x=continent_wave, y=distances_region, fill=continent_wave))+
  geom_violin(trim=F, alpha=0.2)+
  geom_boxplot(width=0.1, outlier.shape = NA)+
  scale_fill_manual(values=c("#EF3437", "#5F4197", "#538DCA", "#54C538", "#1A7E41", "#FF8421", "#FEDA27"))+
  theme(axis.line.x = element_line(size = 1, colour = "black"),
        axis.line.y = element_line(size = 1, colour = "black"),
        axis.line = element_line(size=1, colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        text=element_text(size = 16, family="Arial"),
        axis.text.x=element_text(colour="black", size = 16),
        axis.text.y=element_text(colour="black", size = 16),
        legend.position = "none")


################
##FRANCE_SCALE##
################

# clear workspace
rm(list = ls())

# set working directory
setwd("F:/phylocov/DEFINITIVE/France_W1/")


# import all packages
list.of.packages <- c("adephylo","tidyverse", "lubridate", "glue",
                      "ape", "phytools", "tidytree", "ggplot2",
                      "treeio", "data.table", "dplyr",
                      "parallel", "foreach", "doParallel", "sqldf",
                      "ggtree", "zoo")

new.packages <- list.of.packages[!(list.of.packages %in%
                                     installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(list.of.packages, require, character.only = TRUE)

#import metadata
metadata <- readxl::read_xlsx("metadata_file4.xlsx", sheet = "Feuil1") %>%
  mutate(geo_loc=region)

#you can limit the number of replicates because the program is time-consuming
n_replicates <- 10

for(replicat in 1:n_replicates){
  print(replicat)
  #import the tree
  my_tree = read.nexus(file = gsub(" ", "", paste(replicat, ".nexus")))
  #convert to binary tree
  my_tree = multi2di(my_tree)
  
  #get tips
  my_tips = my_tree$tip.label
  metadata_sub = metadata[metadata$gisaid_id %in% my_tips,]
  
  tree_table <- as_tibble(my_tree) %>%
    left_join(select(metadata_sub, c('gisaid_id', 'geo_loc', 'Pango_lineage')), by = c('label' = 'gisaid_id'))
  
  as.treedata(tree_table) -> tree_data
  
  #list of the territories investigated
  list_region=c("ARA", "BRE", "IDF", "OCC", "PACA")
  
  #compute all pairwise distances and convert as dataframe
  distances = distTips(as.phylo(tree_table), tips="all")
  distances = as.data.frame(as.matrix(distances))
  
  #calculate for each region
  for(a_region in list_region){
    #get metadata for a specific region
    metadata_temp = metadata_sub[metadata_sub$region==a_region,]
    #initialize vector of distances
    distances_region=c()
    print(a_region)
    #we compare distances in the matrix for a same region
    for(i in 1:nrow(distances)){
      #print(i)
      for(j in 1:nrow(distances)){
        if(rownames(distances)[i] %in% metadata_temp$gisaid_id){
          if(colnames(distances)[i] %in% metadata_temp$gisaid_id){
            if(rownames(distances)[i]!=colnames(distances)[j]){
              distances_region=c(distances_region, distances[i,j])
            }
          }
        }
      }
    }
    
    #we convert results as a dataframe and identify the region
    current_table = as.data.frame(distances_region)
    current_table$region = metadata_temp$region[1]
    
    #if the variable does not exist, we must initialize it
    if(exists("final_distances")){
      final_distances = rbind(final_distances, current_table)
    }else{
      final_distances = data.frame(distances_region=double(), region=character())
      final_distances = current_table
    }
  }
}

#plot the results
ggplot(final_distances, aes(x=region, y=distances_region, fill=region))+
  geom_violin(trim=F, alpha=0.2)+
  geom_boxplot(width=0.1, outlier.shape = NA)+
  scale_fill_manual(values=c("#FF4D31", "#6200eb", "#2EC245", "#e0ac15", "#1790F5"))+
  theme(axis.line.x = element_line(size = 1, colour = "black"),
        axis.line.y = element_line(size = 1, colour = "black"),
        axis.line = element_line(size=1, colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        text=element_text(size = 16, family="Arial"),
        axis.text.x=element_text(colour="black", size = 16),
        axis.text.y=element_text(colour="black", size = 16),
        legend.position = "none")


################
##EUROPE_SCALE##
################

# clear workspace
rm(list = ls())

# set working directory
setwd("F:/phylocov/DEFINITIVE/Europe_W1/")


# import all packages
list.of.packages <- c("adephylo","tidyverse", "lubridate", "glue",
                      "ape", "phytools", "tidytree", "ggplot2",
                      "treeio", "data.table", "dplyr",
                      "parallel", "foreach", "doParallel", "sqldf",
                      "ggtree", "zoo")

new.packages <- list.of.packages[!(list.of.packages %in%
                                     installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(list.of.packages, require, character.only = TRUE)

#import metadata
metadata <- readxl::read_xlsx("metadata_file4.xlsx", sheet = "Feuil1") %>%
  mutate(geo_loc=country)

#you can limit the number of replicates because the program is time-consuming
n_replicates <- 10

for(replicat in 1:n_replicates){
  print(replicat)
  #import the tree
  my_tree = read.nexus(file = gsub(" ", "", paste(replicat, ".nexus")))
  #convert to binary tree
  my_tree = multi2di(my_tree)
  
  #get tips
  my_tips = my_tree$tip.label
  metadata_sub = metadata[metadata$gisaid_id %in% my_tips,]
  
  tree_table <- as_tibble(my_tree) %>%
    left_join(select(metadata_sub, c('gisaid_id', 'geo_loc', 'Clade')), by = c('label' = 'gisaid_id'))
  
  as.treedata(tree_table) -> tree_data
  
  #list of the territories investigated
  list_region=c("Belgium","France","Germany","Italy",
                   "Netherlands","Poland","Romania","Russia",
                   "Spain","Sweden","United.Kingdom")
  
  #compute all pairwise distances and convert as dataframe
  distances = distTips(as.phylo(tree_table), tips="all")
  distances = as.data.frame(as.matrix(distances))
  
  #calculate for each region
  for(a_region in list_region){
    #get metadata for a specific region
    metadata_temp = metadata_sub[metadata_sub$country==a_region,]
    #initialize vector of distances
    distances_region=c()
    print(a_region)
    #we compare distances in the matrix for a same region
    for(i in 1:nrow(distances)){
      #print(i)
      for(j in 1:nrow(distances)){
        if(rownames(distances)[i] %in% metadata_temp$gisaid_id){
          if(colnames(distances)[i] %in% metadata_temp$gisaid_id){
            if(rownames(distances)[i]!=colnames(distances)[j]){
              distances_region=c(distances_region, distances[i,j])
            }
          }
        }
      }
    }
    
    #we convert results as a dataframe and identify the region
    current_table = as.data.frame(distances_region)
    current_table$country = metadata_temp$country[1]
    
    #if the variable does not exist, we must initialize it
    if(exists("final_distances")){
      final_distances = rbind(final_distances, current_table)
    }else{
      final_distances = data.frame(distances_region=double(), country=character())
      final_distances = current_table
    }
  }
}

#plot the results
ggplot(final_distances, aes(x=country, y=distances_region, fill=country))+
  geom_violin(trim=F, alpha=0.2)+
  geom_boxplot(width=0.1, outlier.shape = NA)+
  scale_fill_manual(values=c("#FDD93B", "#57C540", "#FD832F", "#558EC8","#872BBA", "#813008", "#C485E6",
                             "#16999F", "#10791E", "#867017", "#ED313C"))+
  theme(axis.line.x = element_line(size = 1, colour = "black"),
        axis.line.y = element_line(size = 1, colour = "black"),
        axis.line = element_line(size=1, colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        text=element_text(size = 16, family="Arial"),
        axis.text.x=element_text(colour="black", size = 16),
        axis.text.y=element_text(colour="black", size = 16),
        legend.position = "none")
