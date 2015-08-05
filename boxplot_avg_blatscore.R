#R --no-restore --no-save --no-readline $1 < $HOME/CORE/NGS/plot_qc.R


args <- commandArgs();      # retrieve args
arg_length=length(args)
args
tab <- read.table(args[5],header=F, skip=1, sep="")
head(tab)
head(tab$V11)
max(tab$V11)
#dev.off()

pdf("boxplot_avg_score.pdf", height=7, width=7)
boxplot(tab$V11, las=2, names=c("library"))
dev.off()