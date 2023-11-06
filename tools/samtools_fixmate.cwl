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

baseCommand: ["samtools", "fixmate"]
arguments:
  - valueFrom: "24"
    prefix: -@
  - valueFrom: "-p"
  - valueFrom: "-m"
  - valueFrom: $(inputs.bam.nameroot).fixmate.bam
    position: 3

inputs:
  bam:
    type: File
    inputBinding:
      position: 2

outputs:
  bam_fixmate:
    type: File
    outputBinding:
      glob: "*.bam"

