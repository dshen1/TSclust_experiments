library(TSclust)
library(quantmod)
library(dplyr)
library(pipeR)
library(tidyr)
library(epiwidgets)

sp5 <- getSymbols("^GSPC",auto.assign=F,from="1900-01-01")[,4]

sp5 %>>%
  # dplyr doesn't like xts, so make a data.frame
  (
    data.frame(
      date = index(.)
      ,roc = .[,1,drop=T]/lag(.[,1,drop=T],k=1)
    )
  ) %>>%
  # add a column for Year
  mutate( year = as.numeric(format(date,"%Y"))) %>>%
  # group by our new Year column
  group_by( year ) %>>%
  # within each year, find what day in the year so we can join
  mutate( pos = rank(date) ) %>>%
  # can remove date
  select( -date ) %>>%
  as.data.frame %>>%
  # years as columns as pos as row
  spread( year, price ) %>>%
  # remove last year since assume not complete
  ( .[,-ncol(.)] ) %>>%
  # remove pos since index will be same
  select( -pos ) %>>%
  # fill nas with previous value
  na.fill( "extend" ) %>>%
  t %>>%
  # use TSclust diss; notes lots of METHOD options
  diss( METHOD="ACF" ) %>>%
  hclust %>>%
  ape::as.phylo() %>>% 
  treewidget %>>%
  htmlwidgets::as.iframe(tf,file="index.html",standalone=F,libdir = "./lib")
