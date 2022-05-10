git clone --depth=1 https://github.com/spack/spack.git
source env-start.sh
spack config add upstreams:manali:install_tree:/apps/manali/UES/store
spack compiler add $(spack find --format '{prefix}' gcc@11)
spack compiler find
