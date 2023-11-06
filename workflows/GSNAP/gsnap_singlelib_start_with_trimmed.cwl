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
  index_dir:
    type: Directory
  pbat:
    type: boolean
    default: $(false)
  threads:
    type: int
  output_name:
    type: string 
  dbsnp:
    type: File
    secondaryFiles:
      - .tbi
  ref:
    type: File
    secondaryFiles:
      - ^.dict
      - .fai
  stand_call_conf:
    type: int

steps:
  gsnap_align:
    run: "./tools/gsnap_align.cwl"
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    in:
       read1:
         source: read1
       read2:
         source: read2
       pbat:
         source: pbat
       threads:
         source: threads
       output_name:
         source: output_name
       index_dir:
         source: index_dir
    out:
       - bam

  merge_and_sort:
    run: "../../tools/samtools_merge_and_sort.cwl"
    in:
      bams:
        source: gsnap_align/bam
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

  picard_addRG:
    run: "../../tools/picard_addRG.cwl"
    in:
      bam_withoutRG:
        source: picard_markdup/bam_duprem
    out:
      - bam_withRG

  samtools_index:
     run: "../../tools/samtools_index.cwl"
     in:
       bam_sorted:
         source: picard_addRG/bam_withRG
     out:
       - bam_sorted_indexed

  bissnp_call:
    run:  "./tools/bissnp_bisulfite_genotyper.cwl"
    in:
      ref:
         source: ref
      dbsnp:
         source: dbsnp
      bam:
         source: samtools_index/bam_sorted_indexed
      stand_call_conf:
         source: stand_call_conf
      threads:
         source: threads
      output_name:
         source: output_name
    out:
      - cpg_vcf
      - snp_vcf
      - log

outputs: 
  picard_markdup_log:
    type: File
    outputSource: picard_markdup/picard_markdup_log
  picard_markdup_stat:
    type: File
    outputSource: picard_markdup/picard_markdup_stat
  bam_sorted_indexed:
    type: File
    outputSource: picard_addRG/bam_withRG
  cpg_vcf:
    type: File
    outputSource: bissnp_call/cpg_vcf
  snp_vcf:
    type: File
    outputSource: bissnp_call/snp_vcf
  log:
    type: File
    outputSource: bissnp_call/log
