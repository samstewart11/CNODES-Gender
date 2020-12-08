###################################
# STEP 1: 
#   - Take the publication list and get detailed information about the authors
# INPUT:
#   - a set of publications exported from SCOPUS
#     -- We're only using the internal identifier, EID.  
#     -- You could actually use DOI if you have papers from another source
#   - a SCOPUS API Key    
# OUTPUT: 
#   - a JSON file for articles in your export (useful for future work)
#   - authorNames.csv: All the authors for your papers
library(jsonlite)

#key is your SCOPUS API key, saved in a separate file called keys.R
source("keys.R")

#pubs is the list of publications we're starting with, in our case, the CNODES articles
pubs = read.csv("dataFiles/Publications.csv",skip=12,header=TRUE,stringsAsFactors=FALSE)
pubs = pubs[which(!is.na(pubs$Source.ID)),]

#since the author order information isn't stored correctly in the data we'll #take care of it here
url = "https://api.elsevier.com/content/abstract/eid/%s?apiKey=%s&httpAccept=application/json"

authors = list()
#authors[[i]]=NA #to deal with the problematic authors
#this for loop is complex because, if it errors-out, you can run the line above
#to skip that record and continue
for(i in pubs$EID[which(!pubs$EID%in%names(authors))]){
  cat(i,"\n")
  article = tryCatch(fromJSON(sprintf(url,i,key)),error=function(e) NA)
  if(!is.na(article)){
    write(toJSON(article),file=paste0("dataFiles/ArticleJSONs/article",i,".json"))
    #the author list is store here in the JSON file
    auths = article$`abstracts-retrieval-response`$authors[[1]]
    if(!"ce:given-name"%in%names(auths))
      auths$`ce:given-name` = NA
    auths$EID = i
    #we'll save their first name, last name, index-name, author order number, author ID and paper ID
    authors[[i]] = tryCatch(auths[,c('ce:given-name','ce:surname','ce:indexed-name','@seq','@auid','EID')],error=function(e) cat("\t!can't find ",i,"\n"))
  }
}

#join the list of authors into a single data frame
allAuthors = do.call(rbind.data.frame,authors)
#some articles didn't work, drop them for now
allAuthors = allAuthors[which(!is.na(allAuthors$EID)),]

#some of the articles didn't store the author given names, so I need to use their IDs to go get their first names (as I did before)
url = "https://api.elsevier.com/content/author/author_id/%s?apiKey=%s&httpAccept=application/json"

ind = which(is.na(allAuthors[,'ce:given-name']))

for(i in ind){
  auth = fromJSON(sprintf(url,allAuthors[i,'@auid'],key))
  name = auth$`author-retrieval-response`$`author-profile`$`preferred-name`
  allAuthors[i,'ce:given-name'] = name['given-name']
}
tapply(allAuthors$`@auid`,allAuthors$`ce:indexed-name`,unique)
write.csv(allAuthors,file='authorNames.csv')
