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
    type:
      type: array # array of libraries
      items: 
        type: array # array of lanes sequenced as part of one library
        items: File
  read2:
    type:
      type: array # array of libraries
      items: 
        type: array # array of lanes sequenced as part of one library
        items: File
  threads:
    type: int
  output_name:
    type: string
  ref:
    type: File
    secondaryFiles:
      - .bwameth.c2t
      - .bwameth.c2t.amb
      - .bwameth.c2t.ann
      - .bwameth.c2t.bwt
      - .bwameth.c2t.pac
      - .bwameth.c2t.sa
      - .fai
  pbat: 
    type: boolean
    default: False

steps: 
  bwameth_align_merge_sort_dedup:
    run: "./tools/bwameth_align_merge_sort_dedup.cwl"
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    in:
      read1: 
        source: read1
      read2:
        source: read2
      ref:
        source: ref
      threads:
        source: threads
      output_name:
        source: output_name
      pbat:
        source: pbat
    out: 
      - bam_duprem
      - picard_markdup_stat
      - picard_markdup_log

  merge_and_sort:
    run: "../../tools/samtools_merge_and_sort.cwl"
    in:
      bams:
        source: bwameth_align_merge_sort_dedup/bam_duprem
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

  methydackel:
     run: "./tools/methydackel.cwl"
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
#  bam_duprem:
#    type: File[]
#    outputSource: bwameth_align_merge_sort_dedup/bam_duprem 
  picard_markdup_stat:
    type: File[]
    outputSource: bwameth_align_merge_sort_dedup/picard_markdup_stat
  picard_markdup_log:
    type: File[]
    outputSource: bwameth_align_merge_sort_dedup/picard_markdup_log
  bam_sorted_indexed:
    type: File
    outputSource: samtools_index/bam_sorted_indexed
  call:
    type: File
    outputSource: methydackel/call
