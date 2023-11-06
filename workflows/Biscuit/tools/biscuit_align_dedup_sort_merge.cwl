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
  threads:
    type: int
  output_name:
    type: string 

steps:
  biscuit_align:
    run: "./biscuit_align.cwl"
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
       - bam

  samblaster_sort:
    run: "../../../tools/samblaster_sort.cwl"
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
    run: "../../../tools/samtools_merge.cwl"
    in:
      bams:
        source: samblaster_sort/bam_duprem
      output_name: output_name
    out:
       - bam_merged

outputs: 
    bam_merged:
      type: File
      outputSource: samtools_merge/bam_merged
    log:
      type: File[]
      outputSource: samblaster_sort/log
