cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["FAME"]
arguments:
  - valueFrom: "--gzip_reads"

requirements:
  DockerRequirement:
    dockerPull: ifishlin324/fame
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

#stderr: stdout
#stdout: $(inputs.output_name + ".fame.log")

inputs:
  - id: read1
    type: File
    inputBinding:
      position: 2
      prefix: "-r1"
  - id: read2
    type: File
    inputBinding:
      position: 3
      prefix: "-r2"
  - id: ref
    type: File
    inputBinding:
      position: 4
      prefix: "--load_index"
    secondaryFiles:
      - _strands
  - id: output_name
    type: string
    inputBinding:
      position: 5
      prefix: "-o"
      valueFrom: $(inputs.output_name)
  - id: pbat
    type: boolean
    default: $(false)
    inputBinding:
      position: 2
      prefix: "--unord_reads"

outputs:
  tsv:
    type: File
    outputBinding:
      glob: "*tsv"
  log:
    type: stdout
