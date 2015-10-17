args <- commandArgs()
dataTable <-read.table(args[5], header=TRUE);
ratio<-data.frame(dataTable)
#ploidy <- type.convert(args[4])
libname <- type.convert(args[4])
outfilename=paste(args[5],".pdf",sep = "")
#png(filename = paste(args[5],".png",sep = ""), width = 1180, height = 1180,
#    units = "px", pointsize = 20, bg = "white", res = NA)

img_width=8
img_high=12	
pdf(outfilename,width=img_width,height=img_high)

#plot(1:10)
#op <- par(mfrow = c(5,5))
#two graphs per row
#bottom, left, top, right : default 5,4,4,2
#mar = c(4.1, 3.1, 0.5, 2.1)
op <- par(mfrow = c(7,1), mar = c(4.1, 5.5, 0.5, 0.5), oma = c(0.5, 0.5, 5, 1), mgp=c(2,1,0))

#op <- par(mfrow = c(7,1))
#par(mar = c(5.1, 4.1, 0.1, 2.1))
#par(oma = c(0, 0, 2, 0))

chrlist<-c("2L", "2R", "3L", "3R", "X", "Y", "4")
#chrlist<-c("2L", "2R", "3L", "3R", "X", "U","4")
#for (i in (1:22)) {
for (j in seq(along=chrlist)) {
	i<-chrlist[j]


	tt <- which(ratio$Chromosome==i)
	if (length(tt)>0) {
	 plot(ratio$Start[tt],ratio$Ratio[tt],ylim = c(-1,3),cex=2,xlab = paste ("chr",i),ylab = "normalized ratio profile",pch = ".",col = colors()[88])

	 tt <- which(ratio$Chromosome==i  & ratio$Ratio>1.25 )
	 points(ratio$Start[tt],ratio$Ratio[tt],pch = ".",cex=2,col = colors()[136])
	 tt <- which(ratio$Chromosome==i  & ratio$Ratio<0.75 )
	 points(ratio$Start[tt],ratio$Ratio[tt],pch = ".",cex=2,col = colors()[461])
	 tt <- which(ratio$Chromosome==i)
	#points(ratio$Start[tt],ratio$CopyNumber[tt], pch = ".", col = colors()[24])
	}
}

text_val <- paste("    TIDAL-FLY v1.0 -  CNV Ratio Genome Chart                ", libname, "                  please cite: Rahman et al.")
mtext(text_val, side=3, line=1, outer=TRUE)

#i <- 'X'
#tt <- which(ratio$Chromosome==i)
#if (length(tt)>0) {
#	plot(ratio$Start[tt],ratio$Ratio[tt]*ploidy,ylim = c(0,3*ploidy),xlab = paste ("position, chr",i),ylab = "normalized copy number profile",pch = ".",col = colors()[88])
#	tt <- which(ratio$Chromosome==i  & ratio$CopyNumber>ploidy )
#	points(ratio$Start[tt],ratio$Ratio[tt]*ploidy,pch = ".",col = colors()[136])
#	tt <- which(ratio$Chromosome==i  & ratio$CopyNumber<ploidy )
#	points(ratio$Start[tt],ratio$Ratio[tt]*ploidy,pch = ".",col = colors()[461])
#	tt <- which(ratio$Chromosome==i)
#	#points(ratio$Start[tt],ratio$CopyNumber[tt], pch = ".", col = colors()[24])
#}
#i <- 'Y'
#tt <- which(ratio$Chromosome==i)
#if (length(tt)>0) {
#	plot(ratio$Start[tt],ratio$Ratio[tt]*ploidy,ylim = c(0,3*ploidy),xlab = paste ("position, chr",i),ylab = "normalized copy number profile",pch = ".",col = colors()[88])
#	tt <- which(ratio$Chromosome==i  & ratio$CopyNumber>ploidy )
#	points(ratio$Start[tt],ratio$Ratio[tt]*ploidy,pch = ".",col = colors()[136])
#	tt <- which(ratio$Chromosome==i  & ratio$CopyNumber<ploidy )
#	points(ratio$Start[tt],ratio$Ratio[tt]*ploidy,pch = ".",col = colors()[461])
#	tt <- which(ratio$Chromosome==i)
#	#points(ratio$Start[tt],ratio$CopyNumber[tt],pch = ".", col = colors()[24])
#}
dev.off()
