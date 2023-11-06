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
      - .bwameth.c2t
      - .bwameth.c2t.amb
      - .bwameth.c2t.ann
      - .bwameth.c2t.bwt
      - .bwameth.c2t.pac
      - .bwameth.c2t.sa
      - .fai
  threads:
    type: int
  output_name:
    type: string
  pbat: 
    type: boolean
    default: False

steps:
  bwameth_align:
    run: "./tools/bwameth_align.cwl"
    scatter: [read1, read2]
    scatterMethod: 'dotproduct'
    in:
       read1:
         source: read1
       read2:
         source: read2
       ref:
         source: ref
       threads:
         source: threads
       output_name:
         source: output_name
       pbat:
         source: pbat
    out:
       - bam

  merge_and_sort:
    run: "../../tools/samtools_merge_and_sort.cwl"
    in:
      bams:
        source: bwameth_align/bam
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

  samtools_index:
     run: "../../tools/samtools_index.cwl"
     in:
       bam_sorted:
         source: picard_markdup/bam_duprem
     out:
       - bam_sorted_indexed

  methydackel:
     run: "./tools/methydackel.cwl"
     in:
       ref:
         source: ref
       bam:
         source: samtools_index/bam_sorted_indexed
       threads:
         source: threads
       output_name:
         source: output_name
     out: 
        - call

outputs:
  picard_markdup_log:
    type: File
    outputSource: picard_markdup/picard_markdup_log 
  picard_markdup_stat:
    type: File
    outputSource: picard_markdup/picard_markdup_stat
  bam_sorted_indexed:
    type: File
    outputSource: samtools_index/bam_sorted_indexed
  call:
    type: File
    outputSource: methydackel/call
