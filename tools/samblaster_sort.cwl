cwlVersion: v1.0
class: CommandLineTool
requirements:
  ShellCommandRequirement: {}
  ResourceRequirement:
    coresMin: $(inputs.threads)
    ramMin: 20000
    tmpdirMin: 30000
  DockerRequirement:
    dockerPull: ifishlin324/samblaster
  InlineJavascriptRequirement: {}

baseCommand: ["samtools", "view", "-h"]
arguments:
  - valueFrom: "|"
    position: 2
    shellQuote: false
  - valueFrom: "samblaster"
    position: 3
  - valueFrom: "|"
    position: 4
    shellQuote: false
  - valueFrom: samtools
    position: 5
  - valueFrom: sort
    position: 6
  - prefix: "-@"
    valueFrom: $(inputs.threads)
    position: 7
  - prefix: "-o"
    valueFrom: $(inputs.output_name).bam
    position: 7
  - valueFrom: "-"
    position: 8

stdout: stderr
stderr: $(inputs.output_name + ".samblaster.log")

inputs:
  output_name:
    type: string
    default: "samblaster_reads.bam"
  bam:
    type: File
    inputBinding:
      position: 1
  threads:
    type: int

outputs:
  - id: bam_duprem
    type: File
    outputBinding:
      glob: $(inputs.output_name).bam
  - id: log
    type: File
    outputBinding:
     glob: "*.samblaster.log"
