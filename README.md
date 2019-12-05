# aa_rmp

## Abstract:

> Tenure-track faculty members in the United States are evaluated on their performance in both research and teaching. In spite of accusations of bias and invalidity, student evaluations of teaching have dominated teaching evaluation at U.S. universities. However, studies establishing these issues have tended to be limited to particular institutional and disciplinary contexts. Moreover, in spite of the idealistic assumption that research and teaching are mutually beneficial, there have been few studies examining the link between research performance and student evaluations of teaching. In this study, we conduct a large scale exploratory analysis of the factors associated with student evaluations of teachers controlling for heterogeneous institutional and disciplinary contexts. We source public student evaluations of teaching from *RateMyProfessor.com* and information regarding career and contemporary research performance metrics from the company *Academic Analytics*. The factors most associated with higher student ratings were the attractiveness of the faculty and the student’s interest in the class; the factors most associated with lower student ratings were course difficulty and whether student comments mentioned an accent or a teaching assistant. Moreover, faculty tended to be rated more highly when they were young, male, in the humanities, and held a rank of associate professor. We observed little to no evidence of any relationship, positive or negative, between student evaluations of teaching and research performance. These results shed light on what factors relate to student evaluations of teaching across diverse contexts. We hope that these results will provide additional insights to the continuing discussion of student teaching evaluations and faculty evaluation more generally. 


## Replicating:

Due to privacy concerns, raw data has not been made available. However, all scripts used to process raw data nad produce the final dataset have been made available in the workflow directory. Scripts can be run individually, howver execution of these scripts is managed using `snakemake`, a python-based workflow automation tool. A python shell has been provided that will download and install `snakemake`. Simply navigate to the directory in a terminal, and activate the local `pipenv` shell. The code can then be run using the `snakemake` command in the workflow directory. Note that most scripts are written in R, and therefore several R packages will need to be installed, including `tidyverse`. 

Analysis (mostly) using the processed final data can be found in the R notebooks in the notebooks directory. 


## Contact
If you have any questions, comments, or requests, either post them as an issue to this repository or contact its owner at *dakmurra@iu.edu*. 
