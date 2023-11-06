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

steps:
  biscuit_align_dedup_sort_merge:
    run: "./tools/biscuit_align_dedup_sort_merge.cwl"
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    in:
       read1:
         source: read1
       read2:
         source: read2
       ref:
         source: ref
       pbat:
         source: pbat
       threads:
         source: threads
       output_name:
         source: output_name
    out:
       - bam_merged
       - log

  samtools_merge:
    run: "../../tools/samtools_merge.cwl"
    in:
      bams:
        source: biscuit_align_dedup_sort_merge/bam_merged
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
    bams:
      type: File
      outputSource: samtools_index/bam_sorted_indexed
    vcfgztbi:
      type: File
      outputSource: tabix/vcfgztbi
    bed:
      type: File
      outputSource: biscuit_vcf2bed/bed
    samblaster_log:
      type:
        type: array # array of libraries
        items:
          type: array # array of lanes sequenced as part of one library
          items: File
      outputSource: biscuit_align_dedup_sort_merge/log
