#!/bin/bash -ex
git clone --bare git@code.chs.usgs.gov:coupled/save/vs2drt.git

cd vs2drt.git
git filter-repo --analyze

# list files greater than 100M
cat filter-repo/analysis/blob-shas-and-paths.txt | awk '!/Files|Format/ {m = $2/1048576; if(m > 100) print $1 "  " m "M" "  " $4$5$6$7$8}'

# create file of shas to be removed
cat > ../vs2drt_strip_blob_ids<<EOF
a31e19153bc7299700b5c2407891cf7c33912ab0
11293be018c90535bf9ba0bbdfc061b503ae9d14
29ddd6bd462353ed859f862ed6173e18d8da91eb
EOF

# gzip files to be kept
git cat-file -p a31e19153bc7299700b5c2407891cf7c33912ab0 > ../vs2drt.dat
gzip ../vs2drt.dat
mv ../vs2drt.dat.gz ../a31e19153bc7299700b5c2407891cf7c33912ab0.dat.gz
git cat-file -p 11293be018c90535bf9ba0bbdfc061b503ae9d14 > ../vs2drt.dat
gzip ../vs2drt.dat 
mv ../vs2drt.dat.gz ../11293be018c90535bf9ba0bbdfc061b503ae9d14.dat.gz
git cat-file -p 29ddd6bd462353ed859f862ed6173e18d8da91eb > ../vs2drt.dat
gzip ../vs2drt.dat 
mv ../vs2drt.dat.gz ../29ddd6bd462353ed859f862ed6173e18d8da91eb.dat.gz

git filter-repo --force \
  --blob-callback '
  if blob.original_id == b"a31e19153bc7299700b5c2407891cf7c33912ab0":
    with open("../a31e19153bc7299700b5c2407891cf7c33912ab0.dat.gz", "rb") as f:
      blob.data = f.read()
  if blob.original_id == b"11293be018c90535bf9ba0bbdfc061b503ae9d14":
    with open("../11293be018c90535bf9ba0bbdfc061b503ae9d14.dat.gz", "rb") as f:
      blob.data = f.read()
  if blob.original_id == b"29ddd6bd462353ed859f862ed6173e18d8da91eb":
    with open("../29ddd6bd462353ed859f862ed6173e18d8da91eb.dat.gz", "rb") as f:
      blob.data = f.read()
  ' \
  --path-rename tests/VS2DRT_LitNix_18mo/vs2drt.dat:tests/VS2DRT_LitNix_18mo/vs2drt.dat.gz

# verify
cd ..
git clone --bare vs2drt.git/ vs2drt-filtered.git
cd vs2drt-filtered.git
git filter-repo --analyze

# list any blobs larger than 5M
cat filter-repo/analysis/blob-shas-and-paths.txt | awk '!/Files|Format/ {m = $2/1048576; if(m > 5) print $1 "  " m "M" "  " $4$5$6$7$8}'

# verify no 'replace' refs (github returns an 'Internal Server Error')
git for-each-ref --count=50

# upload to github.com and code.chs.usgs.gov
git push --mirror git@github.com:usgs-coupled/vs2drt.git
git push --mirror git@code.chs.usgs.gov:coupled/vs2drt.git

# verify default branches

# update VS2DRT_ID and VS2DRT_TRIGGER on code.chs.usgs.gov
