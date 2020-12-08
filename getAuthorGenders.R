#######################################
# Step 3: getting author genders
# Given that GENDER-API is a pay-per-process service, you might choose 
# to upload the CSV file directly at gender-api.com to avoid duplicate 
# charges.  The process below is if you want to use the API
# INPUTS: 
# - two author files, one for our authors, one for citing authors
# - gender-api key
# OUTPUTS:
# - two author files, with gender estimated
#######################################
allAuthors = read.csv("authorNames.csv")
allCitingAuthors = read.csv("citingAuthorNames.csv")
rownames(allAuthors) = allAuthors[,1]
allAuthors = allAuthors[,-1]
rownames(allCitingAuthors) = allCitingAuthors[,1]
allCitingAuthors = allCitingAuthors[,-1]

#genderKey is the gender API key is saved in a separate file called keys.R
source("keys.R")#genderKey
genderUrl = "https://gender-api.com/get?name=%s&key=%s"

allAuthors$ga_samples = allAuthors$ga_accuracy = allAuthors$ga_gender = allAuthors$ga_first_name = NA

for(i in which(is.na(allAuthors$ga_first_name))){
  cat(i,"\n")
  guess = tryCatch(fromJSON(sprintf(genderUrl,allAuthors$ce.given.name[i],genderKey)),error=function(e) NA)
  if(!is.na(guess)){
    out = c(guess$name_sanitized, guess$gender, guess$accuracy, guess$samples)
    allAuthors[i,c("ga_first_name", "ga_gender", "ga_accuracy",  "ga_samples")] = out
  }
}

write.csv(allAuthors,file='authorNamesWithGender.csv')

allCitingAuthors$ga_samples = allCitingAuthors$ga_accuracy = allCitingAuthors$ga_gender = allCitingAuthors$ga_first_name = NA

for(i in which(is.na(allCitingAuthors$ga_first_name))){
  cat(i,"\n")
  guess = tryCatch(fromJSON(sprintf(genderUrl,allCitingAuthors$ce.given.name[i],genderKey)),error=function(e) NA)
  if(!is.na(guess)){
    out = c(guess$name_sanitized, guess$gender, guess$accuracy, guess$samples)
    allCitingAuthors[i,c("ga_first_name", "ga_gender", "ga_accuracy",  "ga_samples")] = out
  }
}

write.csv(allCitingAuthors,file='citingAuthorNamesWithGender.csv')
