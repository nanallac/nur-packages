{ stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, lib
, libcxx
, libusb1
}:

stdenv.mkDerivation rec {
  pname = "libedgetpu1-std";
  version = "16.0";

  src = fetchurl rec {
    url = "https://packages.cloud.google.com/apt/pool/${pname}_${version}_amd64_${sha256}.deb";
    sha256 = "1c4767d1dc4d7509a2b10b2c1e9a61e7efec7d13d19eddf1106047e53b376fab";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    libcxx
    libusb1
  ];

  unpackPhase = ''
    mkdir lib pkg

    dpkg -x $src pkg

    rm -r pkg/usr/share/lintian

    cp pkg/usr/lib/x86_64-linux-gnu/libedgetpu.so.1 ./lib
    cp -r pkg/usr/share .

    rm -r pkg
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r ./{lib,share} $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "The Edge TPU runtime.";
    homepage = "https://coral.ai/software/#edgetpu-runtime";    
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.asl20;
    maintainers = with maintainers; [ nanallac ];
    platforms = [ "x86_64-linux" ];
  };  
}