cwlVersion: v1.0
class: CommandLineTool
baseCommand: [BAT_mapping] 
arguments:
  - valueFrom: $(inputs.read1.nameroot)
    position: 5
    prefix: -o
  - valueFrom: $(inputs.reference.path.split('.').slice(0, -1).join('.'))
    position: 4
    prefix: -i

requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: ifishlin324/bat 

inputs: 
  reference:
    type: File
    doc: path/filename of reference genome fasta
    inputBinding:
      prefix: -g
      position: 1
  read1:
    type: File
    doc: path/filename of query sequences
    inputBinding:
      prefix: -q
      position: 2
  read2:
    type: File
    doc: path/filename of mate pair sequences
    inputBinding:
      prefix: -p   
      position: 3  
  threads:
    type: int
    inputBinding:
      prefix: -t
      position: 6 

outputs:           
  bam:
    type: File
    outputBinding:
      glob: $(inputs.read1.nameroot + ".bam")
  bam.bai:
    type: File
    outputBinding:
      glob: $(inputs.read1.nameroot + ".bam.bai")      
  excluded_bam:
    type: File
    outputBinding:
      glob: $(inputs.read1.nameroot + ".excluded.bam") 
  excluded_bam.bai:
    type: File
    outputBinding:
      glob: $(inputs.read1.nameroot + ".excluded.bam.bai")
  log:
    type: File
    outputBinding:
      glob: "*.log" 
