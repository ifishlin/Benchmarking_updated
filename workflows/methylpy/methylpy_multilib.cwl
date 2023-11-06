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
  sample:
    type: string
  ref_fasta:
    type: File
    secondaryFiles:
      - _f.1.bt2
      - _f.2.bt2
      - _f.3.bt2
      - _f.4.bt2
      - _f.rev.1.bt2
      - _f.rev.2.bt2
      - _r.1.bt2
      - _r.2.bt2
      - _r.3.bt2
      - _r.4.bt2
      - _r.rev.1.bt2
      - _r.rev.2.bt2
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


steps:
  methylpy_paired_multilib:
    run: "./tools/methylpy_paired_multilib.cwl"
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    in:
       read1:
         source: read1
       read2:
         source: read2
       sample:
         source: sample
       ref_fasta:
         source: ref_fasta
       pbat:
         source: pbat
       adapter1: adapter1
       adapter2: adapter2
       trim_galore_quality: trim_galore_quality
       trim_galore_rrbs: trim_galore_rrbs
       trim_galore_clip_r1: trim_galore_clip_r1
       trim_galore_clip_r2: trim_galore_clip_r2
       trim_galore_three_prime_clip_r1: trim_galore_three_prime_clip_r1
       trim_galore_three_prime_clip_r2: trim_galore_three_prime_clip_r2
       threads: threads
    out: 
       - tsvgz

  methylpy_merge_allc:
    run: "./tools/methylpy_merge_allc.cwl"
    in:
       allc_files:
         source: methylpy_paired_multilib/tsvgz
    out: 
       - merge_allc

outputs:  
   tsvgz:
     type: File[]
     outputSource: methylpy_paired_multilib/tsvgz
   merge_allc:
     type: File
     outputSource: methylpy_merge_allc/merge_allc
