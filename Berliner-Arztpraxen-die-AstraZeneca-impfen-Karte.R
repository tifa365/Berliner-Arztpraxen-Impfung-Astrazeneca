set.seed(140)

#install.packages
library(tidyverse)
library(leaflet)
library(readxl)
#for geocoding the addresses
library(tidygeocoder)

#read in csv
df <- read_excel("Übersicht_AstraZeneca-Impfpraxen.xlsx")

#rename doctor-column because of length
df <- rename(df, Name_Arzt = 5)

#clean dataset
df_cleaned <- df %>%
  #rename doctor's name-column because of length
  rename(Name_Arzt = 5) %>% 
  #fix doubled street address by splitting columns into two street addresses
  separate_rows(`Straße und Hausnummer`, sep = "/") %>% 
  #after street address is separated, keep only the first one
  distinct(`Name_Arzt`, `Name der Praxis`, .keep_all = TRUE) %>%
  #create (combined) address colum for georeferencing each address           
  unite(PLZ, Bezirk, sep = " ", col = "kombiniert-plz-landkreis") %>% 
  unite(`Straße und Hausnummer`, `kombiniert-plz-landkreis`, sep = ", ", col = "Adresse")

#geolocate all doctor's offices
df_astrazeneca_doctors_offices <- df_cleaned %>%
  geocode(Addresse) %>% 
  #drop all rows which failed to produce latitute value
  drop_na(lat)

#create simple leaflet map with location markers
map <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(data = df_astrazeneca_doctors_offices,
                    lng = ~long, 
                    lat = ~lat,
                    #name of doctor
                    label = ~`Name der Praxis`,
                    #show address on click
                    popup = ~`Adresse`) #c(~`Name der Praxis`,~Addresse)
# Print the map
map 

#save map as .html
library(htmlwidgets)
saveWidget(map, 'index.html')
