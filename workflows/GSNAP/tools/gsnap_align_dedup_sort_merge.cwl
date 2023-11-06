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
  index_dir:
    type: Directory
  pbat:
    type: boolean
    default: $(false)
  threads:
    type: int
  output_name:
    type: string

steps:
  gsnap_align:
    run: "../tools/gsnap_align.cwl"
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

  merge_and_sort:
    run: "../../../tools/samtools_merge_and_sort.cwl"
    in:
      bams:
        source: gsnap_align/bam
      name_sort:
        valueFrom: $(false)
      threads: threads
    out:
       - bam_merged

  picard_markdup:
    run: "../../../tools/picard_markdup.cwl"
    in:
      bam_sorted:
        source:  merge_and_sort/bam_merged
    out:
      - bam_duprem
      - picard_markdup_log
      - picard_markdup_stat


outputs: 
    bam:
      type: File
      outputSource: picard_markdup/bam_duprem
