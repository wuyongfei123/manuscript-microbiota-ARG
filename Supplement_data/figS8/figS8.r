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
	col.QQ.D = '#638DEE'
	p_value = 10^-data$P_Dom
	z = qnorm(p_value/2)
	lambda = round(median(z^2,na.rm = TRUE)/0.4549,3)
	QQ_main_name = paste0(file_name,'(λ=',lambda,')')
	CMplot(data,plot.type="q",conf.int.col='grey',LOG10=F,box=FALSE,
		file="pdf",file.name=file_name,main = QQ_main_name,file.output=TRUE,dpi=300,verbose=TRUE)
	}
