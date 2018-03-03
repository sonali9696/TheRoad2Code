BEGIN {
	recvdSize = 0
	startTime = 0
	stopTime = 0
	sent=0
	receive=0
    agtCount=0
    rtrCount=0


    startCount=0
    endCount=0
}

{
    event = $1
  time = $2
  node_id = $3
  pkt_size = $8
  level = $4

  if (( $1 == "r") && ( $7 == "cbr" || $7 =="tcp" ) && ( $4=="AGT" ))  agtCount++;

  if (($1 == "s") && $4 == "RTR") rtrCount++;
  
  if (level == "AGT" && event == "s" && $7 == "cbr") {
    sent++;
    if (!startTime || (time < startTime)) {
      startTime = time
    }
    startTimeArr[startCount] = $2;
    startCount++;
  }

  if (level == "AGT" && event == "r" && $7 == "cbr") {
    receive++;
    if (time > stopTime) {
      stopTime = time
    }
    recvdSize += pkt_size
    endTimeArr[endCount] = $2;
    endCount++;
  }

  if (level == "AGT" && event == "d" && $7 == "cbr") {
    endTimeArr[$35] = -1;
  }

}

END {
  count = 0
  for(i=0;i<startCount;i++) {
    if(endTimeArr[i] > 0){
        delay[i] = endTimeArr[i] - startTimeArr[i];
        count++;
    }
    else
    {
        delay[i] = -1;
    }
  }

  endToEndDelay = 0;
  for(i=0; i<count; i++) {
   if(delay[i] > 0) {
    endToEndDelay = endToEndDelay + delay[i];
   }
  }
  endToEndDelay = endToEndDelay/count;
  printf("Sent\t %d\n",sent)
  printf("Received %d\n",receive)
  printf("Dropped %d\n",sent-receive)  
  printf("PDR %.2f\n",(receive/sent)*100);
  printf("Average Throughput[kbps] = %.2f\tStartTime=%.2f\tStopTime = %.2f\n", (recvdSize/(stopTime-startTime))*(8/1000),startTime,stopTime);
  printf("Normalized Load\t %0.3f\n",((agtCount*1.0)/rtrCount));
  print "Average End-to-End Delay = " endToEndDelay * 1000 " ms";

}
