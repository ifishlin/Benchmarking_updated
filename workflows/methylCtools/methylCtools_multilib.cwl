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
  ref_conv_fa:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
  ref_pos:
    type: File
    secondaryFiles:
      - .tbi
  #trimmomatics
  illuminaclip:
    type: string
  adapters_file:
    type: File


steps:
  methylCtools_trim_align_merge_sort_dedup:
    run: "./tools/methylCtools_trim_align_merge_sort_dedup.cwl"
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    in:
       read1:
         source: read1
       read2:
         source: read2
       output_name:
         source: output_name
       ref_conv_fa:
         source: ref_conv_fa
       threads:
         source: threads
       illuminaclip: illuminaclip
       adapters_file: adapters_file
    out:
       - bam_duprem
       - picard_markdup_stat
       - picard_markdup_log

  merge_and_sort:
    run: "../../tools/samtools_merge_and_sort.cwl"
    in:
      bams:
        source: methylCtools_trim_align_merge_sort_dedup/bam_duprem
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

  methylCtools_bcall:
     run: "./tools/methylCtools_bcalltag.cwl"
     doc: "patched bcall for TWGBS"
     in:
        bam:
          source: samtools_index/bam_sorted_indexed
        ref_pos:
          source: ref_pos
        output_name:
          source: output_name
     out:
        - callgz

  tabix:
    run: "../../tools/tabix.cwl"
    in:
      vcfgz:
        source: methylCtools_bcall/callgz
    out:
      - vcfgztbi

outputs: 
#   bam:
#     type: File[]
#     outputSource: methylCtools_align/bam
#   convbam:
#     type: File[]
#     outputSource: methylCtools_bconv/convbam
   bam_sorted_indexed:
     type: File
     outputSource: samtools_index/bam_sorted_indexed
   vcfgztbi:
     type: File
     outputSource: tabix/vcfgztbi
