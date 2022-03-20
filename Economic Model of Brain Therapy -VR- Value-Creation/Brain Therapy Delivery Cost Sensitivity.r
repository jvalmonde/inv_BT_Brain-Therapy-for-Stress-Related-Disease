##Economic Model of Brain Therapy (VR) Value-Creation

#How does implementation rate affect value created. How does Components within implementation piece affect value created?
#How does share test positive affect value created?
#How does implementation cost affect Value created? How does components within implementation cost affect value created?
per_indiv_cost <- c(251, 640, 344, 610, 1401, 1659, 627, 1163, 466, 11023, 730)
eligible_prev <- c(.312, .006, .477, .154, .02, .192, .308, .024, .09, .032, .364)
sum(eligible_prev)
sum(per_indiv_cost)

test_cost <- 20
sensitivity<- .8
specificity<- .2


target_prev <- eligible_prev*sensitivity/(eligible_prev*sensitivity+(1-eligible_prev)*(1-specificity))

potential_target_saving <- per_indiv_cost*target_prev

share_test_iden <- sensitivity*eligible_prev[1]+(1-specificity)*(1-eligible_prev[1])


identification_cost <- test_cost/ share_test_iden

treatment_efficacy <- rep(.60, 11)


treatment_cost <- 250



delivery_mechanism <- c("Doctor Recommends Intervention",
                        "Patient Opts in", 
                        "Patient Adheres to Content")
delivery_share <-c(.9,
                   .8,
                   .9)
delivery_cost <- c(25,
                   0,
                   treatment_cost,
                   60)

sigmoid = function(c){(1/(1+exp(-c/15+3))-.18/(1+exp(-c*1/15+1))+.11)*100}







vc <- c()
cost <-c()
 
  
for(i in seq(0,250)){
  
  
  delivery_cost[4]=i
  delivery_share[3] <- sigmoid(i)/100
  
  
  delivery_cumulative <- cumprod(delivery_share)
  implement_cost <- delivery_cost[1]+sum(c(delivery_cumulative[-length(delivery_share)],delivery_cumulative[length(delivery_share)-1])*delivery_cost[-1])
  implement_rate <- delivery_cumulative[length(delivery_share)]
  effectiveness <- treatment_efficacy * implement_rate
  expected_savings <- sum(potential_target_saving*effectiveness)
  value_created <- expected_savings - implement_cost -identification_cost

  vc <- c(vc, value_created)
  cost<-c(cost, implement_cost +identification_cost)
}





plot(seq(0,250), vc, ty='l',lwd=2,
     xlab="Cost of Compliance Support ($)", ylab="Value Created ($)",
     xlim=c(0,250),
     col=3,
     main="Effects of Compliance Support Cost on Value Created",
     ylim= c(min(vc),max(vc)))
abline(h=0, lty=2)

(0:250)[vc==max(vc)]
(0:250)[vc>0]

#upper bound at 90, lower bound at 10%

#11% base effectiveness
#93% ceiling efficacy
#Current Assumed Efficacy 67% with cost of $60
sigmoid = function(c){(1/(1+exp(-c/15+3))-.18/(1+exp(-c*1/15+1))+.11)*100}
plot(0:200, sigmoid(0:200), ylim=c(0,100), ty='l',lwd=2,col="gold",
     xlab="Cost of Compliance Support ($)",ylab="Compliance Rate (%)",
     main="Cost Effectiveness of Compliance Support")
points(x= 60, y= sigmoid(60),pch='x', col="blue")
lines(-10:210, rep(100,length(-10:210)), col="gray60",lty=2)
abline(h=0,lty=2)

sigmoid(60)
sigmoid(0)
sigmoid(125:200)
(0:200)[sigmoid(0:200)>92.5]
vc[125:200]
