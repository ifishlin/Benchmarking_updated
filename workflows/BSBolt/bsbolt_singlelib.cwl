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
  DB:
    type: Directory
  threads:
    type: int
  output_name:
    type: string
  pbat:
    type: boolean
    default: False

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

  bsbolt_align:
     run: "./tools/bsbolt_align.cwl"
     scatter: [read1, read2]
     scatterMethod: 'dotproduct'
     in:
        read1:
          source: trim/read1_trimmed
        read2:
          source: trim/read2_trimmed
        DB:
          source: DB
        threads:
          source: threads
        output_name:
          source: output_name
        pbat:
          source: pbat
     out:
        - bam

  samtools_fixmate:
    run: "../../tools/samtools_fixmate.cwl"
    scatter: [bam]
    scatterMethod: 'dotproduct'
    in:
      bam: 
        source: bsbolt_align/bam
    out:
      - bam_fixmate

  merge_and_sort:
    run: "../../tools/samtools_merge_and_sort.cwl"
    in:
      bams:
        source: samtools_fixmate/bam_fixmate
      name_sort:
        valueFrom: $(false)
      threads: threads
    out:
      - bam_merged

  samtools_markdup:
    run: "../../tools/samtools_markdup.cwl"
    in:
      bam_sorted:
        source: merge_and_sort/bam_merged
    out:
      - bam_markdup

  samtools_index:
     run: "../../tools/samtools_index.cwl"
     in:
       bam_sorted:
         source: samtools_markdup/bam_markdup
     out:
       - bam_sorted_indexed

  bsbolt_call:
     run: "./tools/bsbolt_callMeth.cwl"
     in:
       DB:
         source: DB
       threads:
         source: threads
       output_name:
         source: output_name
       bam:
         source: samtools_index/bam_sorted_indexed
     out:
       - bggz

outputs: 
   bam_sorted_indexed:
     type: File
     outputSource: samtools_index/bam_sorted_indexed
   bggz:
     type: File
     outputSource: bsbolt_call/bggz
