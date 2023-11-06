cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["/usr/local/gmap-2019-12-01/bin/cmetindex"] 
arguments:
  - valueFrom: "."
    position: 2
    prefix: "-F"
  - valueFrom: "gmap_genome"
    position: 3
    prefix: "-d"

requirements:
  InlineJavascriptRequirement: {}
  ShellCommandRequirement: {}
  DockerRequirement:
    dockerPull: ifishlin324/gsnap
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.ref_dir)
        writable: true

inputs: 
  - id: ref_dir
    type: Directory

outputs: 
  cmet_dir:
    type: Directory
    outputBinding:
      glob: "gmap_genome"

