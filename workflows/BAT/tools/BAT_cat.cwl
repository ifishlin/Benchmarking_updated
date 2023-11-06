cwlVersion: v1.0
class: CommandLineTool
baseCommand: cat 
arguments:
  - valueFrom: ">"
    position: 3
    shellQuote: false
  - valueFrom: $(inputs.output_name).vcf
    position: 4

requirements:
  InlineJavascriptRequirement: {}
  ShellCommandRequirement: {}

inputs:
  vcf:
    type: File
    inputBinding:
      position: 2
  output_name:
    type: string
  header:
    type: File
    inputBinding:
      position: 1

outputs: 
  vcf:
    type: File
    outputBinding:
      glob: $(inputs.output_name).vcf
