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
  qc_pretrim:
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    run: "../../../tools/fastqc.cwl"
    in:
      read1: read1
      read2: read2
    out:
      - fastqc_zip
      - fastqc_html

  trim:
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    run: "../../../tools/trimming/trim_galore.cwl"
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
 
  methylpy_paired:
    run: "./methylpy_paired.cwl"
    in:
       read1:
         source: trim/read1_trimmed
       read2:
         source: trim/read2_trimmed
       sample:
         source: sample
       ref_fasta:
         source: ref_fasta
       pbat:
         valueFrom: $(false)
    out:
       - tsvgz

outputs: 
   tsvgz:
     type: File
     outputSource: methylpy_paired/tsvgz
