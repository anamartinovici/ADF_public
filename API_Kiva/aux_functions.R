f_get_fundedAmount <- function(input_list) {
    if(is.null(input_list[["loanFundrasingInfo"]][["fundedAmount"]])) {
        # you can change the label 
        return("no_fundedAmount")
    } else {
        return(input_list[["loanFundrasingInfo"]][["fundedAmount"]])	
    }
}
