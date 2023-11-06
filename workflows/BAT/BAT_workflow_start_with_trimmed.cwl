cwlVersion: v1.0
class: Workflow

requirements:
 ScatterFeatureRequirement: {}
 SubworkflowFeatureRequirement: {}
 StepInputExpressionRequirement: {}
 InlineJavascriptRequirement: {}

inputs:
  - id : ref
    type: File
    secondaryFiles:
      - .fai
      - ^.ctidx
      - ^.gaidx
  - id: read1
    type: File[]
  - id: read2
    type: File[]
#  - id: prefix_db
#    type: File
#    secondaryFiles:
#      - ^.ctidx
#      - ^.gaidx
  - id: threads
    type: int
  - id: output_name
    type: string
  - id: header
    type: File

outputs:
  bam_sorted_indexed:
    type: File
    outputSource: samtools_index/bam_sorted_indexed
  vcfgztbi:
    type: File
    outputSource: calling/vcfgztbi

steps:
  BAT_mapping:
    run: "./tools/BAT_mapping.cwl"
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    in:
      reference: ref
      read1: read1
      read2: read2
      prefix_db: ref
      threads: threads
    out: [bam]

  merge_and_sort:
    run: "../../tools/samtools_merge_and_sort.cwl"
    in:
      bams:
        source: BAT_mapping/bam
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

  calling:
     run: "./tools/BAT_calling_latest.cwl"
     in:
       ref:
         source: ref
       bam:
         source: samtools_index/bam_sorted_indexed
       threads:
         source: threads
       output_name:
         source: output_name
       header:
         source: header
     out: [vcfgztbi]
