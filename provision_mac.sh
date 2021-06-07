set -x

# Option1 - brew notes https://github.com/cockroachdb/homebrew-tap (note I decided not to use for once!)

# brew install cockroachdb/tap/cockroach
# sudo xcodebuild -license accept


# Option2 manual (slimer?) install method - https://www.cockroachlabs.com/docs/stable/install-cockroachdb-mac.html

curl https://binaries.cockroachdb.com/cockroach-v21.1.1.darwin-10.9-amd64.tgz | tar -xz
cp -i cockroach-v21.1.1.darwin-10.9-amd64/cockroach /usr/local/bin/
mkdir -p /usr/local/lib/cockroach
cp -i cockroach-v21.1.1.darwin-10.9-amd64/lib/libgeos.dylib /usr/local/lib/cockroach/
cp -i cockroach-v21.1.1.darwin-10.9-amd64/lib/libgeos_c.dylib /usr/local/lib/cockroach/
which cockroach
