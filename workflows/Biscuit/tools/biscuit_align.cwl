cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["biscuit", "align"]
arguments:
  - valueFrom: "|"
    position: 6
    shellQuote: false
  - valueFrom: samtools
    position: 7
  - valueFrom: view
    position: 8
  - prefix: "-@"
    valueFrom: $(inputs.threads)
    position: 9
  - prefix: "-o"
    valueFrom: $(inputs.output_name).bam
    position: 10
  - valueFrom: "-"
    position: 11

requirements:
  DockerRequirement:
    dockerPull: mgibio/biscuit
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

stdout: stderr
stderr: $(inputs.output_name + ".biscuit.aln.log")

inputs:
  - id: read1
    type: File
    inputBinding:
      position: 4
  - id: read2
    type: File
    inputBinding:
      position: 5
  - id: ref
    type: File
    secondaryFiles:
      - .bis.amb
      - .bis.ann
      - .bis.pac
      - .dau.bwt
      - .dau.sa
      - .par.bwt
      - .par.sa
    inputBinding:
      position: 3 
  - id: pbat
    type: boolean
    inputBinding:
      prefix: -b
      position: 1
      valueFrom: ${if(inputs.pbat) return "0"; else return "1"}
  - id: threads
    type: int
    inputBinding:
      prefix: -t
      position: 2
  - id: output_name
    type: string
outputs:
  bam:
    type: File
    outputBinding:
      glob: "*.bam"
  log:
    type: stderr
