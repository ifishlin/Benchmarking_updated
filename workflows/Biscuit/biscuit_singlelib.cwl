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
      - .bis.amb
      - .bis.ann
      - .bis.pac
      - .dau.bwt
      - .dau.sa
      - .par.bwt
      - .par.sa
      - .fai
  pbat:
    type: boolean
    default: $(false)
  threads:
    type: int
  output_name:
    type: string 
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

  biscuit_align:
    run: "./tools/biscuit_align.cwl"
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    in:
       read1:
         source: trim/read1_trimmed
       read2:
         source: trim/read2_trimmed
       ref:
         source: ref
       pbat:
         source: pbat
       threads:
         source: threads
       output_name:
         source: output_name
    out:
       - bam

  samblaster_sort:
    run: "../../tools/samblaster_sort.cwl"
    scatter: [bam]
    scatterMethod: 'dotproduct'
    in:
      bam: 
        source: biscuit_align/bam
      output_name:
        source: output_name
      threads:
        source: threads
    out:
      - bam_duprem
      - log

  samtools_merge:
    run: "../../tools/samtools_merge.cwl"
    in:
      bams:
        source: samblaster_sort/bam_duprem
      output_name:
        source: output_name
    out:
       - bam_merged

  samtools_index:
     run: "../../tools/samtools_index.cwl"
     in:
       bam_sorted:
         source: samtools_merge/bam_merged
     out:
       - bam_sorted_indexed

  biscuit_pileup:
     run: "./tools/biscuit_pileup.cwl"
     in:
       output_name: 
         source: output_name
       ref:
         source: ref
       bam_sorted:
         source: samtools_index/bam_sorted_indexed
     out:
       - vcf

  bgzip:
    run: "../../tools/bgzip.cwl"
    in:
      vcf:
        source: biscuit_pileup/vcf
    out:
      - vcf.gz

  tabix:
    run: "../../tools/tabix.cwl"
    in:
      vcfgz: 
        source: bgzip/vcf.gz
    out:
      - vcfgztbi

  biscuit_vcf2bed:
     run: "./tools/biscuit_vcf2bed.cwl"
     in:
       vcfgz:
         source: tabix/vcfgztbi
     out:
       - bed

outputs:
    samblaster_log:
      type: File[]
      outputSource: samblaster_sort/log 
    bams:
      type: File
      outputSource: samtools_index/bam_sorted_indexed
    vcfgztbi:
      type: File
      outputSource: tabix/vcfgztbi
    bed:
      type: File
      outputSource: biscuit_vcf2bed/bed
