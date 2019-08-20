# R_MedPC Converter

This is a step-by-step guide for using the MEDPC Converter created by Wendy Huynh. Please download the files in yhuynh/R_MedPC (https://github.com/yhuynh2/R_MedPC) by clicking on the "Clone or download" green button. You must download it as a ZIP file; afterwards, you may extract these files out of the ZIP folder and place them wherever you choose. 

1. Download R (https://www.r-project.org/) and RStudio (https://www.rstudio.com/products/rstudio/download/) to your computer (they're free programs)

2. Open RStudio and execute the following commands in the _console_. To execute commands in R, type them _one at a time_ in the console and press the ENTER key. Each command will take some time to execute (<3 minutes). 

`install.packages("tidyverse")`

`install.packages("splitstackshape")`

`install.packages("writexl")`

3. Open the MedPC Converter.R file. This file will automatically open in RStudio.

4. Locate the MedPC files for conversion in your File Explorer (Windows PC) or Finder (Mac); we will call this the DATA FOLDER. Ensure that there are no other files/folders in DATA FOLDER, ONLY MedPC data files! If there are other files in the DATA FOLDER (Excel, Word, PDF, etc.), move these non-MedPC files elsewhere.

5. Copy the file path for the DATA FOLDER. 

  - For Windows PCs, this can be done by right clicking on the DATA FOLDER, selecting Properties, and highlighting/copying the text for "Location". 

  - For Mac computers, right click on the DATA FOLDER, select Get Info, and highlighting/copying the text for "Where". 

6. Return to RStudio and scroll down on the MedPC Converter file to the section reading: "Modify Path Code ONLY"

7. Paste your copied file path to line 70. Edit your file path, changing all "`\`" to "`/`". 

8. Cut and paste your DATA FOLDER file path to **REPLACE** `/Users/wendy/Box Sync/Bevins Lab/MedPC2XL Converter/Practice Data` with _your_ edited file path.

9. Line 52 should now display similar to this (notice the quotations!):
`pathcode <- "/Users/UserNameHere/DATA FOLDER"`

10. Highlight lines 1 through 68 and execute the code (CTRL + ENTER). The console will print out a truncated list of files that R will convert. Check that this looks generally correct (correct MedPC file names).

11. If the short list of names printed in the console looks correct, THEN highlight lines 56 to 231 and execute the code (using CTRL + ENTER). This section of code will take longer to execute, depending on the number of files you are converting.

12. If you are familiar with R, make sure to change the working directory before saving the object named final as an .xlsx files. If you are unfamiliar with R, execute the following code to save your converted data:

`library(writexl)`

`write_xlsx(final, str_c("Converted Data ", str_replace_all(Sys.time(), ":", "-")))`

The code above will save your converted files as an .xlsx (Excel) file in your DATA FOLDER. The title of the Excel file will be contain the current date (year-month-day) and time (hour-min-sec). Next, **move this .xlsx file OUT of DATA FOLDER** for the MedPC2XL converter to work next time. This is because this converter will not ignore non-MedPC files and try to convert them, resulting in an error.


If you are interested in learning how to force R to rename the columns and select only relevant columns, please refer to the `rename()` and `select()` functions derived from the tidyverse package. There are lots of resources online for learning the tidyverse method of coding in R! Here is an example for how I retain only relevant variables and rename them:

`relevant.data <- 
  final %>% 
  select(S1, Subject, MSN, Start.Date, S0, S2, Experiment, Group, Box, D,
         J0,J1,J2,J3,J4,J5,J6,J7,
         K0,K1,K2,K3,K4,K5,K6,K7,
         L0,L1,L2,L3,L4) %>% 
  rename(Day = S1,
         StartDate = Start.Date,
         Test_yn = S0,
         Macro = S2,
         Group = Experiment,
         Sex = Group,
         InitBlackOut = D,
         DE_ITI = J0,
         DE_Pre = J1,
         DE_CS = J2,
         DE_elev = J3,
         DE_Total = J4,
         DEperSec.ITI = J5,
         DEperSec.Pre = J6,
         DEperSec.CS = J7,
         DUR_ITI = K0,
         DUR_Pre = K1,
         DUR_CS = K2,
         DUR_elev = K3,
         DUR_Total = K4,
         DURperSec.ITI = K5,
         DURperSec.Pre = K6,
         DURperSec.CS = K7,
         ACT_ITI = L0,
         ACT_Pre = L1,
         ACT_CS = L2,
         ACT_elev = L3,
         ACT_Total = L4)`
