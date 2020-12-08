###################################
# STEP 2: 
#   - Take the publication list and get detailed information about the authors
# INPUT:
#   - a set of publications exported from SCOPUS
#   - a SCOPUS API Key    
# OUTPUT: 
#   - a JSON file for citing articles in your export (useful for future work)
#   - citingAuthorNames.csv: the names of each author that cited your work


#key is your SCOPUS API key, saved in a separate file called keys.R
source("keys.R")

pubs = read.csv("dataFiles/Publications.csv",skip=12,header=TRUE,stringsAsFactors=FALSE)
pubs = pubs[which(!is.na(pubs$Source.ID)),]

#This is where you SHOULD be able to get the citing papers from the SCOPUS API
#But SCOPUS doesn't make that available, so you'll have to download manually
#The loop below prints the addresses listing the citations for each of your 
#articles, you need to follow the link and 
#download the export of the citing articles

url = "\n%s:\nhttps://www.scopus.com/search/submit/citedby.uri?eid=%s&src=s&origin=recordpage\n"
for(i in pubs$EID){
  cat(sprintf(url,i,i))
}

#for this work I took the 30 CSV files and put them in a single CSV - you could do that as a loop here if you want, it depends on how you download in step above
#dat is a list of all the papers that have cited our work
dat = read.csv("dataFiles/Citing_Articles.csv",stringsAsFactors = FALSE)
names(dat)[1] = 'Authors'

#the citing author IDs aren't in this file, so I need to go get them
#we'll use the same approach as in getAuthorDetail.R
url = "https://api.elsevier.com/content/abstract/eid/%s?apiKey=%s&httpAccept=application/json"

citingAuthors = list()
#authors[[i]]=NA #to deal with the problematic authors
for(i in dat$EID[which(!dat$EID%in%names(citingAuthors))]){
  cat(i,"\n")
  article = tryCatch(fromJSON(sprintf(url,i,key)),error=function(e) NA)
  if(!is.na(article)){
    write(toJSON(article),file=paste0("dataFiles/CitingArticleJSONs/article",i,".json"))
    auths = article$`abstracts-retrieval-response`$authors[[1]]
    if(!"ce:given-name"%in%names(auths))
      auths$`ce:given-name` = NA
    auths$EID = i
    citingAuthors[[i]] = tryCatch(auths[,c('ce:given-name','ce:surname','ce:indexed-name','@seq','@auid','EID')],error=function(e) cat("\t!can't find ",i,"\n"))
  }
}

allCitingAuthors = do.call(rbind.data.frame,citingAuthors)
#some articles didn't work, drop them for now
allCitingAuthors = allAuthors[which(!is.na(allAuthors$EID)),]

#some of the articles didn't store the author given names, so I need to use their IDs to go get their first names (as I did before)
url = "https://api.elsevier.com/content/author/author_id/%s?apiKey=%s&httpAccept=application/json"

ind = which(is.na(allCitingAuthors[,'ce:given-name']))

for(i in ind){
  auth = fromJSON(sprintf(url,allCitingAuthors[i,'@auid'],key))
  name = auth$`author-retrieval-response`$`author-profile`$`preferred-name`
  allCitingAuthors[i,'ce:given-name'] = name['given-name']
}

write.csv(allCitingAuthors,file='citingAuthorNames.csv')