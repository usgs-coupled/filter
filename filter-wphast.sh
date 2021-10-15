c#!/bin/bash -ex
# git clone --bare git@code.chs.usgs.gov:coupled/save/wphast.git
# git clone wphast.git

cd wphast.git
# git filter-repo --analyze

# # list files greater than 100M
# cat filter-repo/analysis/blob-shas-and-paths.txt | awk '!/Files|Format/ {m = $2/1048576; if(m > 100) print $1 "  " m "M" "  " $4$5$6$7$8}'

# create file of shas to be removed
cat > ../wphast_strip_blob_ids<<EOF
3a66fda4577ca8a244adec821bbe23f40adfb5b8
2d62c62340c0387e9d1d48416061c3888e3aca02
cf35defd13869aff782a5624158dd7f9bf9dd9cf
55a1bb4d3d211693ce62247b9f35350edf316501
ab260846889c87ed2741dee42e0011c97e5aeec5
d7fcaaca97b10e0d4cc88b4531d44b13536721b2
c726016669a05e68160730bbe353aceda8535c62
EOF

# gzip files to be kept
cd ../wphast
# gzip --keep msi/phast/examples/capecod/WalterData/head_all_pts
# mv msi/phast/examples/capecod/WalterData/head_all_pts.gz ..
# gzip --keep msi/phast/examples/capecod/WalterData/kh_points
# mv msi/phast/examples/capecod/WalterData/kh_points.gz ..
# gzip --keep msi/phast/examples/capecod/WalterData/kz_points
# mv msi/phast/examples/capecod/WalterData/kz_points.gz ..
# gzip --keep msi/phast/examples/capecod/ex5/Parameters/iniital_C.dat
# mv msi/phast/examples/capecod/ex5/Parameters/iniital_C.dat.gz ..

cd ../wphast.git
git filter-repo --force \
  --strip-blobs-with-ids ../wphast_strip_blob_ids \
  --blob-callback '
  if blob.original_id == b"ab297fc2c52a00bb8aa2e623dbc52043a38c53c8":
    with open("../head_all_pts.gz", "rb") as f:
      blob.data = f.read()
  if blob.original_id == b"29aaf8f514a094897680f2b6ed3aeef6e541e0e5":
    with open("../kh_points.gz", "rb") as f:
      blob.data = f.read()
  if blob.original_id == b"459567053c198fefb3315702f4f4451f8bd090f4":
    with open("../kz_points.gz", "rb") as f:
      blob.data = f.read()
  if blob.original_id == b"9e4d0188cf3b8669a9b997dcf5f07a8cfcfb8f92":
    with open("../iniital_C.dat.gz", "rb") as f:
      blob.data = f.read()
  ' \
   --path-rename capecod/WalterData/head_all_pts:capecod/WalterData/head_all_pts.gz \
   --path-rename msi/phast/examples/capecod/WalterData/head_all_pts:msi/phast/examples/capecod/WalterData/head_all_pts.gz \
   --path-rename capecod/WalterData/kh_points:capecod/WalterData/kh_points.gz \
   --path-rename msi/phast/examples/capecod/WalterData/kh_points:msi/phast/examples/capecod/WalterData/kh_points.gz \
   --path-rename capecod/WalterData/kz_points:capecod/WalterData/kz_points.gz \
   --path-rename msi/phast/examples/capecod/WalterData/kz_points:msi/phast/examples/capecod/WalterData/kz_points.gz \
   --path-rename capecod/ex5/Parameters/iniital_C.dat:capecod/ex5/Parameters/iniital_C.dat.gz \
   --path-rename ex5/Parameters/iniital_C.dat:ex5/Parameters/iniital_C.dat.gz \
   --path-rename msi/phast/examples/capecod/ex5/Parameters/iniital_C.dat:msi/phast/examples/capecod/ex5/Parameters/iniital_C.dat.gz

# verify
cd ..
git clone --bare wphast.git/ wphast-filtered.git
git filter-repo --analyze

# list any blobs larger than 100M
cat filter-repo/analysis/blob-shas-and-paths.txt | awk '!/Files|Format/ {m = $2/1048576; if(m > 100) print $1 "  " m "M" "  " $4$5$6$7$8}'

# verify no 'replace' refs (github returns an 'Internal Server Error')
git for-each-ref --count=50

# upload to github.com and code.chs.usgs.gov
git push --mirror git@github.com:usgs-coupled/wphast.git
git push --mirror git@code.chs.usgs.gov:coupled/wphast.git

# verify default branches

# update WPHAST_ID and WPHAST_TRIGGER on code.chs.usgs.gov