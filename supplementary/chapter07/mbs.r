library(tidyverse)
library(gtools)

# a macro to easy access of the tibble 
get <- defmacro(d, t, k, expr={(d %>% filter(Time==t  & Key == k))$Value})

# pass-through p, coupon c
p <- 0.05
c <- 0.06
n <- 12
cm <- c / 12
pm <- p / 12

k <- 0
dat <- tibble(Time=k, Key="M", Value=1000)

CPP <- function(k) {
    if (k <= 36) return(k/36 * 0.06)
    else return(0.06)
}

while (k < n) {
    k <- k + 1
    SMM <- 1 - (1 - CPP(k))^(1/12) 
    dat <- dat %>% add_row(Time=k, Key="MonthlyPayment", Value = 
                    get(dat, k-1, "M") * cm * (1 + cm)^(n-k+1) / ((1 + cm)^(n-k+1) - 1))
    dat <- dat %>% add_row(Time=k, Key="Prepayment", Value = 
                    (get(dat, k-1, "M") * (1 + cm) - get(dat, k, "MonthlyPayment")) * SMM)
    dat <- dat %>% add_row(Time=k, Key="M", Value = 
                    (get(dat, k-1, "M") * (1 + cm) - get(dat, k, "MonthlyPayment")) * (1 - SMM))
    dat <- dat %>% add_row(Time=k, Key="CF", Value = 
                    get(dat, k, "MonthlyPayment") * (1 - SMM) + 
                    get(dat, k-1, "M") * ((1 + cm) * SMM - (cm - pm)))
}
