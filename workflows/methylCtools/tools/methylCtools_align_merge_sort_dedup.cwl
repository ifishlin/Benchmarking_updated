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
    doc: first reads belonging to the same library
    type:
      type: array
      items: File
  read2:
    doc: first reads belonging to the same library
    type:
      type: array
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

steps:
  methylCtools_fqconv:
    run: "./methylCtools_fqconv.cwl"
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    in:
       read1:
         source: read1
       read2:
         source: read2
       output_name:
         source: output_name
    out:
       - convfq

  methylCtools_align:
    run: "./methylCtools_align.cwl"
    scatter: [read_conv_fq]
    scatterMethod: 'dotproduct'
    in:
      ref_conv_fa:
        source: ref_conv_fa
      read_conv_fq:
        source: methylCtools_fqconv/convfq
      output_name:
        source: output_name
      threads:
        source: threads
    out:
      - bam

  methylCtools_bconv:
    run: "./methylCtools_bconv.cwl"
    scatter: [bam]
    scatterMethod: 'dotproduct'
    in:
      bam:
        source: methylCtools_align/bam
      output_name:
        source: output_name
    out:
      - convbam

  merge_and_sort:
    run: "../../../tools/samtools_merge_and_sort.cwl"
    in:
      bams:
        source: methylCtools_bconv/convbam
      name_sort:
        valueFrom: $(false)
      threads: threads
    out:
       - bam_merged

  picard_markdup:
    run: "../../../tools/picard_markdup.cwl"
    in:
      bam_sorted:
        source:  merge_and_sort/bam_merged
    out:
      - bam_duprem
      - picard_markdup_log
      - picard_markdup_stat

outputs:
  bam_duprem:
    type: File
    outputSource: picard_markdup/bam_duprem
  picard_markdup_log:
    type: File
    outputSource: picard_markdup/picard_markdup_log
  picard_markdup_stat:
    type: File
    outputSource: picard_markdup/picard_markdup_stat 
