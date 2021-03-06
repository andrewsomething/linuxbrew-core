class Icu4c < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "https://ssl.icu-project.org/"
  url "https://ssl.icu-project.org/files/icu4c/64.2/icu4c-64_2-src.tgz"
  mirror "https://github.com/unicode-org/icu/releases/download/release-64-2/icu4c-64_2-src.tgz"
  version "64.2"
  sha256 "627d5d8478e6d96fc8c90fed4851239079a561a6a8b9e48b0892f24e82d31d6c"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any
    sha256 "e858556120acc0c2d52b8fb572b677856724cc28d24a7e1b2762d458a2977c8e" => :mojave
    sha256 "02afdd6a472c31351e46a3b2a38c1c77354f0cc9199c3dbd7e06bc171b3638a2" => :high_sierra
    sha256 "4270a558e2709b7cee1be047a8e890ee15bdb379825fd6dc81fdba74cd438c01" => :sierra
    sha256 "e1f7af245f1c331b2ed6a79cc70a0fa444afd015978b77bda13c6109074ef679" => :x86_64_linux
  end

  keg_only :provided_by_macos, "macOS provides libicucore.dylib (but nothing else)"

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-samples
      --disable-tests
      --enable-static
    ]

    args << "--with-library-bits=64" if OS.mac?
    cd "source" do
      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    if File.readable? "/usr/share/dict/words"
      system "#{bin}/gendict", "--uchars", "/usr/share/dict/words", "dict"
    else
      (testpath/"hello").write "hello\nworld\n"
      system "#{bin}/gendict", "--uchars", "hello", "dict"
    end
  end
end
