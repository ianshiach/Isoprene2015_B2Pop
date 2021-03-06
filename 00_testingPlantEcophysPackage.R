#00_testingPlantEcoPhys
#Author: Dave Moore
#Date: 09/05/2015
#Purpose: Test the Plantecophys package - a stand alone package to model common leaf gas exchange measurements


# download the source code for the package: https://cran.r-project.org/web/packages/plantecophys/index.html
#install.packages('PATH/plantecophys_0.6-3.zip', repos = NULL, type="source")
#Manual: https://cran.r-project.org/web/packages/plantecophys/plantecophys.pdf 

library (plantecophys)
library(dplyr)
library(tidyr)
library(ggplot2)
library(grid) #required for 'unit'
#Load data
#Amberly's data from B2

#loading dat_Iso1.Rda - isoprene unit conversions completed using 00_ReadIsoprene_UnitConversions
load ("dat_Iso_01.Rda")
#to make this from scratch just run: 00_ReadIsoprene_UnitConverions.R 



# For the simple case - create a dataframe that is a subset of dat_Iso_01.Rda containing a single
# A/ci curve - I picked the line and data at random from a list of available lines and dates.
#

lines= as.list(unique(dat_Iso_01$line)) 
dates= as.list(unique(dat_Iso_01$date)) 
RefTemps= as.list(unique(dat_Iso_01$Tref)) 

line=dat_Iso_01$line
dateMeas=dat_Iso_01$date
CO2S=dat_Iso_01$CO2
Ci=dat_Iso_01$Ci
Tleaf=dat_Iso_01$Tref
Photo=dat_Iso_01$Anet
PARi=1800

Amberlyaci=data.frame(line,dateMeas,CO2S,Ci,Tleaf,Photo, PARi)

#Split times
ACI25 = Amberlyaci   %>% #piping command for filter
  #restrict to a single Aci curve filter out any Anet values that are too big
  filter(Tleaf==25, Photo < 50) %>% #piping command for select
  #select only the Anet, gs, Ci variables
  select(line,dateMeas,CO2S,Ci,Tleaf,Photo,PARi) 

ACI25_180327 = ACI25   %>% #piping command for filter
  #restrict to a single Aci curve - line
  filter(line=="180-327")#piping command for select

#FIT ACI
fitACI25_180327=fitaci(ACI25_180327)


ACI25_180372 = ACI25   %>% #piping command for filter
  #restrict to a single Aci curve - line
  filter(line=="180-372")#piping command for select

#FIT ACI
fitACI25_180327=fitaci(ACI25_180327)


unique(ACI25_180327$dateMeas)
unique(dat_Iso_01$line)



ACI35 = Amberlyaci   %>% #piping command for filter
  #restrict to a single Aci curve filter out any Anet values that are too big
  filter(Tleaf==35, Photo < 50) %>% #piping command for select
  #select only the Anet, gs, Ci variables
  select(line,dateMeas,CO2S,Ci,Tleaf,Photo,PARi)




 
  mytable = fitaci(ACI25) %>% 
   group_by(date,line)
  

  mutate(grp1 = lag(grp), grp2 = grp, total = total + lag(total)) %>%
  select(grp1, grp2, total) %>%
  na.omit

for(i in 1:length(lines)){
  print(lines[i])
  print(i)
}



Junkaci02 = dat_Iso_01   %>% #piping command for filter
  #restrict to a single Aci curve filter out any Anet values that are too big
  filter(line=="49-177", date=="7/20/2014", Tref==25, Anet < 50) %>% #piping command for select
  #select only the Anet, gs, Ci variables
  mutate(PARi=1800, Photo=Anet,CO2S=CO2, Tleaf=Tref)  %>%
  select(line,date,CO2S,Ci,Tleaf,Photo,PARi) 


Junkaci02 = dat_Iso_01   %>% #piping command for filter
  #restrict to a single Aci curve filter out any Anet values that are too big
  filter(line=="49-177", date=="7/20/2014", Tref==25, Anet < 50) %>% #piping command for select
  #select only the Anet, gs, Ci variables
  mutate(PARi=1800, Photo=Anet,CO2S=as.numeric(CO2), Tleaf=as.numeric(Tref))  %>%
  select(line,date,CO2S,Ci,Tleaf,Photo,PARi) 


# Using fitaci [library (plantecophys)] to estimate Vcmax and Jmax
#
# Note: you need to specify the dataframe and the variables that correspond to ALEAF, Tleaf, Ci and PPFD
# Note: I haven't worked out how to exclude outliers but PECAN:Photosynthesis has this function built in
#
CheckACI_new=fitaci(Junkaci02)

plot(CheckACI_new$df$Amodel, CheckACI_new$df$Ameas)





#Aci plots
#
# Plotting the data used to fit this curve
#
ACi <- ggplot(Junkaci02, aes(x=Ci, y=Photo))

line_label <- Junkaci02$line[1]
date_label <- Junkaci02$date[1]

ACi + aes(shape = factor(line)) +
  ggtitle(paste("Line",line_label,"Date ",date_label,sep=" "))+
  geom_point(size = 8) +
  theme_classic() +
  theme(axis.text=element_text(size=20),
        axis.title=element_text(size=22,face="bold")) + 
  theme(panel.border = element_blank(), axis.line = element_line(colour="black", size=2, lineend="square"))+
  theme(axis.ticks = element_line(colour="black", size=2, lineend="square"))+
  theme(axis.ticks.length=unit(-0.25, "cm"), axis.ticks.margin=unit(0.5, "cm"))+ #provide negative value for tick length = they face inwards
  ylab("Assimilation (umol/m2/sec)")+
  xlab("Ci") 
#
#

#


# 
# ACi_fit <- ggplot(CheckACI$df, aes(x=Ci, y=Amodel))
# 
# line_label <- Junkaci02$line[1]
# date_label <- Junkaci02$date[1]
# 
# ACi_fit + geom_point(colour="grey90", size = 2.5) +
#   theme_classic() +
#   theme(axis.text=element_text(size=20),
#         axis.title=element_text(size=22,face="bold")) + 
#   theme(panel.border = element_blank(), axis.line = element_line(colour="black", size=2, lineend="square"))+
#   theme(axis.ticks = element_line(colour="black", size=2, lineend="square"))+
#   ylab("Modelled Assimilation (umol/m2/sec)")+
#   xlab("Ci") 
