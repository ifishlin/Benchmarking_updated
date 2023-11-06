# BS analysis workflows - CWL implemetation

[Common Workflow Language (CWL)](https://www.commonwl.org/) is an open standard for describing how to  run each computing job and connect them to create workflows. Because CWL is a specification and not a specific piece of software, tools and workflows described using CWL are portable across various platforms that support the CWL standard.

We implemented ten bisulfite sequencing analysis workflows in CWL.

1. [BAT](http://www.bioinf.uni-leipzig.de/Software/BAT/)
2. [Biscuit](https://huishenlab.github.io/biscuit/)
3. [Bismark](https://www.bioinformatics.babraham.ac.uk/projects/bismark/)
4. [BSBolt](https://github.com/NuttyLogic/BSBolt)
5. [bwa-meth](https://github.com/brentp/bwa-meth)
6. [FAME](https://github.com/FischerJo/FAME)
7. [gemBS](https://github.com/heathsc/gemBS)
8. [GSNAP](http://research-pub.gene.com/gmap/) ( - [BisSNP](https://people.csail.mit.edu/dnaase/bissnp2011/))
9. [methylCtools](https://github.com/hovestadt/methylCtools)
10. [methylpy](https://github.com/yupenghe/methylpy)

## Installation

The [cwltool](https://github.com/common-workflow-language/cwltool) and Docker are requried.

To retrieve the CWL-implemetation, clone this repository:
```
git clone https://github.com/ifishlin/Benchmarking_CWL
```

## Usage

CWL workflows have evolved to separate the workflow description and the data flow. 
  - Workflow file (.cwl) : Describing the workflow. 
  - Parameter file (.yml) : Provide the data flow to the workflow.

The simple way to execute a CWL workflow.
```
cwltool workflow.cwl workflow.yml
```


### 0) Build reference index

There is one CWL script for building index required by each workflow.
```
/workflows/tools/<workflow_name>_index.cwl 
```

Fill in the location of the reference fasta in the YAML file. 
```
# The YAML file (<workflow_name>_index.yml)
ref: 
    class: File
    path: ../genome/chr22.fa # replace with your reference.
```

Then, run it to create the index first. 
```
cd workflows/<workflow_name>/tools

cwltool <workflow_name>_index.cwl <workflow_name>_index.yml
```

### 1) Data preprocessing
Three specific CWLs for protocols, Swift, PBAT, and T-WGBS, were provided. Those protocols induce a different level of synthetic DNA, which must be removed before quality and adapter trimming.

- The Swift read sets are removed from the 15'bp at the end of read1 and 15'bp at the beginning of the read2.
- The PBAT read sets are removed the 6'bp at both ends of read1 and read2.
- The T-WGBS read sets are removed from the 9'bp at the end of the read2.

The CWLs for data preprocessing is in the directory. The Trim_galore and Trimmomatic versions are provided:
```
workflows/tools/trimming
```


### 2) Run the workflows

Each workflow has two versions, one for single library and the other for multiple library headsets. The difference is how to deal with redundancy removal. The multiple library version executes the redundancy removal within datasets of each library, then merges the BAMs of all libraries. On the contrary, the single library version runs in reverse order.

You can find two CWLs under the directory of each workflow: 
```
<workflow_name>.singlelib.cwl 

<workflow_name>.mulitlib.cwl
```

ALL workflows utilize docker and you can execute them without any software installation.

```
cwltool <workflow>.singlelib.cwl <workflow>.singlelib.yml
```

# The Benchmarking Project

Analysis of bisulfite sequencing data relies upon processing that generally includes four core steps: 
read preprocessing, alignment, post-alignment processing and calling of methylation states. 
An impressive number of tools for each of the steps or their combinations, workflows integrating them as well as turn-key solutions have been proposed.

Despite of this versatility, so far only few attempts have been made to systematically evaluate complete processing workflows in a standardized and unbiased analysis. Previous benchmarks either focused upon a single processing task, e.g. predominantly alignment software (Kunde-Ramamoorthy, Coarfa et al. 2014, Tran, Porter et al. 2014, Sun, Han et al. 2018, Grehl, Wagner et al. 2020). None of the benchmarks covered a substantial number of tools. Most importantly, none of the studies was based on a reasonable gold-standard data set.

To bridge this gap, we set out to perform a thorough benchmarking study of bisulfite sequencing workflows. At the core of our benchmark is a set of samples with highly accurate methylation calls (Bock, Halbritter et al. 2016), which we use as the gold-standard. We evaluate the software in the context of five most widely used sequencing protocols and propose protocol-specific choice of workflows. To simplify the choice of workflows and enable continuity we developed rich data presentation and benchmarking resources. To our knowledge, this is the most comprehensive benchmarking study of bisulfite sequencing to date.

All CWLs combinations of the Benchmarking projects are listed in [Workflows.md](https://github.com/ifishlin/Benchmarking_CWL/blob/main/Workflows.md).

# Contact
We appreciate any feedback. Feel free to contact us by mailing to p.lutsik `at` dkfz-heidelberg.de and yu-yu.lin `at` dkfz-heidelberg.de. 

# References
