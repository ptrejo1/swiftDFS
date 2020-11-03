# swiftDFS
Simple version of a distributed file system in swift for fun

## Design
- Client
- Name server
- Data servers

## Basic functions
- Read/write a file
- Upload a file: upload success and return the ID of the file

## Replication
- Each chunk (2MB) replicated according to replication factor
- Replicas are distributed in across data servers

## Name Server
- List the relationships between file and chunks
- List the relationships between replicas and data servers
- Data server management
- Using MD5 checksum for chunks in different data servers to ensure results are the same

## Data Server
- Read/Write a local chunk
- Write a chunk via a local directory path
 
## Usage
```bash
swiftDFS> put source_file_path dest_file_path
swiftDFS> ls
...
swiftDFS> read source_file_path dest_file_path
...
```
