###############################################################################################
##                                                                                           ##
##                                                                                           ##
##                        Export and filter papers published in                              ##
##                              "Institution X" indexed in PubMed                            ##
##                                                                                           ##
###############################################################################################
## Define Pubmed Query: You can use Pubmed tool to create your query and test for the result. Copy paste your query inside '' (as a string).
PubMedQuery <- '((Insitution X[Affiliation]) OR (Other name[Affiliation])) AND (("1900/01/01"[Date - Publication] : "3000"[Date - Publication]))'

## Load Libraries
require(dplyr)
require(tidyr)
require(easyPubMed)


PubMedQuery <- '((Insitution X[Affiliation]) OR (Other name[Affiliation])) AND (("1900/01/01"[Date - Publication] : "3000"[Date - Publication]))'

## Run the query on Pubmed
my_query <- get_pubmed_ids(PubMedQuery)

## Download data from Pubmed by 500-item batches - Depends on the nimber of item you expect the xml size grows quite rapidly. 
## Check my_query length in case of doubt.

my_batches <- seq(from = 1, to = my_query$Count, by = 500)
my_abstracts_xml <- as.character(lapply(my_batches,  function(i) {
  fetch_pubmed_data(my_query, retmax = 600, retstart = i)  
}))


## Manipulate data to extract a usable table where eitheir first or last author is at the aforementionned Institution X

Papers_by_first <- table_articles_byAuth(pubmed_data = my_abstracts_xml, 
                                   included_authors = "first", 
                                   encoding = "ASCII")
Papers_by_last <- table_articles_byAuth(pubmed_data = my_abstracts_xml, 
                                     included_authors = "last", 
                                     encoding = "ASCII")
Papers_first_X <- filter(Papers_by_first, grepl('Institution X', address))
Papers_first_X <- mutate(Papers_first_X, position = "First")

Papers_last_X <- filter(Papers_by_last, grepl('Institution X', address))
Papers_last_X <- mutate(Papers_last_X , position = "Last")
new_Papers <- bind_rows(Papers_first_X, Papers_last_X)

## The resulting dataframe will contains duplicate papers if both the first and last authors are from Institution X.
## The column "position" will be useful to identify this situation.


## Export as csv if you like
write.csv2(noduplicate, file="myfile.csv")

############################################################################################################################## 
# > sessionInfo()
# R version 3.6.0 (2019-04-26)
# Platform: x86_64-pc-linux-gnu (64-bit)
# Running under: Ubuntu 16.04.6 LTS
# 
# Matrix products: default
# BLAS:   /usr/lib/atlas-base/atlas/libblas.so.3.0
# LAPACK: /usr/lib/atlas-base/atlas/liblapack.so.3.0
# 
# locale:
#  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8        LC_COLLATE=C.UTF-8    
#  [5] LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8    LC_PAPER=C.UTF-8       LC_NAME=C             
#  [9] LC_ADDRESS=C           LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
# 
# attached base packages:
# [1] stats     graphics  grDevices utils     datasets  methods   base     
# 
# other attached packages:
# [1] easyPubMed_2.13 tidyr_1.0.3     dplyr_0.8.5    


