#!/usr/bin/env cwl-runner

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
    doc: "Fasta file for reference created by the FAME --genome command."
    secondaryFiles:
      - _strands
  output_name:
    type: string
    doc: "Output files prefix name"
  pbat:
    type: boolean
    doc: "Is the dataset PBAT?"
    default: $(false)
  threads:
    type: int
    doc: "Number of CPUs"
    default: 16
  merged_r1_name:
    type: string
    doc: "The name of the merged Read1 FASTQ file."
    default: "read1"
  merged_r2_name:
    type: string
    doc: "The name of the merged Read2 FASTQ file."
    default: "read2"

  # qc parameters
  adapter1:
    doc: "adapter1 configuration for Trim_Galore."
    type: string?
  adapter2:
    doc: "adapter2 configuration for Trim_Galore."
    type: string?
  trim_galore_quality:
    doc: "trim_galore_quality configuration for Trim_Galore."
    type: int
    default: 20
  trim_galore_rrbs:
    doc: "trim_galore_rrbs configuration for Trim_Galore."
    type: boolean
    default: false
  trim_galore_clip_r1:
    type: int?
    doc: "trim_galore_clip_r1 configuration for Trim_Galore."
  trim_galore_clip_r2:
    type: int?
    doc: "trim_galore_clip_r2 configuration for Trim_Galore."
  trim_galore_three_prime_clip_r1:
    type: int?
    doc: "trim_galore_three_prime_clip_r1 configuration for Trim_Galore."
  trim_galore_three_prime_clip_r2:
    type: int?
    doc: "trim_galore_three_prime_clip_r2 configuration for Trim_Galore."


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
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    run: "../../tools/trimming/trim_galore.cwl"
    in:
      read1: read1
      read2: read2
      adapter1: adapter1
      adapter2: adapter2
      quality: trim_galore_quality
      rrbs: trim_galore_rrbs
      clip_r1: trim_galore_clip_r1
      clip_r2: trim_galore_clip_r2
      three_prime_clip_r1: trim_galore_three_prime_clip_r1
      three_prime_clip_r2: trim_galore_three_prime_clip_r2
      threads: threads
    out:
      - log
      - read1_trimmed
      - read2_trimmed

  cat_read1:
    run: "./tools/cat.cwl"
    in:
       read1: trim/read1_trimmed
       output_name: merged_r1_name
    out:
      - merged_fastq

  cat_read2:
    run: "./tools/cat.cwl"
    in:
       read1: trim/read2_trimmed
       output_name: merged_r2_name
    out:
      - merged_fastq

  fame:
    run: "./tools/fame.cwl"
    in:
       read1:
         source: cat_read1/merged_fastq
       read2:
         source: cat_read2/merged_fastq
       ref:
         source: ref
       output_name:
         source: output_name
       pbat:
         source: pbat
    out:
       - tsv
       - log

outputs:
  tsv:
    type: File
    outputSource: fame/tsv
  log:
    type: File
    outputSource: fame/log 
  fastq1:
    type: File
    outputSource: cat_read1/merged_fastq
  fastq2:
    type: File
    outputSource: cat_read2/merged_fastq
