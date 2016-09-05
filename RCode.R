setwd('~/Desktop/Neuro_R/Data')

#########################################################################
##oro.nifti is the 'workhorse' package for structural MRI analysis in R  
#########################################################################

library(oro.nifti)

#########################################################################
##Read in the baseline data
#########################################################################

##Baseline data##
MPRAGE_base <- readNIfTI('SUBJ0001-01-MPRAGE.nii.gz', reorient=FALSE)


#########################################################################
##Dimension of the image
#########################################################################

dim(MPRAGE_base)
MPRAGE_base
slotNames(MPRAGE_base)


#########################################################################
##Visulaize the Data 
#########################################################################

##axial slice##
image(MPRAGE_base[,,128])

##coronal slice##
image(MPRAGE_base[,128,], col = rainbow(12))

##sagittal slice##
image(MPRAGE_base[85,,], col = topo.colors(12))


#########################################################################
##Using orthographic function (from oro.nifti package)
#########################################################################

orthographic(MPRAGE_base)
orthographic(MPRAGE_base, xyz = c(90, 100, 15))



#########################################################################
##Load in follow-up study data 
#########################################################################

MPRAGE_follow <- readNIfTI('SUBJ0001-02-MPRAGE.nii.gz', reorient=FALSE)



#########################################################################
##Plot baseline and followup data
#########################################################################

library(fslr) 

##plot the data together 

double_ortho(MPRAGE_base, MPRAGE_follow)

##plot the difference between the baseline and follow up data 

MPRAGE_diff <- MPRAGE_base - MPRAGE_follow

MPRAGE_diff 

orthographic(MPRAGE_diff )


#########################################################################
## Process the data using fslr 
#########################################################################

##set path to FSL 

options(fsl.path= "/Applications/fsl/")


#########################################################################
## Inhomogenity Correction with fslr 'fsl_biascorrect'
#########################################################################


## MPRAGE_base_bias_corrected <- fsl_biascorrect(MPRAGE_base) 

## writeNIfTI(MPRAGE_base_bias_corrected, filename = 
##             'SUBJ0001-01-MPRAGE_bias_corr', verbose = TRUE, gzipped = TRUE)


MPRAGE_base_bias_corrected <- readNIfTI('SUBJ0001-01-MPRAGE_bias_corr.nii.gz', reorient=FALSE)

bias_diff <- MPRAGE_base_bias_corrected  - MPRAGE_base

orthographic(bias_diff)


#########################################################################
## Skull strip with fslr using 'fslbet'
#########################################################################


MPRAGE_base_bias_corrected_stripped <- fslbet(MPRAGE_base_bias_corrected) 

##plot 

double_ortho(MPRAGE_base, MPRAGE_base_bias_corrected_stripped)


##make a brain mask from the skull stripped image 

bet_mask <- niftiarr(MPRAGE_base_bias_corrected_stripped, 1)
is_in_mask = MPRAGE_base_bias_corrected_stripped>0
bet_mask[!is_in_mask]<-NA

##plot 

orthographic(MPRAGE_base_bias_corrected ,bet_mask)

##write the brain mask 

writeNIfTI(bet_mask, filename = 
             "brain_mask", verbose = TRUE, gzipped = TRUE)

#########################################################################
## Registration of the followup to the baseline with a rigid registration
#########################################################################


MPRAGE_follow_reg_base <- flirt(MPRAGE_follow, MPRAGE_base, dof = 6, 
      retimg = TRUE, reorient = FALSE)


MPRAGE_reg_diff <- MPRAGE_base - MPRAGE_follow_reg_base

double_ortho(MPRAGE_diff, MPRAGE_reg_diff)
