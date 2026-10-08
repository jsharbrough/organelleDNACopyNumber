# 2) Read QC and Adapter Trimming

### Log onto UCSB VPN (Ivanti Secure Access Client)

#### Open Terminal on Macbook  

#### Log into braid2 via `ssh`  
    ssh username@braid2.cnsi.ucsb.edu 

### Install mamba in your home directory
    
####  Move into your home directory using the `cd` command
    cd ~

#### Download the latest version of the Miniforge3 installer using the `wget` command
	wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"

#### Run the interactive installer using the `bash` command, answering any questions as needed
    bash Miniforge3-$(uname)-$(uname -m).sh
    
    Make sure to have the installer add the mamba activation to your .bashrc file

#### Re-source your .bashrc file to activate mamba using the `source` command
	source ~/.bashrc
	
	There should now be a parenthetical enclosing the word "base" on the left hand side of the command prompt

### Install FastQC and Fastp using mamba

#### Create a new mamba environment
    mamba create -n readQC -c bioconda fastp
    
    Answer Y to the question about wanting to install the package and its dependencies

#### Activate mamba environment and install fastqc
	mamba activate readQC
	mamba install -c bioconda fastqc
	
	Test installation of both programs by bringing up the help menu:
	
	fastp
	fastqc -h

#### Download necessary files for carrying out read QC and adapter trimming
#### Job submission bash script – [readQC.sh](https://github.com/jsharbrough/organelleDNACopyNumber/blob/57039b289202fd1c39943d63cb6cea68bb9f831e/scripts/readQC.sh)
#### [getLine.py Python script](https://github.com/jsharbrough/organelleDNACopyNumber/blob/57039b289202fd1c39943d63cb6cea68bb9f831e/scripts/getLine.py)
	
#### On your local machine, open a Terminal session and put all necessary ancillary files and scripts in the project folder
    cd /path/to/directory/containing/files
    scp readQC.sh username@braid2.cnsi.ucsb.edu:/scratch/<username>/projectName/
    scp getLine.py username@braid2.cnsi.ucsb.edu:/scratch/<username>/projectName/
    
    For each scp attempt, you will be prompted to enter a password

#### If your running a PC, move the necessary ancillary files into the project folder via whatever method works best for you 
	
#### Move back to your Braid2 Terminal and navigate to your project folder on Braid2
	cd /scratch/$USER/projectName/

#### Generate files of file names (FOFN) for reads
	ls /path/to/read/files/*.fastq.gz > reads.fofn
	
#### Check FOFNs to make sure they look correct
	cat reads.fofn 
	
	Check whether forward and reverse reads should be on consecutive lines. If they do not, use [Vi](https://www.cs.colostate.edu/helpdocs/vi.html) to fix

#### Make pre- and post-trim read QC directories
	mkdir /path/to/read/files/fastQC_pretrim/
	mkdir /path/to/read/files/fastQC_posttrim/
	
#### Edit readQC.sh job submission script to run on the fastq files on Braid2
#### Changes need to be made to lines: <b>2, 6, 16, 19, 21, </b>
	vi readQC.sh
	
	Type the 'a' key to enter into edit mode and change the text of the file once you have entered the Vi session
	Type the 'esc' key to exit edit mode
	Type 'ZZ' to save the changes you've made and close the Vi session
	Type 'q!' to quit without saving

#### Submit the job
	sbatch readQC.sh
	
	You can check on the status of the job with the squeue function
	
	squeue -u $USER 
	
	or
	
	watch squeue -u $USER

#### Once the job has been completed (you should receive an email), you'll need to check the pre- and post-trimming QC information to make sure all adapters have been removed and that the data look clean. The output from FastQC is in HTML format and can be opened in any internet browser (e.g., Google Chrome). The following code will let you make a tarball of the FastQC output and download it from Braid2. On your Braid2 terminal, type the following:
	cd /scratch/$USER/projectName/path/to/read/files/
	
	tar -czvf <Name_of_Sequencing_Run>.pretrim_fastqc.tar.gz fastQC_pretrim/
	
	tar -czvf <Name_of_Sequencing_Run>.posttrim_fastqc.tar.gz fastQC_posttrim/
	
	Make sure to do this for both the Aviti and NovaSeq data

#### Download the fastqc data to your local machine. On a Terminal on your machine, type the following to scp the tarballs to your local machine:
	scp username@braid2.cnsi.ucsb.edu:/scratch/<username>/projectName/path/to/read/files/<Name_of_Sequencing_Run>.pretrim_fastqc.tar.gz .
	
	scp username@braid2.cnsi.ucsb.edu:/scratch/<username>/projectName/path/to/read/files/<Name_of_Sequencing_Run>.posttrim_fastqc.tar.gz .
	
#### Open the tarballs and inspect the pre- and post- QC files to make sure everything looks good. Then proceed to the [3) Repeat Modeling and Masking]() step
	
