f_get_fundedAmount <- function(input_list) {
    if(is.null(input_list[["loanFundraisingInfo"]][["fundedAmount"]])) {
        # you can change the label 
        return("no_fundedAmount")
    } else {
        return(input_list[["loanFundraisingInfo"]][["fundedAmount"]])	
    }
}
