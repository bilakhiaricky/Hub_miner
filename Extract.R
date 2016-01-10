# 0. Set up the query 
#install.packages('httpuv')
#install.packages("httr")
#install.packages("gsubfn")
#library(gsubfn)

install.packages("devtools")
require(devtools)
install_github("cscheid/rgithub")
library(github)

library(httpuv)
library(httr)

ctx = interactive.login("198d187asd90332401997", "d8ff7770f38adaed7d72a35ec9db4e74240f09ca")
oauth_endpoints("github")
myapp <- oauth_app("github",
                   key = "198d187asd0332401997",
                   secret = "d8ff7770f38ad4ed7d72a35ec9db4e74240f09ca")
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/rate_limit", gtoken)
stop_for_status(req)
content(req)
req$url
req$status_code
splitted_str<-strsplit(req$url,"=")[[1]]
splitted_str[2]
create.github.context(api_url = "https://api.github.com", client_id = "198d187eb90332401997",
                      client_secret = "d8ff7770f3ad24ed7d72a35ec9db4e74240f09ca", 
                      access_token = splitted_str[2], 
                      max_etags = 10000, verbose = FALSE)

owner = "rubinius"
repo = "rubinius"

data_fetched <- data.frame(  "ID" = integer(), "WEBLINK" = character(),"COMMENTS" = character(),stringsAsFactors=FALSE)
for (issues_no in seq(1,3556)){
  tryCatch({
  first_comment <- get.repository.issues(owner, repo,issue.number = issues_no,ctx = get.github.context())
  count_comments<-as.numeric(first_comment$content$comments)
    if((count_comments <= 100)){
      data_fetched[nrow(data_fetched) + 1, ] <- c( issues_no,first_comment$content$html_url,gsub("[\r\n\t]"," ",first_comment$content$body))
    other_comment<- get.all.repository.issues.comments(owner, repo,issue.number = issues_no, ctx = get.github.context(), per_page=100)
    for (w in seq(1:count_comments)){
      data_fetched[nrow(data_fetched) + 1, ] <- c( issues_no,other_comment$content[[w]]$html_url,gsub("[\r\n\t]"," ",other_comment$content[[w]]$body))
    }
  }else if(count_comments > 100){
    no_pages<- count_comments/100
    remain_count <- count_comments%%100
    for (q in seq(1:no_pages)){
      other_comment<- get.all.repository.issues.comments(owner, repo,issue.number = issues_no, ctx = get.github.context(), per_page=100, page=q)
      for (r in seq(1:100)){
        data_fetched[nrow(data_fetched) + 1, ] <- c( issues_no,other_comment$content[[r]]$html_url,gsub("[\r\n\t]"," ",other_comment$content[[r]]$body))
      }
    }
    other_comment<- get.all.repository.issues.comments(owner, repo,issue.number = issues_no, ctx = get.github.context(), per_page=100, page=(q+1))
    for (e in seq(1:remain_count)){
      data_fetched[nrow(data_fetched) + 1, ] <- c( issues_no,other_comment$content[[e]]$html_url,gsub("[\r\n\t]"," ",other_comment$content[[e]]$body))
      }
  }
  }, error = function(err) {
    
    # error handler picks up where error was generated
    print(paste("MY_ERROR:  ",err,"for id",issues_no))
  }) 
}

write.csv(data_fetched,"rubinus_final.csv",row.names = F)
read_rubinus_data<- read.csv("rubinus_final.csv",header = T)





