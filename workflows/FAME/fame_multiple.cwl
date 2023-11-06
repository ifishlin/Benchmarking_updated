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
  read2:
    type: File[]
  ref:
    type: File
    secondaryFiles:
      - _strands
  output_name:
    type: string
  pbat:
    type: boolean
    default: $(false)

  # qc parameters
  adapter1:
    type: string?
  adapter2:
    type: string?
  trim_galore_quality:
    type: int
    default: 20
  trim_galore_rrbs:
    type: boolean
    default: false
  trim_galore_clip_r1:
    type: int?
  trim_galore_clip_r2:
    type: int?
  trim_galore_three_prime_clip_r1:
    type: int?
  trim_galore_three_prime_clip_r2:
    type: int?
  threads:
    type: int
    default: 16
  merged_r1_name:
    type: string
    default: "read1"
  merged_r2_name:
    type: string
    default: "read2"


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
