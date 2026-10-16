class Sdrsentinel < Formula
  desc "Passive RF signal characterization, pulse analysis, and direction finding suite"
  homepage "https://github.com/Zaryob/SDRPlusPlus"
  url "https://github.com/Zaryob/SDRPlusPlus.git", branch: "master"
  version "1.0.0"
  license "GPL-3.0-or-later"
  head "https://github.com/Zaryob/SDRPlusPlus.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "eigen"
  depends_on "fftw"
  depends_on "glfw"
  depends_on "libusb"
  depends_on "portaudio"
  depends_on "volk"
  depends_on "zstd"

  def install
    args = %w[
      -DCMAKE_BUILD_TYPE=Release
      -DOPT_BUILD_RF_TOOLS=ON
      -DOPT_BUILD_KRAKEN_DOA=ON
      -DOPT_BUILD_PORTAUDIO_SINK=ON
      -DOPT_BUILD_NEW_PORTAUDIO_SINK=ON
    ]

    system "cmake", "-B", "build", "-G", "Ninja", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_path_exists bin/"sdrpp"
  end
end
