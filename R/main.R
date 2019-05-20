#' Read SubRip file
#'
#' Read a srt file as a vector, make sure your srt file is saveing as ANSI encoding using Windows Notepad
#'
#' @param file character. The name of the file which the subtitles are to be read from
#' @param encoding character. Encoding to be assumed for input strings, deafult is 'utf-8'.
#' @export
#' @seealso \code{\link[base]{readLines}}
#' @examples
#' \dontrun{
#'
#' # read a ANSI srt file
#' srt.read <- ("movie.srt" ,encoding= 'utf-8')
#' }
srt.read<-function(file,encoding= 'utf-8'){
  file <- readLines(file,encoding = encoding)
  return(file)
}

srt.shift<-function(srt,time_shifted){
  options("digits.secs"=3)
  time_format <- "%H:%M:%OS"
  time_stamp_loc <- which(grepl("^[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]$",srt))
  srt[time_stamp_loc] <- srt[time_stamp_loc] %>%
    strsplit(.," --> ") %>%
    lapply(.,function(t) sapply(t,function(tt) gsub("\\,","\\.",tt)) %>% as.character) %>%
    lapply(.,function(x) format(strptime(x,format=time_format)+time_shifted,time_format) %>% gsub("\\.","\\,",.)) %>%
    lapply(.,paste,collapse = " --> ") %>%
    do.call(c,.)
  return(srt)
}

srt.write<-function(srt,filename){
  fileConn<-file(filename)
  writeLines(srt, fileConn)
  close(fileConn)
}

srt.content<-function(srt){
  time_stamp_loc <- which(grepl("^[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]$",srt))
  a <- time_stamp_loc+1
  b <- c((time_stamp_loc-2)[-1],length(srt))
  content <- srt[mapply(function(a,b) a:b, a,b)%>% do.call(c,.)]
  content <- content[content!=""]
  return(content)
}



