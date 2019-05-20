library(magrittr)
srt.read<-function(srtfile,encoding= 'utf-8'){
  # Make sure srt file is saving as ANSI encoding using Windows Notepad 
  file <- readLines(srtfile,encoding = encoding)
  return(file)
}

srt.shift<-function(srtfile,time_shifted){
  options("digits.secs"=3)
  time_format <- "%H:%M:%OS"
  time_stamp_loc <- which(grepl("^[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]$",srtfile))
  srtfile[time_stamp_loc] <- srtfile[time_stamp_loc] %>%
    strsplit(.," --> ") %>%
    lapply(.,function(t) sapply(t,function(tt) gsub("\\,","\\.",tt)) %>% as.character) %>%
    lapply(.,function(x) format(strptime(x,format=time_format)+time_shifted,time_format) %>% gsub("\\.","\\,",.)) %>%
    lapply(.,paste,collapse = " --> ") %>%
    do.call(c,.)
  return(srtfile)
}

srt.write<-function(srtfile,filename){
  fileConn<-file(filename)
  writeLines(srtfile, fileConn)
  close(fileConn)
}

srt.content<-function(srtfile){
  time_stamp_loc <- which(grepl("^[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]$",srtfile))
  a <- time_stamp_loc+1
  b <- c((time_stamp_loc-2)[-1],length(srtfile))
  content <- srtfile[mapply(function(a,b) a:b, a,b)%>% do.call(c,.)]
  content <- content[content!=""]
  return(content)
}



