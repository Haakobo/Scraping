library(RCurl)
library(curl)
library(rJava)
library(tidyr)
library(stringr)
library(XML)
library(xlsx)
library(WriteXLS)
library(openxlsx)
library(rlist)
library(dplyr)
library(XLConnect)
library(rvest)  

download.file('https://www.beeline.am/hy/mobile-tariffs/', 'blabla.html')
content <- read_html("blabla.html")
links <- content %>% html_nodes(., "a") %>% html_attr("href")
links_new <- list(links[grepl("https://www.beeline.am/hy/mobile-tariffs/[A-Zb-z]+",links, perl=TRUE)])

scrap <- function(url){
   download.file(url, 'result.html')
   content <- read_html('result.html')
   
   result <- list()
   
   title1<-content %>% html_nodes(., xpath = "/html/body/main/div[3]/div/div[1]/div[1]/h2/text()") %>% html_text()
   title <- gsub("\\s*\\([^\\)]+\\)","",title1, perl=TRUE)
   
   result <- c(result, title)
   
   type <- regmatches(title1, gregexpr("(?=\\().*?(?<=\\))", title1, perl=T)) %>% gsub("\\(","",.) %>% gsub("\\)","",.)
   result <- c(result, type)
   
   sms<- content %>% html_nodes(., xpath = "/html/body/main/div[3]/div/div[1]/div[1]/div[2]/div[3]/div/div/span[1]") %>% html_text()
   result <- c(result, sms)
   
   mins_offnet <- content %>% html_nodes(., xpath = "/html/body/main/div[3]/div/div[1]/div[1]/div[2]/div[2]/div/div/span[1]") %>% html_text()
   result <- c(result, mins_offnet)
   
   mins_onnet <- content %>% html_nodes(., xpath = "/html/body/main/div[3]/div/div[1]/div[1]/div[2]/div[1]/div/div/span[1]") %>% html_text()
   result <- c(result, mins_onnet)
   
   internet<-content %>% html_nodes(., xpath = "/html/body/main/div[3]/div/div[1]/div[1]/div[2]/div[4]")%>% html_text()
   internet1<-gsub("\r\n","",internet)
   result <- c(result, internet1)
   
   price<-content %>% html_nodes(., xpath = "/html/body/main/div[3]/div/div[1]/div[2]/div[1]/div[2]/div/p")%>% html_text()
   price
   #if (title= "Mix"){
     #price <- content%>% html_nodes(., xpath = "/html/body/main/div[3]/div/div[1]/div[2]/div[2]/div[2]/div/p")%>% html_text()
   #}
   result <- c(result, price)
   
   
   result
} 

for (i in links_new[[1]]){
  print(unlist(scrap(i)))
}

df <- data.frame(matrix(ncol = 7, nrow = 0))
x <- c("title", "internet","type","price","mins_offnet","sms","mins_onnet")
colnames(df) <- x
j <- 1

for (i in links_new[[1]]){
  print(i)
  scrap(i)
  df[j,] <- unlist(scrap(i))
  j <- j + 1
}
write.xlsx(df, 'filename.xlsx')




gsub("\\s*\\([^\\)]+\\)","","blablabla (bla)", perl=TRUE)

regmatches("blablabla (bla)", gregexpr("(?=\\().*?(?<=\\))", "blablabla (bla)", perl=T)) %>% gsub("\\(","",.) %>% gsub("\\)","",.)

#### First part done (prelim)


scrap_table <- function(url){
  download.file(url,destfile = "result.html")
  tariff<- readHTMLTable("result.html", which=1)
  if (nrow(tariff)<5){
    content <- read_html('result.html')
    a <- content %>% html_nodes("div.static-content") %>% html_nodes("p") %>% html_text()
    b <- list(a[grepl("- \\d+ ????????",a, perl=TRUE)|grepl("-\\d+ ????????",a, perl=TRUE)])
    b1<-as.data.frame(b)
    names(b1)[1]<-"new_name"
    tariff <-data.frame(str_split_fixed(b1$new_name, "-", 2))
  }
  print(tariff)
}



wb <- loadWorkbook("createSheet.xlsx")
i <- 1
for (j in links_new[[1]]){
  print(j)
  print(scrap_table(j))
  Sheet = createSheet(wb, unlist(strsplit(j, "/"))[6])
  writeWorksheet(wb, as.data.frame(scrap_table(j)), sheet = paste(unlist(strsplit(j, "/"))[6]), startCol = 1)
  j <- j + 1
  
}
saveWorkbook(wb)


a1 <- scrap_table(links_new[[1]])
a2 <- scrap_table(links_new[[2]])
wb <- loadWorkbook("createSheet.xlsx")
wb

names <- tail(unlist(strsplit(links_new[1], split="/", fixed = FALSE, perl = FALSE, useBytes = FALSE)), n=2)[1]
paste(names, "_", as.character(Sys.Date()), sep = "")

as.character(Sys.Date())

tail(names, n = 2)[1]



names[length(names)-1]

links_new[-2]

final <- scrap_table(links_new[1])
colnames(final)[2] <- paste(tail(unlist(strsplit(links_new[[1]], split="/", fixed = FALSE, perl = FALSE, useBytes = FALSE)), n=2)[1], "_", as.character(Sys.Date()), sep = "")
for (j in links_new[2:length(links_new)]){
  print(j)
  a <- scrap_table(j)
  colnames(a)[2] <- paste(tail(unlist(strsplit(j, split="/", fixed = FALSE, perl = FALSE, useBytes = FALSE)), n=2)[1], "_", as.character(Sys.Date()), sep = "")
  
  final<- merge(x=final,y=a,by="V1",all=TRUE)
 
}



write.xlsx(final, "new_result.xlsx")

 





