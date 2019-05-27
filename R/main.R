if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))

#' Read srt file
#'
#' Read a srt file as a vector, if there is any encoding issue, try to save your srt fle as ANSI encoding using Windows Notepad.
#'
#' @param file character. The name of the file which the subtitles are to be read from.
#' @param encoding character. Encoding to be assumed for input strings, deafult is 'utf-8'.
#' @export
#' @seealso \code{\link[base]{readLines}}
#' @examples
#' # read a ANSI srt file
#' srt_path <- system.file("extdata", "movie.srt", package="SRTtools")
#' srt <- srt.read(srt_path, encoding = 'utf-8')
#'
#'
#'
srt.read <- function(file,encoding= 'utf-8'){
  file <- readLines(file,encoding = encoding)
  return(file)
}

#' Re-synchronize Srt File
#'
#' Shift a srt file with specific time.
#'
#' @param srt vector. The srt file read by \code{\link[SRTtools]{srt.read}}.
#' @param time_shifted numeric. The time that srt file want to be shifted (in seconds).
#' @export
#' @seealso \code{\link[SRTtools]{srt.read}}
#' @examples
#' srt_path <- system.file("extdata", "movie.srt", package="SRTtools")
#' srt <- srt.read(srt_path, encoding = 'utf-8')
#'
#' # Postpone subtitles 3 seconds later
#' srt <- srt.shift(srt, time_shifted = 3)
#'
#' # Expedite subtitles 5 seconds earlier
#' srt <- srt.shift(srt, time_shifted = -5)
#'
srt.shift <- function(srt,time_shifted){
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

#' Srt Output
#'
#' Write the srt file to the system.
#'
#' @param srt vector. The srt file read by \code{\link[SRTtools]{srt.read}}.
#' @param filename Either a character string naming a file or a connection open for writing.
#' @export
#' @seealso \code{\link[SRTtools]{srt.read}}
#' @examples
#' srt_path <- system.file("extdata", "movie.srt", package="SRTtools")
#' srt <- srt.read(srt_path, encoding = 'utf-8')
#'
#' # Postpone subtitles 3 seconds later
#' srt <- srt.shift(srt, time_shifted = 3)
#'
#' # Save and cover original "movie.srt" file
#' srt.write(srt, filename =  file.path(tempdir(), "movie.srt"))
#'
srt.write<-function(srt,filename){
  fileConn<-file(filename)
  writeLines(srt, fileConn)
  close(fileConn)
}

#' Retrieve Subtitle Text
#'
#' Retrieve all the subtitle text content from a srt file
#'
#' @param srt vector. The srt file read by \code{\link[SRTtools]{srt.read}}.
#' @export
#' @seealso \code{\link[SRTtools]{srt.read}}
#' @examples
#' srt_path <- system.file("extdata", "movie.srt", package="SRTtools")
#' srt <- srt.read(srt_path, encoding = 'utf-8')
#'
#' srt.content(srt)
#'
srt.content <- function(srt){
  content_loc <- srt.conten_loc(srt)
  return(srt[content_loc])
}

#' Change Style of Subtitle
#'
#' Change subtitle style or posistion by specific subtitle index.
#'
#' @param srt vector. The srt file read by \code{\link[SRTtools]{srt.read}}.
#' @param line numerical vector. Style will only change the subtitles of the selected subtitle index, default is 'all', means the whole subtitles will apply the style.
#' @param pos character. The subtitles position, the valid options are '\code{bottom-left}', '\code{bottom-center}', '\code{bottom-right}', '\code{middle-left}', '\code{middle-center}', '\code{middle-right}', '\code{top-left}', '\code{top-center}', '\code{top-right}' and '\code{center}'.
#' @param style character vector. The styles that subtitle applied, '\code{u}' for bottom line, '\code{i}' for italic, '\code{b}' for bold, '\code{s}' for strikethrough.
#' @param col character. The color that subtitle applied.
#' @export
#' @seealso \code{\link[SRTtools]{srt.read}}
#' @examples
#' srt_path <- system.file("extdata", "movie.srt", package="SRTtools")
#' srt <- srt.read(srt_path, encoding = 'utf-8')
#' srt.style(srt, line = c(1,3,5), pos = 'top-left', style = c('b','i'), col = 'red')
#'
srt.style <- function(srt, line = "all", pos = "None", style = "None", col = "None"){
  # Position
  pos_heaed <- switch(pos,
                      "None" = "",
                      "bottom-left" = "{\\an1}",
                      "bottom-center" = "{\\an2}",
                      "bottom-right" = "{\\an3}",
                      "middle-left" = "{\\an4}",
                      "middle-center" = "{\\an5}",
                      "middle-right" = "{\\an6}",
                      "top-left" = "{\\an7}",
                      "top-center" = "{\\an8}",
                      "top-right" = "{\\an9}",
                      "center" = "{\\an10}",
               )
  # Style
  if(any(style=="None")){
    style_html <- c("","")
  }else{
    if(!all(style %in% c("u","i","b","s"))){
      stop("Please enter valid html style")
    }else{
      head_ <- ""
      tail_ <- ""
      for(i in style){
        head_ <- paste0(head_,"<",i,">")
        tail_ <- paste0(tail_,"</",i,">")
        style_html <- c(head_,tail_)
      }
    }
  }

  # Color
  if(col=="None"){
    color_html <- c("","")
  }else{
    color_html <- c(paste0("<font color='",col,"'>"),"</font>")
  }

  head_total <- paste0(pos_heaed,style_html[1],color_html[1])
  tail_total <- paste0(style_html[2],color_html[2])
  if(any(line=='all')){
    srt[srt.conten_loc(srt)] <- paste0(head_total,srt[srt.conten_loc(srt)],tail_total)
  }else if(is.numeric(line)){
    srt_index <- sapply(srt,srt_to_numeric)%>%as.numeric
    dialogue_start_loc <- srt_index %in% line %>% which+2
    dialogue_end_loc <- sapply(srt_index[dialogue_start_loc-2]+1,function(x) which(srt_index==x)-1)
    target_dialogue_loc <- mapply(function(a,b) a:b, dialogue_start_loc,dialogue_end_loc) %>% unlist %>% as.vector %>% .[srt[.] != ""]
    srt[target_dialogue_loc] <- paste0(head_total,srt[target_dialogue_loc],tail_total)
  }else{
    stop("Please enter a valid 'line' argument.")
  }
  return(srt)
}

#' Search Index By KeyWord
#'
#' Return the subtitle index by specific keyword
#'
#' @param srt vector. The srt file read by \code{\link[SRTtools]{srt.read}}.
#' @param key_word character. The key word want to be searched in subtitles.
#' @export
#' @seealso \code{\link[SRTtools]{srt.read}}
#' @examples
#' srt_path <- system.file("extdata", "movie.srt", package="SRTtools")
#' srt <- srt.read(srt_path, encoding = 'utf-8')
#' srt.search(srt, key_word = "captain")
#'

srt.search <- function(srt,key_word){
  srt_index <- sapply(srt,srt_to_numeric)%>%as.numeric
  srt_index_loc <- which(!is.na(srt_index))
  return(
    key_word %>% grepl(.,srt) %>% which %>% sapply(.,function(x) srt_index[max(srt_index_loc[srt_index_loc<x])])
  )
}

srt.conten_loc <- function(srt){
  time_stamp_loc <- which(grepl("^[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]$",srt))
  a <- time_stamp_loc+1
  b <- c((time_stamp_loc-2)[-1],length(srt))
  dia_range <- mapply(function(a,b) a:b, a,b)
  if(is.list(dia_range)){
    content_loc<-dia_range %>% do.call(c,.)
  }else{
    content_loc<-dia_range %>% c
  }

  content_loc %<>% .[srt[.]!=""]
  return(content_loc)
}


srt_to_numeric<-function(s){
  tryCatch({
    as.numeric(s)
  },
  warning = function(msg) {
    NA
  }
  )
}
