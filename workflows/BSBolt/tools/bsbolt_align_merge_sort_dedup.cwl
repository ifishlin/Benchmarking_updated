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
  DB:
    type: Directory
  threads:
    type: int
  output_name:
    type: string
  pbat:
    type: boolean
    default: False

steps:
  bsbolt_align:
     run: "./bsbolt_align.cwl"
     scatter: [read1, read2]
     scatterMethod: 'dotproduct'
     in:
        read1:
          source: read1
        read2:
          source: read2
        DB:
          source: DB
        threads:
          source: threads
        output_name:
          source: output_name
        pbat:
          source: pbat
     out:
        - bam

  samtools_fixmate:
    run: "../../../tools/samtools_fixmate.cwl"
    scatter: [bam]
    scatterMethod: 'dotproduct'
    in:
      bam: 
        source: bsbolt_align/bam
    out:
      - bam_fixmate

  merge_and_sort:
    run: "../../../tools/samtools_merge_and_sort.cwl"
    in:
      bams:
        source: samtools_fixmate/bam_fixmate
      name_sort:
        valueFrom: $(false)
      threads: threads
    out:
      - bam_merged

  samtools_markdup:
    run: "../../../tools/samtools_markdup.cwl"
    in:
      bam_sorted:
        source: merge_and_sort/bam_merged
    out:
      - bam_markdup

outputs: 
   bam_markdup:
     type: File
     outputSource: samtools_markdup/bam_markdup
