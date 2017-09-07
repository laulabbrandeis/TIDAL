# library(plotrix)

  args <- commandArgs();      # retrieve args
  arg_length=length(args)

  file_name=args[5]
  qc_file_name=paste(file_name,".qc",sep="",collapse=NULL)
  tab <- read.table(qc_file_name,header=T)
  names(tab)<-c("Position","Minimum","Lower_whisker","Q1","Median","Q3","Upper_whisker","Maximum","Mean","Stdev","A","C","G","T","N","X")

  read_length=nrow(tab)
  read_count=tab$A[1]+tab$C[1]+tab$G[1]+tab$T[1]+tab$N[1]+tab$X[1]

  img_width=11
  img_high=8

  minx=1
  maxx=read_length
  miny=min(tab$Minimum)
  maxy=max(tab$Maximum)
  yoff=miny
  main_title=args[5]
  main_title=paste(main_title,read_count,sep=", Read count: ")
  main_title=paste(main_title,read_length,sep=", Read length: ")
  out_file_name=paste(file_name,".pdf",sep="",collapse=NULL)
  pdf(out_file_name,width=img_width,height=img_high)

  par(mar=c(6,6,6,6))
  plot(c(minx,maxx),c(miny-yoff,maxy-yoff),type='n',main=main_title,xlab="Position",ylab="Quality",cex.main=1.0,cex.lab=0.8,cex.axis=0.4,axes=FALSE)
# txt=paste("Total reads: ", sep="", read_count)
# text(minx, maxy+2, "XXXXXX" ,adj = c(0,0),cex = .80)
# txt=paste("Read length: ", sep="", read_length)
# text(minx, maxy-4, txt ,adj = c(0,0),cex = .80)
  axis(1,at=minx:maxx              ,cex.axis=0.4,tck=0.01,pos=miny-1-yoff)
  axis(3,at=minx:maxx              ,cex.axis=0.4,tck=0.01,pos=maxy+1-yoff)
  axis(2,at=(miny-yoff):(maxy-yoff),cex.axis=0.4,tck=0.01,pos=minx-2)
  axis(4,at=(miny-yoff):(maxy-yoff),cex.axis=0.4,tck=0.01,pos=maxx+2)
  for(i in seq(minx,maxx,by=2)){
    rect(i-0.5,miny-yoff,i+0.5,20       ,col="pink"         ,border=NA)
    rect(i-0.5,20       ,i+0.5,28       ,col="khaki1"       ,border=NA)
    rect(i-0.5,28       ,i+0.5,maxy-yoff,col="darkseagreen1",border=NA)
  }
  for(i in seq(minx+1,maxx,by=2)){
    rect(i-0.5,miny-yoff,i+0.5,20       ,col="lightpink1"     ,border=NA)
    rect(i-0.5,20       ,i+0.5,28       ,col="lightgoldenrod2",border=NA)
    rect(i-0.5,28       ,i+0.5,maxy-yoff,col="palegreen"      ,border=NA)
  }
  for(i in c(minx:maxx)){
    q1=tab$Q1[i]-yoff
    q3=tab$Q3[i]-yoff
    rect(i-0.4,q1,i+0.4,q3,col="gold",border="goldenrod")
    upper=tab$Upper_whisker[i]-yoff
    lower=tab$Lower_whisker[i]-yoff
    lines(c(i,i),c(lower,q1),col="black")
    lines(c(i,i),c(q3,upper),col="black")
    lines(c(i-0.3,i+0.3),c(lower,lower),col="black")
    lines(c(i-0.3,i+0.3),c(upper,upper),col="black")
    median=tab$Median[i]-yoff
    lines(c(i-0.4,i+0.4),c(median,median),col="red")
    minimum=tab$Minimum[i]-yoff
    points(i,minimum,type="p",lwd=1)
    maximum=tab$Maximum[i]-yoff
    points(i,maximum,type="p",lwd=1)
  }
  for(i in c(minx+1:maxx)){
    mean1=tab$Mean[i-1]
    mean2=tab$Mean[i]
    lines(c(i-1,i),c(mean1,mean2),type="l")
  }

  par(mar=c(6,6,6,2))
  main_title=args[5]
  main_title=paste(main_title,"Nucleotide Contents",sep=": ")
  plot(c(minx,maxx+9),c(0,100),type='n',main=main_title,,xlab="Position",ylab="Content(%)",cex.main=1.0,cex.lab=0.8,cex.axis=0.4,axes=FALSE)
  axis(1,at=minx:maxx,cex.axis=0.4,tck=0.01,pos=-1)
  axis(3,at=minx:maxx,cex.axis=0.4,tck=0.01,pos=101)
  axis(2,at=seq(0,100,by=10),cex.axis=0.8,tck=0.01,pos=minx-2)
  axis(4,at=seq(0,100,by=10),cex.axis=0.8,tck=0.01,pos=maxx+2)
  for(i in c(minx:maxx)){
    a_count=tab$A[i]
    c_count=tab$C[i]
    g_count=tab$G[i]
    t_count=tab$T[i]
    n_count=tab$N[i]
    x_count=tab$X[i]
    total_count=a_count+c_count+g_count+t_count+n_count+x_count
    a_count=a_count*100/total_count
    t_count=t_count*100/total_count+a_count
    c_count=c_count*100/total_count+t_count
    g_count=g_count*100/total_count+c_count
    n_count=n_count*100/total_count+g_count
    rect(i-0.4,0      ,i+0.4,a_count,col="red",border=NA)
    rect(i-0.4,a_count,i+0.4,t_count,col="orange",border=NA)
    rect(i-0.4,t_count,i+0.4,c_count,col="green",border=NA)
    rect(i-0.4,c_count,i+0.4,g_count,col="blue",border=NA)
    rect(i-0.4,g_count,i+0.4,n_count,col="black",border=NA)
    lines(c(minx-2,maxx+2),c(25,25),col="black",lty=2)
    lines(c(minx-2,maxx+2),c(50,50),col="black",lty=1)
    lines(c(minx-2,maxx+2),c(75,75),col="black",lty=2)
    legend("topright",c("N","G","C","T","A"),cex=0.7,col=c("black","blue","green","orange","red"),fill=c("black","blue","green","orange","red"),bg="white")
  }

  minn=min(tab$N)
  maxn=max(tab$N)*1.05
  par(mar=c(6,6,6,2))
  main_title=args[5]
  main_title=paste(main_title,"Unknown nucleotide count",sep=": ")
# plot(c(minx,maxx),c(minn,maxn),type='n',main="Unknown nucleotide count" ,xlab="Position",ylab="N count",cex.main=1.0,cex.lab=0.8,cex.axis=0.4,axes=FALSE)
  plot(c(minx,maxx),c(minn,maxn),type='n',main=main_title ,xlab="Position",ylab="N count",cex.main=1.0,cex.lab=0.8,cex.axis=0.8,xaxt="n")
  axis(1,at=minx:maxx,cex.axis=0.4,tck=0.01,pos=minn-1)
  axis(3,at=minx:maxx,cex.axis=0.4,tck=0.01,pos=maxn+1)
# axis(2,at=seq(minn,maxn,by=100),cex.axis=0.8,tck=0.01,pos=minx-2)
# axis(4,at=seq(minn,maxn,by=100),cex.axis=0.8,tck=0.01,pos=maxx+2)
  for(i in c(minx+1:maxx)){
    n1=tab$N[i-1]
    n2=tab$N[i]
    lines(c(i-1,i),c(n1,n2),type="l",col="orange")
  }
#
#
#
  stat_file_name=paste(file_name,".stat",sep="",collapse=NULL)
  stat_tab <- read.table(stat_file_name,header=T)
  names(stat_tab)<-c("Freq","Count")

  lbls=stat_tab$Freq
  slices=stat_tab$Count
  pct <- round(slices/sum(slices)*100)
  lbls <- paste(lbls, sep=": ", pct) # add percents to labels
  lbls <- paste(lbls,"%",sep="") # ad % to labels
  main_title=args[5]
  main_title=paste(main_title,"Sequence duplication",sep=": ")
  pie(slices,labels = lbls, col=rainbow(length(lbls)), main=main_title) 
