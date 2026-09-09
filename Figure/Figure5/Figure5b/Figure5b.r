#if (!require("CMplot")) install.packages("CMplot")
library(CMplot)
library(data.table)

files = list.files(pattern = '*.txt')
for (file in files){
	file_name = gsub("^Pvalue_|.txt$","", file)
	y_name = paste0('-log10(P)',' ',file_name)
	data = fread(file,header=T)
	data = as.data.frame(data)
	data = data[,c(1,2,4)]
	names(data) = c('CHR','POS','P_Dom')
	data$SNP = paste0(data$CHR,':',data$POS)
	data = na.omit(data)
	data = data[,c(4,1,2,3)]
	region_data = data[data$CHR == 1 & data$POS >131820000 & data$POS < 131830000,]
	max_P = region_data[which.max(region_data$P_Dom),]
	topSNP = max_P$SNP
	col.A = c('#ED7A6A','#DEAEBF','#F49568')
	col.D = c('#638DEE','#66C999','#77DCDD')
	CMplot(data,plot.type='m',LOG10=F,col = col.D,
		threshold=c(-log10(0.05/1000000),-log10(1/1000000)),
		threshold.lty = c(1,2),threshold.lwd = c(1,1),threshold.col=c('#23B2E0','black'),
		signal.col = c('orange','green'),signal.cex = 0.5,
		cex = 0.5,band=0.1,
		ylab = y_name,
		highlight = topSNP,highlight.col = 'red', highlight.cex = 1.5,
		#highlight.text = topSNP,  #显示SNP的文本
		amplify=T,multracks=F,
		file='pdf',file.name=file_name,file.output=T,dpi = 300)
	col.QQ.A = '#F47F72'
	p_value = 10^-data$P_Dom
	z = qnorm(p_value/2)
	lambda = round(median(z^2,na.rm = TRUE)/0.4549,3)
	QQ_main_name = paste0(file_name,'(λ=',lambda,')')
	CMplot(data,plot.type="q",conf.int.col='grey',LOG10=F,box=FALSE,
		file="pdf",file.name=file_name,main = QQ_main_name,file.output=TRUE,dpi=300,verbose=TRUE)
	}
