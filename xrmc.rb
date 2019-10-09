class Xrmc < Formula
  desc "Monte Carlo simulation of X-ray imaging and spectroscopy experiments"
  homepage "https://github.com/golosio/xrmc"
  url "https://xrmc.tomschoonjans.eu/xrmc-6.6.0.tar.gz"
  sha256 "89c2ca22c44ddb3bb15e1ce7a497146722e3f5a0c294618cae930a254cbbbb65"
  revision 2

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "xraylib"
  depends_on "llvm"
  depends_on "xmi-msim" => :optional

  # fix rng
  patch do
    url "https://patch-diff.githubusercontent.com/raw/golosio/xrmc/pull/38.patch"
  end

  # fix clang crashing
  patch do
    url "https://github.com/golosio/xrmc/commit/2e12a7daf3f29fdf1f6b2c8d06b86889cf5eaf3f.patch"
  end

  def install
    ENV['CC'] = Formula["llvm"].opt_bin/"clang"
    ENV['CXX'] = Formula["llvm"].opt_bin/"clang++"
    ENV['LDFLAGS'] = "-L#{Formula["llvm"].opt_lib} -Wl,-rpath,#{Formula["llvm"].opt_lib}"
    ENV['CPPFLAGS'] = "-isysroot #{MacOS.sdk_path}"

    inreplace Dir.glob("{examples,test}/*/Makefile.am"),
      "$(datadir)/examples/xrmc/", "$(datadir)/examples/"

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --enable-openmp
      --docdir=#{doc}
      --datarootdir=#{pkgshare}
    ]

    if build.with? "xmi-msim"
      args << "--enable-xmi-msim"
    else
      args << "--disable-xmi-msim"
    end

    system "autoreconf", "-fiv"
    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    cp_r (pkgshare/"examples/cylind_cell").children, testpath
    system bin/"xrmc", "input.dat"
  end
end
