class Xtensor < Formula
  desc "Multi-dimensional arrays with broadcasting and lazy computing"
  homepage "https://xtensor.readthedocs.io/en/latest/"
  url "https://github.com/QuantStack/xtensor/archive/0.22.0.tar.gz"
  sha256 "b73aacfdef12422f45b27ac43537bd9371ede092df4c14e20d2b8e41b2b5648e"
  license "BSD-3-Clause"

  bottle do
    cellar :any_skip_relocation
    sha256 "b3f2e18f9cb703dad3b54bb9144a5c2311447a02e3a99dfdfaa16a60f094866d" => :big_sur
    sha256 "1a256282dc60a06b042a75c0f925bd1d41595ed35a1b6fffb986bd6b73acf16f" => :arm64_big_sur
    sha256 "50282bf733c6d27583f9709ddfbe0dd70211dd0732dedffcc49c699a5ef45fb1" => :catalina
    sha256 "a2dd16b94e98a9a53cbba847c2e4563629ee6bbff49d7043836c6513cda22a87" => :mojave
  end

  depends_on "cmake" => :build

  resource "xtl" do
    url "https://github.com/xtensor-stack/xtl/archive/0.6.23.tar.gz"
    sha256 "aac8bb21e025a26698fed898c1c0f40c83a18846148cb3fbd67bc924f3269743"
  end

  def install
    resource("xtl").stage do
      system "cmake", ".", *std_cmake_args
      system "make", "install"
    end

    system "cmake", ".", "-Dxtl_DIR=#{lib}/cmake/xtl", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cc").write <<~EOS
      #include <iostream>
      #include "xtensor/xarray.hpp"
      #include "xtensor/xio.hpp"
      #include "xtensor/xview.hpp"

      int main() {
        xt::xarray<double> arr1
          {{11.0, 12.0, 13.0},
           {21.0, 22.0, 23.0},
           {31.0, 32.0, 33.0}};

        xt::xarray<double> arr2
          {100.0, 200.0, 300.0};

        xt::xarray<double> res = xt::view(arr1, 1) + arr2;

        std::cout << res(2) << std::endl;
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++14", "test.cc", "-o", "test", "-I#{include}"
    assert_equal "323", shell_output("./test").chomp
  end
end
