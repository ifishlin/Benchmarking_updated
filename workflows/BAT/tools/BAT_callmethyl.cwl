cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["haarz.x", "callmethyl"] 
arguments:
  - valueFrom: "|"
    position: 5
    shellQuote: false
  - valueFrom: grep
    position: 6
  - valueFrom: "-v"
    position: 7
  - valueFrom: "^\\["
    position: 8
  - valueFrom: ">>"
    position: 9
    shellQuote: false
  - valueFrom: "tmp.vcf"
    position: 10

requirements:
  InlineJavascriptRequirement: {}
  ShellCommandRequirement: {}
  DockerRequirement:
    dockerPull: ifishlin324/bat

inputs: 
  - id: ref
    type: File
    secondaryFiles:
      - .fai
    inputBinding:
      prefix: -d
      position: 1
  - id: bam
    type: File
    secondaryFiles:
      - .bai
    inputBinding:
      prefix: -b
      position: 4
  - id: threads
    type: int
    inputBinding:
      prefix: -t
      position: 2

outputs:
  vcf:
    type: File
    outputBinding:
      glob: "tmp.vcf"

