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
    type: File
  read2:
    type: File
  DB:
    type: Directory
  threads:
    type: int
  output_name:
    type: string
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
  bismark_ignore:
    type: int
  bismark_ignore_r2:
    type: int
  bismark_ignore_3prime:
    type: int
  bismark_ignore_3prime_r2:
    type: int


steps:
  qc_pretrim:
    run: "../../tools/fastqc.cwl"
    in:
      read1: read1
      read2: read2
    out:
      - fastqc_zip
      - fastqc_html

  trim:
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

  bismark_align:
     run: "./tools/bismark_align_gen_unmapped.cwl"
     in:
        read1:
          source: trim/read1_trimmed
        read2:
          source: trim/read2_trimmed
        DB:
          source: DB
        threads:
          source: threads
     out:
        - bam
        - unmapped_r1
        - unmapped_r2

  bismark_align_se_unmapped_r1:
     run: "./tools/bismark_align_se_pbat.cwl"
     in: 
         read1:
           source: bismark_align/unmapped_r1
         DB:
           source: DB
         threads:
           source: threads
         pbat: 
           valueFrom: $(true) 

     out:
        - bam

  bismark_align_se_unmapped_r2:
     run: "./tools/bismark_align_se_pbat.cwl"
     in:
         read1:
           source: bismark_align/unmapped_r2
         DB:
           source: DB
         threads:
           source: threads
         pbat:
           valueFrom: $(false)

     out:
        - bam

  bismark_deduplicate_mapped:
     run: "./tools/bismark_deduplicate_pe.cwl"
     in: 
         bam:
           source: bismark_align/bam
     out:
        - bam

  bismark_deduplicate_ummapped_r1:
     run: "./tools/bismark_deduplicate_se.cwl"
     in:
         bam:
           source: bismark_align_se_unmapped_r1/bam
     out:
        - bam

  bismark_deduplicate_ummapped_r2:
     run: "./tools/bismark_deduplicate_se.cwl"
     in:
         bam:
           source: bismark_align_se_unmapped_r2/bam
     out:
        - bam

  bismark_methylation_extractor:
    run: "./tools/bismark_methylation_extractor.cwl"
    in:
      aligned_reads: bismark_deduplicate_mapped/bam
      no_overlap:
        valueFrom: $(true)
      ignore: bismark_ignore
      ignore_r2: bismark_ignore_r2
      ignore_3prime: bismark_ignore_3prime
      ignore_3prime_r2: bismark_ignore_3prime_r2
      threads: threads
      genome: DB
    out:
      - methylation_calls_bedgraph
      - methylation_calls_bismark
      - mbias_report
      - splitting_report
      - genome_wide_methylation_report
      - Cp_context_specific_methylation_reports
      - CH_context_specific_methylation_reports


  bismark_methylation_extractor_r1:
    run: "./tools/bismark_methylation_extractor.cwl"
    in:
      aligned_reads: bismark_deduplicate_ummapped_r2/bam
      no_overlap: 
        valueFrom: $(false)
      ignore: bismark_ignore
      #ignore_r2: bismark_ignore_r2
      ignore_3prime: bismark_ignore_3prime
      #ignore_3prime_r2: bismark_ignore_3prime_r2
      threads: threads
      genome: DB
      paired_end:
        valueFrom: $(false)
    out:
      - methylation_calls_bedgraph
      - methylation_calls_bismark
      - mbias_report
      - splitting_report
      - genome_wide_methylation_report
      - Cp_context_specific_methylation_reports 
      - CH_context_specific_methylation_reports

  bismark_methylation_extractor_r2:
    run: "./tools/bismark_methylation_extractor.cwl"
    in:
      aligned_reads: bismark_deduplicate_ummapped_r1/bam
      no_overlap:
        valueFrom: $(false)
      ignore: bismark_ignore_3prime
      #ignore_r2: bismark_ignore_3prime_r2
      ignore_3prime: bismark_ignore_3prime
      #ignore_3prime_r2: bismark_ignore_3prime_r2
      threads: threads
      genome: DB
      paired_end:
        valueFrom: $(false)
    out:
      - methylation_calls_bedgraph
      - methylation_calls_bismark
      - mbias_report
      - splitting_report
      - genome_wide_methylation_report
      - Cp_context_specific_methylation_reports
      - CH_context_specific_methylation_reports

  bismark2bedGraph:
    run: "./tools/bismark_bismark2bedGraph_multiple.cwl"
    in:
       output_name: output_name
       mapped: bismark_methylation_extractor/Cp_context_specific_methylation_reports
       unmapped_r1: bismark_methylation_extractor_r1/Cp_context_specific_methylation_reports
       unmapped_r2: bismark_methylation_extractor_r2/Cp_context_specific_methylation_reports
    out:
       - gz

outputs: 
   bam:
     type: File
     outputSource: bismark_deduplicate_mapped/bam
   bam2:
     type: File
     outputSource: bismark_deduplicate_ummapped_r1/bam
   bam3:
     type: File
     outputSource: bismark_deduplicate_ummapped_r2/bam
   methylation_calls_bedgraph_r1:
     type: File
     outputSource: bismark_methylation_extractor_r1/methylation_calls_bedgraph
   methylation_calls_bismark_r1:
     type: File
     outputSource: bismark_methylation_extractor_r1/methylation_calls_bismark
   mbias_report_r1:
     type: File
     outputSource: bismark_methylation_extractor_r1/mbias_report
   splitting_report_r1:
     type: File
     outputSource: bismark_methylation_extractor_r1/splitting_report
   genome_wide_methylation_report_r1:
     type: File
     outputSource: bismark_methylation_extractor_r1/genome_wide_methylation_report
   Cp_context_specific_methylation_reports_r1:
     type: File[]
     outputSource: bismark_methylation_extractor_r1/Cp_context_specific_methylation_reports
   CH_context_specific_methylation_reports_r1:
     type: File[]
     outputSource: bismark_methylation_extractor_r1/CH_context_specific_methylation_reports
   methylation_calls_bedgraph_r2:
     type: File
     outputSource: bismark_methylation_extractor_r2/methylation_calls_bedgraph
   methylation_calls_bismark_r2:
     type: File
     outputSource: bismark_methylation_extractor_r2/methylation_calls_bismark
   mbias_report_r2:
     type: File
     outputSource: bismark_methylation_extractor_r2/mbias_report
   splitting_report_r2:
     type: File
     outputSource: bismark_methylation_extractor_r2/splitting_report
   genome_wide_methylation_report_r2:
     type: File
     outputSource: bismark_methylation_extractor_r2/genome_wide_methylation_report
   Cp_context_specific_methylation_reports_r2:
     type: File[]
     outputSource: bismark_methylation_extractor_r2/Cp_context_specific_methylation_reports
   CH_context_specific_methylation_reports_r2:
     type: File[]
     outputSource: bismark_methylation_extractor_r2/CH_context_specific_methylation_reports
   methylation_calls_bedgraph:
     type: File
     outputSource: bismark_methylation_extractor/methylation_calls_bedgraph
   methylation_calls_bismark:
     type: File
     outputSource: bismark_methylation_extractor/methylation_calls_bismark
   mbias_report:
     type: File
     outputSource: bismark_methylation_extractor/mbias_report
   splitting_report:
     type: File
     outputSource: bismark_methylation_extractor/splitting_report
   genome_wide_methylation_report:
     type: File
     outputSource: bismark_methylation_extractor/genome_wide_methylation_report
   Cp_context_specific_methylation_reports:
     type: File[]
     outputSource: bismark_methylation_extractor/Cp_context_specific_methylation_reports
   CH_context_specific_methylation_reports:
     type: File[]
     outputSource: bismark_methylation_extractor/CH_context_specific_methylation_reports
   bismark2bedGraph_gz:
     type: File[]
     outputSource: bismark2bedGraph/gz
