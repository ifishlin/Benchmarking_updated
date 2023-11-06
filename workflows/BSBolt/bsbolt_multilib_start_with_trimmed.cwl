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
  DB:
    type: Directory
  threads:
    type: int
  output_name:
    type: string
  pbat:
    type: boolean
    default: False

steps:
  bsbolt_align_merge_sort_dedup:
     run: "./tools/bsbolt_align_merge_sort_dedup.cwl"
     scatter: [read1, read2]
     scatterMethod: 'dotproduct'
     in:
        read1:
          source: read1
        read2:
          source: read2
        DB:
          source: DB
        threads:
          source: threads
        output_name:
          source: output_name
        pbat:
          source: pbat
     out:
        - bam_markdup

  merge_and_sort:
    run: "../../tools/samtools_merge_and_sort.cwl"
    in:
      bams:
        source: bsbolt_align_merge_sort_dedup/bam_markdup
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
