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
  gsnap_align_dedup_sort_merge:
    run: "./tools/gsnap_align_dedup_sort_merge.cwl"
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

  samtools_merge:
    run: "../../tools/samtools_merge.cwl"
    in:
      bams:
        source: gsnap_align_dedup_sort_merge/bam
      output_name: 
        source: output_name
    out:
       - bam_merged

  picard_addRG:
    run: "../../tools/picard_addRG.cwl"
    in:
      bam_withoutRG:
        source: samtools_merge/bam_merged
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
#  bam:
#    type: File[]
#    outputSource: gsnap_align_dedup_sort_merge/bam
  bam_sorted_indexed:
    type: File
    outputSource: samtools_index/bam_sorted_indexed
  cpg_vcf:
    type: File
    outputSource: bissnp_call/cpg_vcf
  snp_vcf:
    type: File
    outputSource: bissnp_call/snp_vcf
  log:
    type: File
    outputSource: bissnp_call/log
