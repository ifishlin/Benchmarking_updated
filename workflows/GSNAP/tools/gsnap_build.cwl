cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["gmap_build"] 
arguments:
  - valueFrom: "gmap_genome"
    position: 1
    prefix: "-d"
  - valueFrom: "."
    position: 2
    prefix: "-D"

requirements:
  InlineJavascriptRequirement: {}
  ShellCommandRequirement: {}
  DockerRequirement:
    dockerPull: ifishlin324/gsnap

inputs: 
  - id: ref
    type: File
    inputBinding:
      position: 2

outputs: 
  genome_dir:
    type: Directory
    outputBinding:
      glob: "gmap_genome"

