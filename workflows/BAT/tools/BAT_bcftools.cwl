cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["bcftools", "sort", "-m", "2048M"] 
arguments:
  - valueFrom: $(inputs.vcf.basename).gz
    position: 1
    prefix: -o
  - valueFrom: "z"
    position: 2
    prefix: -O
  - valueFrom: "tmp"
    position: 3
    prefix: -T

requirements:
  InlineJavascriptRequirement: {}
  #ShellCommandRequirement: {}
  DockerRequirement:
    dockerPull: ifishlin324/bat

inputs: 
  - id: vcf
    type: File
    inputBinding:
      position: 4

outputs:
  vcfgz:
    type: File
    outputBinding:
      glob: "*.vcf.gz"

