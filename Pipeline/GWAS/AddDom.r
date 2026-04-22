########################################################################################################################
### The AddDom Model of ADDO:
### 1. PLINK Input Format: (1) file.bed & file.bim & file.fam (2) file.phe (1st column name should be individual id;
### From the 2nd column should start by covariates columns and then phenotype columns; The sex column should coded 
### as female=0 and male=0) (3) file.covs (Two columns files; The 1st column is phenotype names; The 2nd column is
### the corresponding covariates and each covariates should be separated by comma.)
### 2. GenABEL Input Format: file.ABEL.dat (Just contain one GenABEL type variable named "dat") & file.covs (The 
### format of phenotype file and covariates file should be prepared as above)
### 3. Required Softwares: plink (v.1.90) & gcta64 (v.1.26) (emmax-kin/gemma/ just install needed one)
### 4. Depended Packages: data.table, parallel, bigmemory, mvtnorm (only required by the Heterotic Model), MASS
### (only required by the Heterotic Model), GenABEL (optional), emma (optional) 
########################################################################################################################

rm(list=ls());options(stringsAsFactors=FALSE)

# [1] Load library #
library(ADDO)
source("R/ADDO_AddDom1_QC.r")
source("R/ADDO_AddDom2_Pvalue.r")
source("R/ADDO_AddDom3_Plot.r")
source("R/plotGWAS.r")
source("R/plotRegion.r")

# [2] Specify directory and covariates types variable #
system("mkdir 1_AddDom 2_Heterotic") 
indir = paste0(getwd(),"/data"); outdir = paste0(getwd(),"/1_AddDom")
#covariates_types = c("n","n","n","f"); names(covariates_types) = c("PC1","PC2","PC3","PeakSNP")
covariates_types = c("n","n","n"); names(covariates_types) = c("PC1","PC2","PC3")

# [3] Use three functions one by one #
ADDO_AddDom1_QC(indir=indir, outdir=outdir, Phe_HistogramPlot=T, Input_name="SNP.INDEL.SV", Input_type="PLINK", Kinship_type="GCTA_ad", Phe_ResDone = F, Phe_NormDone = F, Normal_method = "QUANTILE", covariates_sum=3, covariates_types=covariates_types, Phe_IndMinimum = 50, Phe_Extreme = 5, GT_maf = 0.05, GT_missing = 0.1, num_nodes=40)

ADDO_AddDom2_Pvalue(indir=indir, outdir=outdir, Phe_HistogramPlot=T, Input_name="SNP.INDEL.SV", Kinship_type="GCTA_ad", VarComponent_Method="GCTA_ad", Run_separated=T, covariates_sum=3, Phe_IndMinimum=50, GT_IndMinimum=5, matrix_acceleration=T, logP_threshold=0, num_nodes=40)

ADDO_AddDom3_Plot(outdir=outdir, covariates_sum=3, RegionMan_chr_whole=F, RegionMan_chr_region=300000, chrs_sum=39, Down_sampling=F)

#ADDO_AddDom4_IntePlot(outdir=outdir, covariates_sum=3, RegionMan_chr_whole=F, RegionMan_chr_region=2000000, chrs_sum=21, Down_sampling=F)


