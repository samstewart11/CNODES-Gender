# Scripts for CNODES Gender Study
The scripts contained in this project are used to reproduce the analysis in our paper [INSERT CITATION HERE]. 

The script is dependent on access to the SCOPUS API, which requires that you have institutional or personal access to SCOPUS services.  To obtain your SCOPUS API key visit https://dev.elsevier.com/

Once access is obtained you need to export the set of citations you want to study - we used a SciVal collection to get the publications we want to study, but any approach will do - the script depends on the SCOPUS EID, and internal ID they use in their holdings.

Once that's complete there are three scripts to execute

1. **getAuthorDetail.R**: Takes the EID for the papers under study and uses the SCOPUS API to get full names and author position information for each Author.
2. **getCitingAuthors.R**: Takes the EID for the papers under study, gets all the papers that cite that paper, and gets the author names and position information for each author.  *NOTE that currently the downloading of citing papers is manual.*  The SCOPUS API does not provide a method for extracting the individual citing papers, so this must be done manually.  I will update this script if this service becomes available
3. **getAuthorGenders.R**: Takes the authors and citing authors and runs them through the service gender-api.com to estimate the genders of each author.

## Inputs for scripts
There are three inputs for these scripts

1.  *Publications.csv*: List of publications under study.  Uses the EID for each paper.
2.  *Citing_CNODES.csv*: List of papers that cite our papers.  `getCitingAuthors.R` should be able to extract these automatically, but that is not the case currently
3.  *keys.R*: Stores two keys - `key` is the SCOPUS API key and `genderKey` is the key for gender-api.com

## Outputs for scripts
1.  *authorNames.csv, citingAuthorNames.csv*: Names of authors extracted from SCOPUS services
2.  *authorNamesWithGender.csv, citingAuthorNamesWithGender.csv*: Names of authors with the genders estimated from gender-api.com
3.  *ArticleJSONs, CitingArticleJSONs*: Folders saving the SCOPUS records for both our articles and the articles that cite our articles.  Not necessary for this study, but useful to have on hand for future research
