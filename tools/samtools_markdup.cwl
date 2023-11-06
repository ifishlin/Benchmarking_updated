doc: Sort a bam file by read names.
cwlVersion: v1.0
class: CommandLineTool

hints:
  ResourceRequirement:
    coresMin: 4
    ramMin: 15000
    tmpdirMin: 30000

requirements:
  DockerRequirement:
    dockerPull: kerstenbreuer/samtools:1.7

baseCommand: ["samtools", "markdup"]
arguments:
  - valueFrom: "24"
    prefix: -@
  - valueFrom: "-r"
  - valueFrom: $(inputs.bam_sorted.nameroot).markdup.bam
    position: 3

inputs:
  bam_sorted:
    type: File
    inputBinding:
      position: 2

outputs:
  bam_markdup:
    type: File
    outputBinding:
      glob: "*.bam"

