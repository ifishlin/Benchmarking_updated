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
    doc: "Read1 FASTQ files list"
  read2:
    type: File[]
    doc: "Read2 FASTQ files list"
  index_dir:
    type: Directory
    doc: "The directory containing reference-related files created by the GSNAP"
  pbat:
    type: boolean
    doc: "Is the dataset PBAT?"
    default: $(false)
  threads:
    type: int
    doc: "Number of CPUs"
  output_name:
    type: string 
    doc: "Output files prefix name"
  dbsnp:
    type: File
    doc: "The dbSNP file required by the Bis-SNP caller."
    #secondaryFiles:
    #  - .tbi
  ref:
    type: File
    doc: "Fasta file for reference"
    secondaryFiles:
      - ^.dict
      - .fai
  stand_call_conf:
    type: int
    doc: "stand_call_conf configuration for Bis-SNP."
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

  gsnap_align:
    run: "./tools/gsnap_align.cwl"
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    in:
       read1:
         source: trim/read1_trimmed
       read2:
         source: trim/read2_trimmed
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
