#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
 ScatterFeatureRequirement: {}
 SubworkflowFeatureRequirement: {}
 StepInputExpressionRequirement: {}
 InlineJavascriptRequirement: {}

inputs:
  ref:
    type: File
    doc: "Fasta file for reference."
    secondaryFiles:
      - .fai
      - ^.ctidx
      - ^.gaidx
  read1:
    type: File[]
    doc: "Read1 FASTQ files list"
  read2:
    type: File[]
    doc: "Read2 FASTQ files list"
#  - id: prefix_db
#    type: File
#    secondaryFiles:
#      - ^.ctidx
#      - ^.gaidx
  threads:
    type: int
    doc: "Number of CPUs"
  output_name:
    type: string
    doc: "Output files prefix name"
  header:
    type: File
    doc: "A pre-created header file for VCF file to fix the bug."
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


outputs:
  bam_sorted_indexed:
    type: File
    outputSource: samtools_index/bam_sorted_indexed
  vcfgztbi:
    type: File
    outputSource: calling/vcfgztbi

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

  BAT_mapping:
    run: "./tools/BAT_mapping.cwl"
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    in:
      reference: ref
      read1: trim/read1_trimmed
      read2: trim/read2_trimmed
      prefix_db: ref
      threads: threads
    out: [bam]

  merge_and_sort:
    run: "../../tools/samtools_merge_and_sort.cwl"
    in:
      bams:
        source: BAT_mapping/bam
      name_sort:
        valueFrom: $(false)
      threads: threads
    out:
       - bam_merged

  samtools_index:
     run: "../../tools/samtools_index.cwl"
     in:
       bam_sorted:
         source: merge_and_sort/bam_merged
     out:
       - bam_sorted_indexed

  calling:
     run: "./tools/BAT_calling_latest.cwl"
     in:
       ref:
         source: ref
       bam:
         source: samtools_index/bam_sorted_indexed
       threads:
         source: threads
       output_name:
         source: output_name
       header:
         source: header
     out: [vcfgztbi]
