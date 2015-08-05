args <- commandArgs()
dataTable <-read.table(args[5], header=TRUE);
ratio<-data.frame(dataTable)
#head(ratio$interval)
#ploidy <- type.convert(args[4])
libname <- type.convert(args[4])
outfilename=paste(args[5],".pdf",sep = "")
#png(filename = paste(args[5],".png",sep = ""), width = 1180, height = 1180,
#    units = "px", pointsize = 20, bg = "white", res = NA)

img_width=8
img_high=12	
pdf(outfilename,width=img_width,height=img_high)

#bottom, left, top, right : default 5,4,4,2
#mar = c(4.1, 3.1, 0.5, 2.1)
op <- par(mfrow = c(7,1), mar = c(4.1, 5.5, 0.5, 0.5), oma = c(0.5, 0.5, 5, 1), mgp=c(2,1,0))
#op <- par(mfrow = c(7,1), mgp=c(2,1,0))
#par(mar = c(5.1, 4.1, 0.1, 2.1))
#par(oma = c(0, 0, 2, 0))

#mtext("This belongs to the title", side=3, line=1)
chrlist<-c("chr2L", "chr2R", "chr3L", "chr3R", "chrX", "chrY", "chr4")
#Chrom,interval, insert_score, insert_reads, depletion_score, depeltion_reads

for (j in seq(along=chrlist)) {
	i<-chrlist[j]
	tt <- which(ratio$Chrom==i)
#	xmax <-max(ratio$interval[tt])
#head(xmax)
#[525] "palevioletred1" 
#colors()[24] = black
#colors()[136]) = red
# colors()[461] = blue
# colors()[88]) = "darkolivegreen3" 
# colors()[430]) = "lightskyblue"
#xlim = c(0,xmax)

	if (length(tt)>0) {	
	plot(ratio$interval[tt],ratio$insert_score[tt],ylim = c(-2.5,2.5), cex=2, xlab = paste(i),ylab ="", yaxt="n", pch = ".",col = colors()[88], type="n")
#	axis(2,at=-2:2, las=2, labels=c("dep"letters[1:5]))
#	axis(2,at=-2:2, las=2, labels=c("Dep.CR>4 ", "Dep.CR<=4", "", "Ins.CR>4 ", "Ins.CR<=4"))
	axis(2,at=c(-2, -1, 1,2), las=2, labels=c("Del.CR>4 ", "Del.CR<=4", "Ins.CR<=4 ", "Ins.CR>4"))
	abline(h=0, col=c("black"), lty=1, lwd=0.5)


	 tt <- which(ratio$Chrom==i  & ratio$insert_score==1 &  ratio$insert_reads<=10)
	 points(ratio$interval[tt],ratio$insert_score[tt],pch =".",cex=2,col = c("lightpink"))

	 tt <- which(ratio$Chrom==i  & ratio$insert_score==1 &  ratio$insert_reads>10)
	 points(ratio$interval[tt],ratio$insert_score[tt],pch =".",cex=2,col = c("red"))



	 tt <- which(ratio$Chrom==i  & ratio$insert_score==2 &  ratio$insert_reads<=10)
	 points(ratio$interval[tt],ratio$insert_score[tt],pch =".",cex=2,col = c("lightpink"))

	 tt <- which(ratio$Chrom==i  & ratio$insert_score==2 &  ratio$insert_reads>10)
	 points(ratio$interval[tt],ratio$insert_score[tt],pch =".",cex=2,col = c("red"))

#TE depletion points

	tt <- which(ratio$Chrom==i  & ratio$depletion_score==-1 &  ratio$depletion_reads<=10)
	points(ratio$interval[tt],ratio$depletion_score[tt],pch =".",cex=2,col = c("lightblue"))


	tt <- which(ratio$Chrom==i  & ratio$depletion_score==-1 &  ratio$depletion_reads>10)
	points(ratio$interval[tt],ratio$depletion_score[tt],pch =".",cex=2,col = c("blue"))


	tt <- which(ratio$Chrom==i  & ratio$depletion_score==-2 &  ratio$depletion_reads<=10)
	points(ratio$interval[tt],ratio$depletion_score[tt],pch =".",cex=2,col = c("lightblue"))

	tt <- which(ratio$Chrom==i  & ratio$depletion_score==-2 &  ratio$depletion_reads>10)
	points(ratio$interval[tt],ratio$depletion_score[tt],pch =".",cex=2,col =  c("blue"))



	}
}
text_val <- paste("    TIDAL-FLY v1.0 -  TE Indel Genome Chart                 ", libname, "                      please cite: Rahman et al.")
mtext(text_val, side=3, line=1, outer=TRUE)
#mtext("Please Cite: Rahman et. al.", side=3, line=2, outer=TRUE, font=10)
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
