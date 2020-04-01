{ stdenv, fetchurl, apr, scons, openssl, aprutil, zlib, kerberos
, pkgconfig, libiconv }:

stdenv.mkDerivation rec {
  name = "serf-1.3.9";

  src = fetchurl {
    url = "https://www.apache.org/dist/serf/${name}.tar.bz2";
    sha256 = "1k47gbgpp52049andr28y28nbwh9m36bbb0g8p0aka3pqlhjv72l";
  };

  nativeBuildInputs = [ pkgconfig scons ];
  buildInputs = [ apr openssl aprutil zlib libiconv ]
    ++ stdenv.lib.optional (!stdenv.isCygwin) kerberos;

  patches = [ ./scons.patch ];

  prefixKey = "PREFIX=";

  sconsFlags = [
    "OPENSSL=${openssl}"
    "ZLIB=${zlib}"
  ] ++ stdenv.lib.optional (!stdenv.isCygwin)
    "GSSAPI=${kerberos.dev}";

  preConfigure = ''
    sconsFlags+=(
      "APR=$(echo ${apr.dev}/bin/*-config)"
      "APU=$(echo ${aprutil.dev}/bin/*-config)"
      "CC=$CC"
    )
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "HTTP client library based on APR";
    license = licenses.asl20;
    maintainers = with maintainers; [ orivej raskin ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
