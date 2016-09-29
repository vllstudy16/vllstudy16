install.packages("gdata")
library(gdata)

fileLocation = "coding.xlsx"
df = gdata::read.xls(fileLocation, stringsAsFactors=FALSE)

# Define codes to check for
unclear = c("unclear", "fuzzy", "unlcear")
barpub = c("bar", "bar/restaurant", "pub", "Bar/pub")
bathroom = c("bathroom", "toilet")
bedroom = c("bedroom", "bedroom/dorm room", "dorm room", "dorm room?", "dorm room/bedroom", "study desk", "dorm room/personal room", "dormroom")
kitchen = c("kitchen", "kitchen (dorm)")
living = c("Living area/flat", "common room", "living room", "flat", "home", "launry room", "washing room", "living room (dorm)", "dorm kitchen/lounge", "washroom", "dorm building")
corridor = c("corridor", "Corridor", "hallway", "dorm corridor", "dorm building corridor", "hall")
train = c("train", "inside tube", "Train/bus", "station", "on a bus", "station paltform","station paltform ", "train", "train platform", "tube", "tube station", "train station", "station", "subway", "train/bus", "train/bus station", "underground")
town = c("town", "city", "bridge", "London W1", "outside building", "road", "sidewalk", "sidewalk/street", "street", "street/sidewalk", "high street", "Town/city")
campus = c("Campus", "campus building", "university campus", "university campus ", "university building", "campus", "university corridor")
classroom = c("classroom", "lab", "office")
lecture = c("lecture theatre", "Lecture theatre", "lecture room", "lecturer room")
cafe = c("caf\xe9", "restaurant", "caf\xe9", "caf\xe9 / library", "caf\xe9/bar/restaurant", "caf\xe9/eating place", "canteen", "cantine", "macdonalds", "café/restaurant entrance", "McDonalds", "university canteen/café","caf,", "caf, / library", "caf,/bar/restaurant", "caf‚/eating place", "Cafe/restaurant", "restaurant/caf,")
shop = c("supermarket", "in a shop", "in a shop (CEX)", "shop", "super market", "acquarium shop", "autopark", "clothes shop", "shopping store")
car = c("Car", "car")
ice = c("ice skating rink", "Ice skating arena")
alcohol = c("off-license")
gym = c("gym", "Gym")
park = c("park", "Park")

df$NewLocation = df$Location
df$NewLocation[df$NewLocation %in% unclear] <- "unclear"
df$NewLocation[df$NewLocation %in% barpub] <- "bar/pub"
df$NewLocation[df$NewLocation %in% bathroom] <- "bathroom"
df$NewLocation[df$NewLocation %in% bedroom] <- "bedroom"
df$NewLocation[df$NewLocation %in% kitchen] <- "kitchen"
df$NewLocation[df$NewLocation %in% living] <- "living area/flat"
df$NewLocation[df$NewLocation %in% corridor] <- "corridor"
df$NewLocation[df$NewLocation %in% train] <- "train/bus"
df$NewLocation[df$NewLocation %in% town] <- "town/city"
df$NewLocation[df$NewLocation %in% campus] <- "campus"
df$NewLocation[df$NewLocation %in% classroom] <- "classroom"
df$NewLocation[df$NewLocation %in% lecture] <- "lecture theatre"
df$NewLocation[df$NewLocation %in% cafe] <- "cafe/restaurant"
df$NewLocation[df$NewLocation %in% shop] <- "shop"
df$NewLocation[df$NewLocation %in% car] <- "car"
df$NewLocation[df$NewLocation %in% ice] <- "ice skating arena"
df$NewLocation[df$NewLocation %in% alcohol] <- "alcohol off-license"
df$NewLocation[df$NewLocation %in% gym] <- "gym"
df$NewLocation[df$NewLocation %in% park] <- "park"

