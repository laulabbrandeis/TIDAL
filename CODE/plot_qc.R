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
# pie3D(slices,labels=lbls,explode=0.1, main="Sequence duplication ")
#
#
#
  abt_file_name=paste(file_name,".abt",sep="",collapse=NULL)
  abt_tab <- read.table(abt_file_name,header=F)
  names(abt_tab)<-c("Read","Count")

  par(mar=c(2,0,8,2))
  main_title=args[5]
  main_title=paste(main_title,"Most abuandant reads",sep=": ")
  plot(c(0,maxx),c(1,22),type='n',main=main_title,xlab="",ylab="",cex.main=1.0,cex.lab=0.8,cex.axis=0.4,axes=FALSE)
  counts <- abt_tab$Count[1:20]
  reads <- abt_tab$Read[1:20]

# par(las=2)
# par(mar=c(5,20,4,2))
# text(1, 0, "Text in the Middle")
  reads=paste(reads,counts, sep = ": ", collapse = NULL)
  reads=paste(reads,round(counts*100/read_count, digits = 2), sep = " (", collapse = NULL)
  reads=paste(reads,"%)", sep = "", collapse = NULL)
  for(i in c(1:20)){
    reads[i]=paste(i,reads[i], sep = ". ", collapse = NULL)
    text(1, 22-i, reads[i],adj = c(0,0),cex = .80)
  }

#
#
#
  mer7_file_name=paste(file_name,".7mer",sep="",collapse=NULL)
  mer7_tab <- read.table(mer7_file_name,header=F)
  names(mer7_tab)<-c("Pattern","FrqCount","LineCount","Ratio")

  counts <- mer7_tab$LineCount[1:20]*100/read_count
  pattern <- mer7_tab$Pattern[1:20]
  par(las=2)
  par(mar=c(5,8,4,2))
  main_title=args[5]
  main_title=paste(main_title,"Most frequent 7-mers",sep=": ")
  barplot(counts, main=main_title,ylab="",xlab="Frequency (%)",names.arg=pattern,cex.names=0.8,col=heat.colors(10),horiz=TRUE) 
#
#
#
  mer8_file_name=paste(file_name,".8mer",sep="",collapse=NULL)
  mer8_tab <- read.table(mer8_file_name,header=F)
  names(mer8_tab)<-c("Pattern","FrqCount","LineCount","Ratio")

  counts <- mer8_tab$LineCount[1:20]*100/read_count
  pattern <- mer8_tab$Pattern[1:20]
  par(las=2)
  par(mar=c(5,8,4,2))
  main_title=args[5]
  main_title=paste(main_title,"Most frequent 8-mers",sep=": ")
  barplot(counts, main=main_title,ylab="",xlab="Frequency (%)",names.arg=pattern,cex.names=0.8,col=heat.colors(10),horiz=TRUE) 

q()
  lines(tab$read_length,tab$total_read_before_miRNA_removal,col="blue")
  lines(tab$read_length,tab$total_read_after_miRNA_removal,col="red")
  lines(tab$read_length,tab$total_read_mapped_to_genome,col="green")
  lines(tab$read_length,tab$total_read_uniquely_mapped_to_genome,col="gold")
  legend(x=minx+(maxx-minx)*1/40,y=miny+(maxy-miny)*39/40,c(total_read,"total read before miRNA removal","total read after miRNA removal","total read mapped to genome (after miRNA removal)","total read uniquely mapped to genome (after miRNA removal)"),cex=0.3,col=c("black","blue","red","green","gold"),lty=c(0,1,1,1,1))

q()
  
args[5]
q()
  x <- c(1:as.string(args[5])); # get the 4th argument
x
q()
  y <- c(x^2);                # work out square
  png(filename="image.png");  # create image file
  plot(x,y);                  # plot image

  window_size=10

# sink("sink.out")
  map <- read.table("inp",header=T)
  names(map)<-c("chr","start","stop","totl_read_p","totl_read_m","totl_read","uniq_read_p","uniq_read_m","uniq_read","norm_read_p","norm_read_m","norm_read")


  all_gene=read.table("fly_repeat.bed",header=F)
  names(all_gene)=c("chr","start","stop","symbol","dummy","strain")
  all_gene=unique(all_gene[c(1,2,3,4,6)])
  all_geneindex=which(all_gene$stop>=0)
  all_genlen=length(all_geneindex)
  minx=min(all_gene$start[all_geneindex])
  maxx=max(all_gene$stop[all_geneindex])
  xq=quantile(all_gene$stop[all_geneindex])
xq
  pdf("repeat_plot.pdf",width=img_width,height=img_high)

cur_gene=376
# for(cur_gene in 1:all_genlen){
  for(cur_gene in 1:100){
    RegionChro=all_gene$chr[all_geneindex[cur_gene]]
print(RegionChro)
flush.console()
    RegionStart=all_gene$start[all_geneindex[cur_gene]]
    RegionEnd=all_gene$stop[all_geneindex[cur_gene]]
#   image_file=paste(RegionChro,".pdf", sep = "", collapse = NULL)

    mapindex=which(map$chr==RegionChro & map$start>=RegionStart-10 & map$stop<=RegionEnd+10)
    mapindex=mapindex[sort(map$start[mapindex],index.return=TRUE)$ix]
    maplen=length(mapindex)
maplen

#   minx=min(map$start[mapindex])
#   maxx=max(map$start[mapindex])
    currmaxx=max(map$start[mapindex])
#   if(currmaxx<xq[2])     maxx=xq[2]
#   else if(currmaxx<xq[3])maxx=xq[3]
#   else if(currmaxx<xq[4])maxx=xq[4]
#   else                   maxx=xq[5]
    if(currmaxx<=500)      maxx=500
    else                   maxx=ceiling(currmaxx/1000)*1000

##y=0.0369174x+55.197476
# left_px<-round(0.0369174*img_width+55.197476)
##y=0.9628196x-27.30042
# rite_px<-round(0.9628196*img_width-27.30042)
# resolution<-rite_px-left_px+1
# resolution<-trunc(resolution/2)
# resolution=600
    resolution=round((maxx-minx+1)/window_size)
    if(maxx-minx<resolution)resolution=maxx-minx
#   pdf(image_file,width=img_width,height=img_high)
    par(mfrow=c(4,1),cex.lab=2,cex.axis=1.5,cex.main=2)
resolution
    totl_read_p=round(sum(map$totl_read_p[mapindex]))
    totl_read_m=round(sum(map$totl_read_m[mapindex]))
    totl_read  =round(sum(map$totl_read  [mapindex]))
    uniq_read_p=round(sum(map$uniq_read_p[mapindex]))
    uniq_read_m=round(sum(map$uniq_read_m[mapindex]))
    uniq_read  =round(sum(map$uniq_read  [mapindex]))
    norm_read_p=round(sum(map$norm_read_p[mapindex]))
    norm_read_m=round(sum(map$norm_read_m[mapindex]))
    norm_read  =round(sum(map$norm_read  [mapindex]))
    m=1
    n=window_size
    while(n<maplen){
      mdx=mapindex[m:n]
      map$totl_read_p[mapindex[m]]=sum(map$totl_read_p[mdx])
      map$totl_read_m[mapindex[m]]=sum(map$totl_read_m[mdx])
      map$uniq_read_p[mapindex[m]]=sum(map$uniq_read_p[mdx])
      map$uniq_read_m[mapindex[m]]=sum(map$uniq_read_m[mdx])
      map$norm_read_p[mapindex[m]]=sum(map$norm_read_p[mdx])
      map$norm_read_m[mapindex[m]]=sum(map$norm_read_m[mdx])
      m=n+1
      n=n+window_size
    }
# if(resolution<(maxx-minx)){
#   for(i in 2:resolution){
#     n=trunc(i*maplen/resolution)
#     mdx=mapindex[m:(n-1)]
#     map$totl_read_p[mapindex[m]]=sum(map$totl_read_p[mdx])
#     map$totl_read_m[mapindex[m]]=sum(map$totl_read_m[mdx])
#     map$uniq_read_p[mapindex[m]]=sum(map$uniq_read_p[mdx])
#     map$uniq_read_m[mapindex[m]]=sum(map$uniq_read_m[mdx])
#     map$norm_read_p[mapindex[m]]=sum(map$norm_read_p[mdx])
#     map$norm_read_m[mapindex[m]]=sum(map$norm_read_m[mdx])
#print(c(i,m,n-1,map$totl_read_p[mapindex[m]]))
#flush.console()
#     m=n
#   }
# }


#    min(map$start[mapindex]), max(map$totl_read_p[mapindex])                              max(map$start[mapindex]), max(map$totl_read_p[mapindex])
#    ---------------------------------------------------------------------------
#    |                                                                         |
#    |                                                                         |
#    |     Total count                                                         |
#    |                                                                         |
#    |                                                                         |
#    ---------------------------------------------------------------------------
#    min(map$start[mapindex]), 0-max(map$totl_read_m[mapindex])                            max(map$start[mapindex]), 0-max(map$totl_read_m[mapindex])
#    
#
#    min(map$start[mapindex]), max(map$totl_read_p[mapindex])-value_height                 max(map$start[mapindex]), max(map$totl_read_p[mapindex])-value_height
#
    miny=0-max(map$totl_read_m[mapindex])
    maxy=max(map$totl_read_p[mapindex])
miny
maxy

    value_height=maxy-miny

    title=paste(RegionChro,", Total (length > 16), ",totl_read, ",   +:", totl_read_p, ",   -:",totl_read_m,sep="")
    plot(c(minx,maxx,maxx,minx,minx),c(miny,miny,maxy,maxy,miny),type="n",main=title,xlab="",ylab="")
    m=1
    n=window_size
    while(n<maplen){
      if(map$totl_read_p[mapindex[m]]>0)lines(c(map$start[mapindex[m]],map$start[mapindex[m]]),c(0                             ,map$totl_read_p[mapindex[m]]),col="red")
      if(map$totl_read_m[mapindex[m]]>0)lines(c(map$start[mapindex[m]],map$start[mapindex[m]]),c(0-map$totl_read_m[mapindex[m]],0                           ),col="blue")
      m=n+1
      n=n+window_size
    }
# m=1
# for(i in 2:resolution){
#   n=trunc(i*maplen/resolution)
#   if(map$totl_read_p[mapindex[m]]>0)lines(c(map$start[mapindex[m]],map$start[mapindex[m]]),c(0                             ,map$totl_read_p[mapindex[m]]),col="red")
#   if(map$totl_read_m[mapindex[m]]>0)lines(c(map$start[mapindex[m]],map$start[mapindex[m]]),c(0-map$totl_read_m[mapindex[m]],0                           ),col="blue")
#   m=n
# }


#    min(map$start[mapindex]), max(map$uniq_read_p[mapindex])                              max(map$start[mapindex]), max(map$uniq_read_p[mapindex])
#    ---------------------------------------------------------------------------
#    |                                                                         |
#    |                                                                         |
#    |     Unique count                                                        |
#    |                                                                         |
#    |                                                                         |
#    ---------------------------------------------------------------------------
#    min(map$start[mapindex]), 0-max(map$uniq_read_m[mapindex])                            max(map$start[mapindex]), 0-max(map$uniq_read_m[mapindex])
#    
#
#    min(map$start[mapindex]), max(map$uniq_read_p[mapindex])-value_height                 max(map$start[mapindex]), max(map$uniq_read_p[mapindex])-value_height
#
# miny=0-max(map$uniq_read_m[mapindex])
# maxy=max(map$uniq_read_p[mapindex])
    value_height=maxy-miny

#   title=paste("16 < Read length < 24, ",RegionChro, ":", minx, "-",maxx,sep="")
    title=paste(RegionChro,", 16 < Read length < 24, ",uniq_read, ",   +:", uniq_read_p, ",   -:",uniq_read_m,sep="")
    plot(c(minx,maxx,maxx,minx,minx),c(miny,miny,maxy,maxy,miny),type="n",main=title,xlab="",ylab="")
    m=1
    n=window_size
    while(n<maplen){
      if(map$uniq_read_p[mapindex[m]]>0)lines(c(map$start[mapindex[m]],map$start[mapindex[m]]),c(0                             ,map$uniq_read_p[mapindex[m]]),col="red")
      if(map$uniq_read_m[mapindex[m]]>0)lines(c(map$start[mapindex[m]],map$start[mapindex[m]]),c(0-map$uniq_read_m[mapindex[m]],0                           ),col="blue")
      m=n+1
      n=n+window_size
    }
# m=1
# for(i in 2:resolution){
#   n=trunc(i*maplen/resolution)
#   if(map$uniq_read_p[mapindex[m]]>0)lines(c(map$start[mapindex[m]],map$start[mapindex[m]]),c(0                             ,map$uniq_read_p[mapindex[m]]),col="red")
#   if(map$uniq_read_m[mapindex[m]]>0)lines(c(map$start[mapindex[m]],map$start[mapindex[m]]),c(0-map$uniq_read_m[mapindex[m]],0                           ),col="blue")
#   m=n
# }

#    min(map$start[mapindex]), max(map$norm_read_p[mapindex])                              max(map$start[mapindex]), max(map$norm_read_p[mapindex])
#    ---------------------------------------------------------------------------
#    |                                                                         |
#    |                                                                         |
#    |     Normalized count                                                    |
#    |                                                                         |
#    |                                                                         |
#    ---------------------------------------------------------------------------
#    min(map$start[mapindex]), 0-max(map$norm_read_m[mapindex])                            max(map$start[mapindex]), 0-max(map$norm_read_m[mapindex])
#
#
#    min(map$start[mapindex]), max(map$norm_read_p[mapindex])-value_height                 max(map$start[mapindex]), max(map$norm_read_p[mapindex])-value_height
#
# miny=0-max(map$norm_read_m[mapindex])
# maxy=max(map$norm_read_p[mapindex])
    value_height=maxy-miny

#   title=paste("Read length >=24, ",RegionChro, ":", minx, "-",maxx,sep="")
    title=paste(RegionChro,", Read length >=24, ",norm_read, ",   +:", norm_read_p, ",   -:",norm_read_m,sep="")
    plot(c(minx,maxx,maxx,minx,minx),c(miny,miny,maxy,maxy,miny),type="n",main=title,xlab="",ylab="")
    m=1
    n=window_size
    while(n<maplen){
      if(map$norm_read_p[mapindex[m]]>0)lines(c(map$start[mapindex[m]],map$start[mapindex[m]]),c(0                                   ,map$norm_read_p[mapindex[m]]),col="red")
      if(map$norm_read_m[mapindex[m]]>0)lines(c(map$start[mapindex[m]],map$start[mapindex[m]]),c(0-map$norm_read_m[mapindex[m]],0                                 ),col="blue")
      m=n+1
      n=n+window_size
    }
# m=1
# for(i in 2:resolution){
#   n=trunc(i*maplen/resolution)
#   if(map$norm_read_p[mapindex[m]]>0)lines(c(map$start[mapindex[m]],map$start[mapindex[m]]),c(0                                   ,map$norm_read_p[mapindex[m]]),col="red")
#   if(map$norm_read_m[mapindex[m]]>0)lines(c(map$start[mapindex[m]],map$start[mapindex[m]]),c(0-map$norm_read_m[mapindex[m]],0                                 ),col="blue")
#   m=n
# }

#    min(map$start[mapindex]), max(map$norm_read_p[mapindex])                              max(map$start[mapindex]), max(map$norm_read_p[mapindex])
#    ---------------------------------------------------------------------------
#    |                                                                         |
#    |                                                                         |
#    |     Gene plot                                                           |
#    |                                                                         |
#    |                                                                         |
#    ---------------------------------------------------------------------------
#    min(map$start[mapindex]), 0-max(map$norm_read_m[mapindex])                            max(map$start[mapindex]), 0-max(map$norm_read_m[mapindex])
#
#
#    min(map$start[mapindex]), max(map$norm_read_p[mapindex])-value_height                 max(map$start[mapindex]), max(map$norm_read_p[mapindex])-value_height
#
    geneindex=which(all_gene$chr==RegionChro & ((all_gene$start>minx-10 & all_gene$start<=maxx+10) | (all_gene$stop>minx-10 & all_gene$stop<=maxx+10)) )
    genlen=length(geneindex)
    geneindex=geneindex[sort(all_gene$start[geneindex],index.return=TRUE)$ix]
#chr4    53433   64403   plexB   0       -       53643   64050   0       5       318,183,584,4770,864,   0,383,3066,3708,10106,

    gap=10
    maxy=0
    miny=0-genlen*100-2*gap
    plot(c(minx,maxx,maxx,minx,minx),c(miny,miny,maxy,maxy,miny),type="n",main="",xlab="",ylab="",axes=FALSE)
    arrow_thickness=min(3,ceiling(200/genlen))
    text_size=max(min(2,ceiling(60*10/genlen)/10),2)
    for(i in 1:genlen){
      if(all_gene$strain[geneindex[i]]=="-"){
        arrows(all_gene$start[geneindex[i]],(0-i*100-gap),all_gene$stop[geneindex[i]] ,0-i*100-gap,length=0.3,angle=15,code=1,lwd=arrow_thickness)
        text(all_gene$start[geneindex[i]],0-i*100-gap+gap,labels=all_gene$symbol[geneindex[i]],cex=text_size,adj=c(0,0))
      }
      if(all_gene$strain[geneindex[i]]=="+"){
        arrows(all_gene$stop[geneindex[i]] ,(0-i*100-gap),all_gene$start[geneindex[i]],0-i*100-gap,length=0.3,angle=15,code=1,lwd=arrow_thickness)
        text(all_gene$start[geneindex[i]],0-i*100-gap+gap,labels=all_gene$symbol[geneindex[i]],cex=text_size,adj=c(0,0))
      }
      temp1 = paste("Window size=",round((maxx-minx)/resolution), sep = "")
      temp1 = paste(temp1,", length=",currmaxx,"bp", sep = "")
      text(minx,miny,temp1,cex=1.8,adj=c(0,0))
    }
 }
 dev.off()




  
q()
seq(-1,1.3,length.out=8)
length(mapindex)
  if(RMPos$V6[te[1]]=="-" )rect(RMPos$V4[te[1]],-0.5,RMPos$V5[te[1]],0,col="red",border=NA)
  if(RMPos$V6[te[1]]=="+" )rect(RMPos$V4[te[1]],0,RMPos$V5[te[1]],0.5,col="black",border=NA)
  if(length(te)>0){ #just make sure that we have some elements in the vector "te"
  for(j in 1:length(te)){
#plot first the TE on the + strand:
#arrows take as input the x1, y1, x2, y2. x1 is the start of the TE, x2 is the end. y1 and y2 depend on the index of the element in the list "te". There is a small modulo operator, to avoid as much as possible overlapping arrows. Small tricks, doesn't work perfectly all the times. Could require some adjustments...

# if(RMPos$V6[te[j]]=="+" & RMPos$Size[te[j]]>20)arrows(RMPos$V4[te[j]],seq(-1,1.3,length.out=8)[j%%9+1],RMPos$V5[te[j]],seq(-1,1.3,length.out=8)[j%%9+1],length=.05,angle=30,code=2)
# if(RMPos$V6[te[j]]=="-" & RMPos$Size[te[j]]>20)arrows(RMPos$V4[te[j]],seq(-1,1.3,length.out=8)[j%%9+1],RMPos$V5[te[j]],seq(-1,1.3,length.out=8)[j%%9+1],length=.05,angle=30,code=1)

  if(RMPos$V6[te[j]]=="-" )rect(RMPos$V4[te[j]],-0.5,RMPos$V5[te[j]],0,col="red",border=NA)
  if(RMPos$V6[te[j]]=="+" )rect(RMPos$V4[te[j]],0,RMPos$V5[te[j]],0.5,col="black",border=NA)

# if the size is bigger than 500, write the name of the element:
if(RMPos$Size[te[j]]>500)text((RMPos$V4[te[j]]+RMPos$V5[te[j]])/2,seq(-1,1.3,length.out=8)[j%%9+1]+0.1,labels=RMPos$V7[te[j]],cex=.7)
}}
#dev.off()
#q()
#
#
## Say you want to represent the TE on a region defined by RegionChro, RegionStart and RegionEnd
#
#
#
#Then there are two possible representations of the TE:
#With some arrows representing the orientation of the TE. (In this example, I only represent the TE whose size is bigger than 200nt)
#
#
#
#
#
##           V1           V2    V3     V4     V5 V6      V7 Size
##1  IDEFIX_LTR    LTR/Gypsy chr2L   9726   9859  +  IDEFIX  133
##2  DNAREP1_DM DNA/Helitron chr2L   9889   9993  - DNAREP1  104
##3  DNAREP1_DM DNA/Helitron chr2L  15866  15955  - DNAREP1   89
##4  DNAREP1_DM DNA/Helitron chr2L  24236  24484  + DNAREP1  248
##5  DNAREP1_DM DNA/Helitron chr2L  27529  27771  - DNAREP1  242
##6   LINEJ1_DM  LINE/Jockey chr2L  47514  52519  +  LINEJ1 5005
##7  DNAREP1_DM DNA/Helitron chr2L  60251  60631  + DNAREP1  380
##8  DNAREP1_DM DNA/Helitron chr2L  60656  60786  + DNAREP1  130
##9         BS2  LINE/Jockey chr2L  64316  64914  +     BS2  598
##10 DNAREP1_DM DNA/Helitron chr2L 116520 116980  + DNAREP1  460
##
