cwlVersion: v1.0
class: Workflow

requirements:
 ScatterFeatureRequirement: {}
 SubworkflowFeatureRequirement: {}
 StepInputExpressionRequirement: {}
 InlineJavascriptRequirement: {}

inputs:
  read1:
    type: File[]
    doc: "Read1 FASTQ files list"
  read2:
    type: File[]
    doc: "Read2 FASTQ files list"
  ref:
    type: File
    doc: "Fasta file for reference"
    secondaryFiles:
      - .bwameth.c2t
      - .bwameth.c2t.amb
      - .bwameth.c2t.ann
      - .bwameth.c2t.bwt
      - .bwameth.c2t.pac
      - .bwameth.c2t.sa
      - .fai
  threads:
    type: int
    doc: "Number of CPUs"
  output_name:
    type: string
    doc: "Output files prefix name"
  pbat: 
    type: boolean
    doc: "Is the dataset PBAT?"
    default: False
  illuminaclip:
    type: string
    doc: "Illuminaclip string configuration for Trimmomatic."
  adapters_file:
    type: File
    doc: "Adapters file configuration for Trimmomatic."

steps:
  qc_pretrim:
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    run: "../../tools/fastqc.cwl"
    in:
      read1: read1
      read2: read2
    out:
      - fastqc_zip
      - fastqc_html

  trim:
    scatter: [fastq1, fastq2]
    scatterMethod: 'dotproduct'
    run: "../../tools/trimming/trimmomatic.cwl"
    in:
      fastq1: read1
      fastq2: read2
      adapters_file: adapters_file
      illuminaclip: illuminaclip
    out:
      - trimmomatic_log
      - fastq1_trimmed
      - fastq2_trimmed
      - fastq1_trimmed_unpaired
      - fastq2_trimmed_unpaired

  bwameth_align:
    run: "./tools/bwameth_align.cwl"
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    in:
       read1:
         source: trim/fastq1_trimmed
       read2:
         source: trim/fastq2_trimmed
       ref:
         source: ref
       threads:
         source: threads
       output_name:
         source: output_name
       pbat:
         source: pbat
    out:
       - bam

  merge_and_sort:
    run: "../../tools/samtools_merge_and_sort.cwl"
    in:
      bams:
        source: bwameth_align/bam
      name_sort:
        valueFrom: $(false)
      threads: threads
    out:
       - bam_merged

  picard_markdup:
    run: "../../tools/picard_markdup.cwl"
    in:
      bam_sorted:
        source:  merge_and_sort/bam_merged
    out:
      - bam_duprem
      - picard_markdup_log
      - picard_markdup_stat

  samtools_index:
     run: "../../tools/samtools_index.cwl"
     in:
       bam_sorted:
         source: picard_markdup/bam_duprem
     out:
       - bam_sorted_indexed

  methyldackel_mbais:
     run: "./tools/methyldackel_mbias.cwl"
     in:
       ref:
         source: ref
       bam:
         source: samtools_index/bam_sorted_indexed
       threads:
         source: threads
       output_name:
         source: output_name
     out:
        - mbias

  methyldackel:
     run: "./tools/methyldackel.cwl"
     in:
       ref:
         source: ref
       bam:
         source: samtools_index/bam_sorted_indexed
       threads:
         source: threads
       output_name:
         source: output_name
     out: 
        - call

outputs:
#  bam:
#    type: File[]
#    outputSource: bwameth_align/bam
  picard_markdup_log:
    type: File
    outputSource: picard_markdup/picard_markdup_log 
  picard_markdup_stat:
    type: File
    outputSource: picard_markdup/picard_markdup_stat
  bam_sorted_indexed:
    type: File
    outputSource: samtools_index/bam_sorted_indexed
  call:
    type: File
    outputSource: methyldackel/call
  mbias:
    type: File
    outputSource: methyldackel_mbais/mbias
