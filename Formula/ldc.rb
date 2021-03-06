class Ldc < Formula
  desc "Portable D programming language compiler"
  homepage "https://wiki.dlang.org/LDC"
  url "https://github.com/ldc-developers/ldc/releases/download/v1.15.0/ldc-1.15.0-src.tar.gz"
  sha256 "d7e0e0cf332542c42e3b6570d391b0f05d5a81a812297efcdadccf8fb0f0cee2"
  head "https://github.com/ldc-developers/ldc.git", :shallow => false

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any_skip_relocation
    sha256 "6bc71f5b6f5e3c2d5b3ad60ab26aaeef04650de55d1c6993ab7d3cfbb2ec06aa" => :mojave
    sha256 "11a25fb3aa6eb44e0d120e1b777141f0095a811b15042bae41621123800fce52" => :high_sierra
    sha256 "ec4cc70ece5daaad1992b5dbe0f8b06a5762bc959fc726960e1225e355c775fd" => :sierra
    sha256 "7847be03c37aaedbb180a82812c3eacbbddc9fd831715f857b6d3f2649260c40" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "libconfig" => :build
  depends_on "llvm"

  resource "ldc-bootstrap" do
    if OS.mac?
      url "https://github.com/ldc-developers/ldc/releases/download/v1.12.0/ldc2-1.12.0-osx-x86_64.tar.xz"
      version "1.12.0"
      sha256 "a946e658aaff1eed80bffeb4d69b572f259368fac44673731781f6d487dea3cd"
    else
      url "https://github.com/ldc-developers/ldc/releases/download/v1.12.0/ldc2-1.12.0-linux-x86_64.tar.xz"
      version "1.12.0"
      sha256 "eeb83d3356d6ba3f5892f629de466df79c02bac5fd1f0e1ecdf01fe6171d42ac"
    end
  end

  def install
    # Fix the error:
    # CMakeFiles/LDCShared.dir/build.make:68: recipe for target 'dmd2/id.h' failed
    ENV.deparallelize unless OS.mac?

    ENV.cxx11
    (buildpath/"ldc-bootstrap").install resource("ldc-bootstrap")

    mkdir "build" do
      args = std_cmake_args + %W[
        -DLLVM_ROOT_DIR=#{Formula["llvm"].opt_prefix}
        -DINCLUDE_INSTALL_DIR=#{include}/dlang/ldc
        -DD_COMPILER=#{buildpath}/ldc-bootstrap/bin/ldmd2
        -DLDC_WITH_LLD=OFF
        -DRT_ARCHIVE_WITH_LDC=OFF
      ]
      # LDC_WITH_LLD see https://github.com/ldc-developers/ldc/releases/tag/v1.4.0 Known issues
      # RT_ARCHIVE_WITH_LDC see https://github.com/ldc-developers/ldc/issues/2350

      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.d").write <<~EOS
      import std.stdio;
      void main() {
        writeln("Hello, world!");
      }
    EOS
    system bin/"ldc2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    # Fix Error: The LLVMgold.so plugin (needed for LTO) was not found.
    if OS.mac?
      system bin/"ldc2", "-flto=thin", "test.d"
      assert_match "Hello, world!", shell_output("./test")
      system bin/"ldc2", "-flto=full", "test.d"
      assert_match "Hello, world!", shell_output("./test")
    end
    system bin/"ldmd2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
  end
end
