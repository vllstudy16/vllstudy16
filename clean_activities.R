install.packages("gdata")
library(gdata)

fileLocation = "coding.xlsx"
df = gdata::read.xls(fileLocation, stringsAsFactors=FALSE)

unknown = c("no discernible objects","completely fuzzy","unclear","unknown","corrupt","too dark")
usingComputer = c("at computer","looking at laptop screen","internet browsing","chatting on facebook","checking phone and at computer","watching tv on computer","eating food in front of computer","working on laptop","using facebook on laptop","checking mails","reading article on relationship in laptop","using laptop","watching youtube","facebook","working with laptop","watching game of thrones on youtube","youtube","playing computer game","browsing the internet, sitting with laptop on his lap","checking phone and on computer","checking phone and watching computer","instant messaging on Facebook, looking at laptop monitor, eating","looking at laptop monitor","looking at laptop monitor, sitting","looking at laptop screen, sitting","messaging with friends on Facebook","messaging with friends on Facebook/ checking newsfeed from his laptop","using a text editor on his laptop","watching someone at computer","watching youtube on laptop, checking nail polish","watching youtube on laptop, sitting","watching youtube on laptop, sitting,eating","writing on laptop","writing/reading email", "sitting with laptop on his/her lap, browsing through files", "sitting with laptop on his/her lap, using microsoft word","writing on his/her laptop")
eatingDrinking = c("eating pizza","eating","drinking","eating fried patatas","sitting, eating, drinking","eating, sitting","eating food in front of computer","lunch","eating food","eating burger","pouring drink in glass","pouring sauce","eating/checking cellphone","eating/drinking with friends","drinking, sitting", "eating and watching computer","standing,holding a cup of coffee/tea")
attendingClass = c("attending class","sitting in the classroom","discussing","in class","attending a workshop/conference","attending a presentation","listening to lecture","attending lecture","sitting, listening to lecture","sitting, listening to lecture,looking at laptop monitor")
onPhone = c("checking phone","on phone","looking at mobile phone screen","texting","checking phone and at computer","checking mobile in class","eating/checking cellphone","checking mobile","checking cellphone","walking and using phone","charging mobile phone","checking phone and on computer","checking phone and watching computer","looking at mobile phone monitor","looking at mobile phone screen, messaging on Facebook","playing game on phone","sitting, looking at/texting mobile phone screen")
socialisingEntertainment = c("talking","interacting","socialising","live concert","playing game","eating/drinking with friends","talking with friend","dining out","playing board game","sitting, talking","skating")
services = c("shopping","queing","ordering","purchasing","checking out at supermarket","purchasing drink","standing in queue to order burger/food","queuing ","ticket inspection")
standing = c("standing","waiting","looking at the noticeboard","looking outside from window")
walking = c("walking","walking dog","walkin inside the entrance","walk","walking through revolving doors","walking/standing")
traveling = c("commuting","parking motorcycle","motorcycling","riding in car","waiting on train platform","riding train","on train","traveling in tube","walking on platform 12","at station","at train station","in car")
readingOrWriting = c("reading","drawing","reading magazine","sitting, reading","sitting, writing","writing, sitting")
sittingLying = c("sitting at table","sitting","sitting and holding hands","sitting or lying","lying down","lying on bed","siting","sitting at desk")
startStudying = c("starting study")
cooking = c("cooking","in kitchen","openning refrigirator","unclear (wasing dishes)","using the vacuum cleaner","washing dishes","washing hands","working in kitchen","washing clothes","washing hands/utensils")
bedroom = c("in bedroom","in bathroom","looking in mirror","painting nails","makeup","doing makeup","getting ready","putting makeup on","putting on glasses")
study = c("at desk","studying/discussing","studying")
onTablet = c("on tablet")
exercise = c("working out","pole dancing", "gyming")
cameraRelated = c("posing to camera","adjusting camera")
viceRelated = c("buying alcohol")
watchingTV = c("watching tv")

df$NewActivity = df$Activity
df$NewActivity[df$NewActivity %in% unknown] <- "unknown activity"
df$NewActivity[df$NewActivity %in% usingComputer] <- "using computer"
df$NewActivity[df$NewActivity %in% eatingDrinking] <- "eating/drinking"
df$NewActivity[df$NewActivity %in% attendingClass] <- "attending class"
df$NewActivity[df$NewActivity %in% onPhone] <- "on phone"
df$NewActivity[df$NewActivity %in% socialisingEntertainment] <- "socialising/entertainment"
df$NewActivity[df$NewActivity %in% services] <- "services"df
df$NewActivity[df$NewActivity %in% standing] <- "standing"
df$NewActivity[df$NewActivity %in% walking] <- "walking"
df$NewActivity[df$NewActivity %in% traveling] <- "travel"
df$NewActivity[df$NewActivity %in% readingOrWriting] <- "reading or writing"
df$NewActivity[df$NewActivity %in% sittingLying] <- "sitting/lying"
df$NewActivity[df$NewActivity %in% startStudying] <- "commencing research study"
df$NewActivity[df$NewActivity %in% cooking] <- "kitchen/house"
df$NewActivity[df$NewActivity %in% bedroom] <- "bedroom/bathroom related"
df$NewActivity[df$NewActivity %in% study] <- "study"
df$NewActivity[df$NewActivity %in% onTablet] <- "on tablet"
df$NewActivity[df$NewActivity %in% exercise] <- "exercise"
df$NewActivity[df$NewActivity %in% cameraRelated] <- "camera related"
df$NewActivity[df$NewActivity %in% viceRelated] <- "vice related"
df$NewActivity[df$NewActivity %in% watchingTV] <- "watching tv



