# lazys3

A Ruby script to bruteforce for AWS s3 buckets using different permutations.

# Usage 

```
$ ruby lazys3.rb <COMPANY> 
```

or, to run in Docker:

```
docker run --rm -it -v $(pwd):/opt/app:Z --user $(id -u):$(id -g) -w /opt/app ruby:2.4.2 ./lazys3.rb <COMPANY>
```

# Authors
- http://twitter.com/nahamsec
- http://twitter.com/JobertAbma

# Changelog 

1.0 - Release
