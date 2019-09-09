# Remove the existing variables from the environment
rm(list=ls())

# Set the current directory
setwd("C:/Users/hohanyan/Desktop/Scrap_Beeline&Ucom")


# Install and load the necessary packages
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
#install.packages("Xmisc")
library(Xmisc)

# Scrap the tariff plan links and store them into a list
download.file('https://www.beeline.am/hy/mobile-tariffs/', 'blabla.html')
content <- read_html("blabla.html")
links <- content %>% html_nodes(., "a") %>% html_attr("href")
links_new <- list(links[grepl("https://www.beeline.am/hy/mobile-tariffs/[A-Zb-z]+",links, perl=TRUE)])

# Create a function for scraping the  tariff prices (stored in a tabular form)
scrap_table <- function(url){
  download.file(url,destfile = "result.html")
  tariff<- readHTMLTable("result.html", which=1)
  if (nrow(tariff)<5){
    content <- read_html('result.html')
    a <- content %>% html_nodes("div.static-content") %>% html_nodes("p") %>% html_text()
    b <- list(a[grepl("- \\d+ դրամ",a, perl=TRUE)|grepl("-\\d+ դրամ",a, perl=TRUE)])
    b1<-as.data.frame(b)
    names(b1)[1]<-"new_name"
    tariff <-data.frame(str_split_fixed(b1$new_name, "-", 2))
  }
  print(tariff)
}

# Remove the variable final (in case it exists)
rm(final)

# Run the function for the first link
final <- scrap_table(links_new[[1]][1])

# Change the column names for the table (resulting from the first link)
colnames(final)[2] <- paste(tail(unlist(strsplit(links_new[[1]], split="/", fixed = FALSE, perl = FALSE, useBytes = FALSE)), n=2)[1], "_", as.character(Sys.Date()), sep = "")

# Loop over each item of the list and merge the resulting table to the previous one
for (j in links_new[[1]][2:length(links_new[[1]])]){
  print(j)
  a <- scrap_table(j)
  colnames(a)[2] <- paste(tail(unlist(strsplit(j, split="/", fixed = FALSE, perl = FALSE, useBytes = FALSE)), n=2)[1], "_", as.character(Sys.Date()), sep = "")
  final<- merge(x=final,y=a,by="V1",all=TRUE)
  
}

#final1 <- final
#final <- final1

# Remove the " դրամ" from all the cells
final[, 2:24] <- lapply(final[,2:24], gsub, pattern='դրամ', replacement="") %>% lapply(., gsub, pattern='/ՄԲ', replacement='') %>% 
  lapply(., gsub, pattern='/ՄԲ', replacement='') %>% lapply(., gsub, pattern=',', replacement='.') %>% lapply(., gsub, pattern=' ', replacement='') %>%
  lapply(., gsub, pattern=' ', replacement='')
# final[] <- lapply(final, gsub, pattern='դրամ', replacement='')
# final[] <- lapply(final, gsub, pattern='/ՄԲ', replacement='')
# final[] <- lapply(final, gsub, pattern=',', replacement='.')
# final[] <- lapply(final, gsub, pattern=' ', replacement='')

# Convert columns (besides the first one) to numeric
final[,2:24] <- lapply(final[,2:24], function(x) as.numeric(as.character(x)))

# Change the name of the first column
colnames(final)[1] <- "Ծառայության անվանումը"

# Export the results to an .xlsx file
write.xlsx(final, "new_resultթ.xlsx")
shell.exec("new_resultթ.xlsx")



#### ####
library(openxlsx)
wb <- createWorkbook("new.xlsx")
i <- 1
for (j in links_new[[1]]){
  print(j)
  addWorksheet(wb, unlist(strsplit(j, "/"))[6], gridLines = TRUE)
  writeData(wb, as.data.frame(scrap_table(j)), sheet = unlist(strsplit(j, "/"))[6])
}
saveWorkbook(wb, "new.xlsx", overwrite = TRUE)
